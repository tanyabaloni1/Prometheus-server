variable "project_name_prefix" {
  type        = string
  description = "A string value to describe prefix of all the resources"
  default     = "dev-tothenew"
}

variable "common_tags" {
  type        = map(string)
  description = "A map to add common tags to all the resources"
  default = {
    Environment = "dev"
    Project     = "ToTheNew",
  }
}

variable "vpc_id" {
  type        = string
  description = "A string value for VPC ID"
  default = "vpc-06b81581f436fc50d"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet Ids where server will be launched"
  default = ["subnet-0439466f054b180df","subnet-00fb82858212f688a"]
}

variable "security_group_ids" {
  type        = list(string)
  description = "A string value for Security Group ID"
  default     = []
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID for creating AWS resources default alias for EC2 is aws/ebs and for AWS prometheus aws/es"
  default     = "alias/aws/ebs"
}

variable "cloudwatch_logs_retention" {
  type        = number
  description = "Cloudwatch logs of the AWS prometheus retention period"
  default     = 7
}

variable "volume_type" {
  type        = string
  description = "Volume type for EC2 instance default latest type"
  default     = "gp3"
}

variable "volume_size" {
  type        = number
  description = "Volume size of the EC2 instance"
  default     = 100
}

variable "volume_encrypted" {
  type        = bool
  description = "Volume can be encrypted through this check"
  default     = true
}

variable "delete_on_termination" {
  type        = bool
  description = "Delete the volume after the termination of the EC2"
  default     = true
}

variable "instance_type" {
  type        = string
  description = "Instance type of the Server"
  default     = "t3.large"
}

variable "instance_count" {
  type        = number
  description = "Number of node of AWS prometheus you want to launch"
  default     = 1
}

variable "availability_zone_count" {
  type        = number
  description = "Availability Zone count when zone is enabled"
  default     = 2
}

variable "zone_awareness_enabled" {
  type        = bool
  description = "Zone Awareness enable for multi AZ"
  default     = false
}

variable "automated_snapshot_start_hour" {
  type        = number
  description = "AWS prometheus snapshot start hour time"
  default     = 22
}

variable "advanced_security_options_enabled" {
  type        = bool
  description = "Advance Security Option to Enable for Authentication"
  default     = false
}

variable "create_iam_service_linked_role" {
  type        = bool
  default     = false
  description = "Whether to create `AWSServiceRoleForAmazonElasticsearchService` service-linked role. Set it to `false` if you already have an ElasticSearch cluster created in the AWS account and AWSServiceRoleForAmazonElasticsearchService already exists."
}

variable "create_aws_prometheus" {
  type        = bool
  description = "If you want to create the AWS prometheus enable this check"
  default     = false
}

variable "create_aws_ec2_prometheus" {
  type        = bool
  description = "If you want to create the AWS EC2 instance prometheus enable this check"
  default     = true
}

variable "key_name" {
  type        = string
  description = "Key name for launching the EC2 instance"
  default     = ""
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM Profile name for launching the EC2 instance"
  default     = ""
}

variable "ebs_optimized" {
  type        = bool
  description = "EBS optimized enable"
  default     = true
}

variable "disable_api_termination" {
  type        = bool
  description = "Disable API termination means disable instance termination"
  default     = true
}

variable "disable_api_stop" {
  type        = bool
  description = "Disable API stop means disable instance stop"
  default     = true
}

variable "source_dest_check" {
  type        = bool
  description = "Source destination Check"
  default     = true
}

variable "ami_id" {
  type        = string
  description = "AMI id of the Amazon Linux 2"
  default     = ""
}

variable "elasticsearch_private_ip"{
type        = string
}

