# Input variable definitions

variable "region" {
  description = "AWS Region"
  type    = string
  default = "us-east-1"
}

variable "application_name" {
  description = ""
  type    = string
}

variable "environment" {
  description = ""
  type    = string
}

variable "owner_team" {
  description = ""
  type    = string
}

variable "token_jwt_secret" {
  description = ""
  type    = string
}

variable "document_db_cluster_name" {
  description = ""
  type    = string
}

variable "document_db_cluster_instance_class" {
  description = ""
  type    = string
}

variable "document_db_cluster_db_name" {
  description = ""
  type    = string
}

variable "document_db_cluster_username" {
  description = ""
  type    = string
}

variable "document_db_cluster_password" {
  description = ""
  type    = string
}

variable "api_gateway_name" {
  description = ""
  type    = string
}

variable "api_gateway_stage_name" {
  description = ""
  type    = string
}

variable "smtp_server" {
  description = ""
  type    = string
}

variable "smtp_port" {
  description = ""
  type    = number
}

variable "smtp_username" {
  description = ""
  type    = string
}

variable "smtp_password" {
  description = ""
  type    = string
}