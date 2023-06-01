data "template_file" "promscript" {
template = file("${path.module}/user_data.sh")
vars = {
 elasticsearch_private_ip= var.elasticsearch_private_ip
}
}
