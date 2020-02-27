# >>> ES vars
variable "region" {
  type        = string
  description = "The region we want to operate in."
}

variable "product_name" {
  type        = string
  description = "The product name as used in various places (e.g. aws resource tags), for example tixx"
}

variable "environment" {
  type        = string
  description = "The environment this cluster is representing, for example dv (development), st (staging) or pd (production)"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the vpc provided by DOIT"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all created resources"
}

variable "data_subnet_ids" {
  type        = list(string)
  description = "The IDs of the data subnets provided by DOIT"
}

variable "instance_type" {
  type        = string
  description = "The type of the instance"
}

variable "elasticsearch_version" {
  type        = string
  description = "Version of Elasticsearch to deploy"
}

variable "instance_count" {
  type        = number
  description = "Number of data nodes in the cluster"
}

variable "zone_awareness_enabled" {
  type        = bool
  description = "Enable zone awareness for Elasticsearch cluster"
}

variable "encrypt_at_rest_enabled" {
  type        = bool
  description = "Whether to enable encryption at rest"
}

variable "create_iam_service_linked_role" {
  type        = bool
  description = "Whether to create `AWSServiceRoleForAmazonElasticsearchService` service-linked role. Set it to `false` if you already have an ElasticSearch cluster created in the AWS account and AWSServiceRoleForAmazonElasticsearchService already exists. See https://github.com/terraform-providers/terraform-provider-aws/issues/5218 for more info"
}

variable "ebs_volume_size" {
  type        = number
  description = "EBS volumes for data storage in GB"
}

output "es_logs_security_group_id" {
  value       = module.elasticsearch_logs.security_group_id
  description = "Security Group ID to control access to the Elasticsearch domain"
}