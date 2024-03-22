############################################### [AWS API GATEWAY] Outputs

output "api_gateway_url" {
  description = "API Gateway URL."

  value = module.api_gateway.base_url_api_gw_invoke_url
}

###############################################