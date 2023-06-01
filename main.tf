data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  count             = var.create_aws_prometheus && !var.create_aws_ec2_prometheus ? 1 : 0
  name              = "${var.project_name_prefix}-prometheus-log"
  retention_in_days = var.cloudwatch_logs_retention
  tags              = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-prometheus" }))
}

resource "aws_iam_service_linked_role" "service_linked_role" {
  count            = var.create_aws_prometheus && !var.create_aws_ec2_prometheus && var.create_iam_service_linked_role ? 1 : 0
  aws_service_name = "es.amazonaws.com"
}

resource "aws_cloudwatch_log_resource_policy" "cloudwatch_log_resource_policy" {
  count           = var.create_aws_prometheus && !var.create_aws_ec2_prometheus ? 1 : 0
  policy_name     = "${var.project_name_prefix}-prometheus-log-policy"
  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

resource "aws_iam_role" "prometheus_role" {
  count              = var.iam_instance_profile == "" ? 1 : 0
  name               = "${var.project_name_prefix}-prometheus-role"
  tags               = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-prometheus-role" }))
  assume_role_policy = <<POLICY
  {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Sid" : "prometheusAssumeRole"
      }
    ]
  }
  POLICY
}

data "aws_iam_policy" "prometheus_ssm_mananged_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "prometheus_AmazonSSMManagedInstanceCore" {
  policy_arn = data.aws_iam_policy.prometheus_ssm_mananged_instance_core.arn
  role       = aws_iam_role.prometheus_role[0].name
}
resource "aws_iam_instance_profile" "prometheus_profile" {
  count = var.iam_instance_profile == "" ? 1 : 0
  name  = "${var.project_name_prefix}-prometheus-profile"
  role = aws_iam_role.prometheus_role[0].name
  tags  = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-prometheus-profile" }))
}
resource "aws_security_group" "prometheus_sg" {
  name        = "${var.project_name_prefix}-prometheus-sg"
  tags        = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-prometheus-sg" }))
  description = "prometheus security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP client communication"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow traffic to internet for Package installation"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  filter {
   name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  owners = ["amazon"]
}
# data "aws_ami" "ubuntu" {
#   owners = ["099720109477"]

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/ubuntu-*-*-amd64-server-*"]
#   }
# }

data "aws_ssm_parameter" "mongodb_endpoint" {
  depends_on = [
    module.mongodb
  ]
  name = "/${local.workspace.rds.environment}/MongoDB/MONGODB_HOST"
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
  vars = {
 elasticsearch_private_ip= var.elasticsearch_private_ip
 mongodb_private_ip=data.aws_ssm_parameter.mongodb_endpoint.value
}
  
}

resource "aws_instance" "ec2_prometheus" {
  count                   = !var.create_aws_prometheus && var.create_aws_ec2_prometheus ? 1 : 0
  ami                     = var.ami_id == "" ? data.aws_ami.amazon_linux_2.id : var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.subnet_ids[0]
  vpc_security_group_ids  = length(var.security_group_ids) == 0 ? [aws_security_group.prometheus_sg.id] : concat([aws_security_group.prometheus_sg.id], var.security_group_ids)
  key_name                = var.key_name
  iam_instance_profile    = var.iam_instance_profile == "" ? aws_iam_instance_profile.prometheus_profile[0].name : var.iam_instance_profile
  ebs_optimized           = var.ebs_optimized
  disable_api_termination = var.disable_api_termination
  #disable_api_stop        = var.disable_api_stop
  user_data_base64  = base64encode(data.template_file.user_data.rendered)
  source_dest_check = var.source_dest_check

  volume_tags = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-prometheus" }))
  tags        = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-prometheus" }))

  root_block_device {
    delete_on_termination = var.delete_on_termination
    encrypted             = var.volume_encrypted
    kms_key_id            = var.kms_key_id
    volume_size           = var.volume_size
    volume_type           = var.volume_type
  }

}
