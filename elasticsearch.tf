# Elasticsearch
module "elasticsearch_logs" {
  source                         = "git::https://github.com/cloudposse/terraform-aws-elasticsearch.git?ref=tags/0.5.0"
  tags                           = var.tags
  name                           = "${format("%s-%s-k8s-logs", var.product_name, var.environment)}"
  vpc_id                         = var.vpc_id
  subnet_ids                     = [var.data_subnet_ids.0]
  zone_awareness_enabled         = var.zone_awareness_enabled
  elasticsearch_version          = var.elasticsearch_version
  instance_type                  = var.instance_type
  instance_count                 = var.instance_count
  create_iam_service_linked_role = false
  encrypt_at_rest_enabled        = var.encrypt_at_rest_enabled
  ebs_volume_size                = var.ebs_volume_size
  iam_actions                    = ["es:ESHttpGet", "es:ESHttpPut", "es:ESHttpPost", "es:ESHttpDelete"]
  kibana_subdomain_name          = "kibana-kubernetes-logs"
  iam_role_arns                  = ["*"]
}
