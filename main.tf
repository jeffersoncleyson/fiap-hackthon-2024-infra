provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  backend "s3" {
    bucket = "fiap-hackthon-soat-2024-state"
    key    = "fiap-hackthon-soat-2024"
    region = "us-east-1"
  }
}

module "network" {
  source = "git::https://github.com/jeffersoncleyson/fiap-hackthon-2024-tf-network.git?ref=main"
  ############################################### [TAGs] Variables
  application_name = var.application_name
  environment      = var.environment
  owner_team       = var.owner_team
  ############################################### [IGW] Variables
  internet_gateway_tag_name = format("%s-igw", var.application_name)
}


module "ec2" {
  source = "git::https://github.com/jeffersoncleyson/fiap-hackthon-2024-tf-ec2.git?ref=main"
  application_name   = var.application_name
  vpc_public_subnets = [module.network.public_subnet_one, module.network.public_subnet_two]
  vpc_sg_id          = module.network.aws_sg_id

  depends_on = [module.network]
}

module "documentdb" {
  source = "git::https://github.com/jeffersoncleyson/fiap-hackthon-2024-tf-documentdb.git?ref=main"
  application_name    = var.application_name
  cluster_name        = var.document_db_cluster_name
  username_admin      = var.document_db_cluster_username
  password_admin      = var.document_db_cluster_password
  instance_class      = var.document_db_cluster_instance_class
  vpc_private_subnets = [module.network.private_subnet_one, module.network.private_subnet_two]
  vpc_sg_id           = module.network.aws_sg_id

  depends_on = [module.network]
}



module "login" {
  source = "git::https://github.com/jeffersoncleyson/fiap-hackthon-2024-tf-lambda.git?ref=main"
  application_name   = var.application_name
  path_lambda        = "./lambdas"
  lambda_name        = "login"
  lambda_handler     = "src.main.lambda_handler"
  lambda_runtime     = "python3.9"
  vpc_public_subnets = [module.network.public_subnet_one, module.network.public_subnet_two]
  vpc_sg_id          = module.network.aws_sg_id
  lambda_environments = {
    "MONGO_URI" : format("mongodb://%s:%s@%s:27017/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false", var.document_db_cluster_username, var.document_db_cluster_password, module.documentdb.docdb_endpoint),
    "DB_NAME" : var.document_db_cluster_db_name,
    "SECRET" : var.token_jwt_secret
  }
  depends_on = [module.documentdb, module.network]
}

module "authorizer" {
  source = "git::https://github.com/jeffersoncleyson/fiap-hackthon-2024-tf-lambda.git?ref=main"
  application_name   = var.application_name
  path_lambda        = "./lambdas"
  lambda_name        = "authorizer"
  lambda_handler     = "src.main.lambda_handler"
  lambda_runtime     = "python3.9"
  vpc_public_subnets = [module.network.public_subnet_one, module.network.public_subnet_two]
  vpc_sg_id          = module.network.aws_sg_id
  lambda_environments = {
    "SECRET" : var.token_jwt_secret
  }

  depends_on = [module.network]
}

module "usuario" {
  source = "git::https://github.com/jeffersoncleyson/fiap-hackthon-2024-tf-lambda.git?ref=main"
  application_name   = var.application_name
  path_lambda        = "./lambdas"
  lambda_name        = "usuario"
  lambda_handler     = "src.main.lambda_handler"
  lambda_runtime     = "python3.9"
  vpc_public_subnets = [module.network.public_subnet_one, module.network.public_subnet_two]
  vpc_sg_id          = module.network.aws_sg_id
  lambda_environments = {
    "MONGO_URI" : format("mongodb://%s:%s@%s:27017/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false", var.document_db_cluster_username, var.document_db_cluster_password, module.documentdb.docdb_endpoint),
    "DB_NAME" : var.document_db_cluster_db_name,
    "SECRET" : var.token_jwt_secret
  }

  depends_on = [module.documentdb, module.network]
}

module "ponto" {
  source = "git::https://github.com/jeffersoncleyson/fiap-hackthon-2024-tf-lambda.git?ref=main"
  application_name   = var.application_name
  path_lambda        = "./lambdas"
  lambda_name        = "ponto"
  lambda_handler     = "src.main.lambda_handler"
  lambda_runtime     = "python3.9"
  vpc_public_subnets = [module.network.public_subnet_one, module.network.public_subnet_two]
  vpc_sg_id          = module.network.aws_sg_id
  lambda_environments = {
    "MONGO_URI" : format("mongodb://%s:%s@%s:27017/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false", var.document_db_cluster_username, var.document_db_cluster_password, module.documentdb.docdb_endpoint),
    "DB_NAME" : "fiap"
  }

  depends_on = [module.documentdb, module.network]
}

module "relatorio" {
  source = "git::https://github.com/jeffersoncleyson/fiap-hackthon-2024-tf-lambda.git?ref=main"
  application_name   = var.application_name
  path_lambda        = "./lambdas"
  lambda_name        = "relatorio"
  lambda_handler     = "src.main.lambda_handler"
  lambda_runtime     = "python3.9"
  vpc_public_subnets = [module.network.private_subnet_one, module.network.private_subnet_two]
  vpc_sg_id          = module.network.aws_sg_id
  lambda_environments = {
    "MONGO_URI" : format("mongodb://%s:%s@%s:27017/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false", var.document_db_cluster_username, var.document_db_cluster_password, module.documentdb.docdb_endpoint),
    "DB_NAME" : var.document_db_cluster_db_name,
    "SMTP_SERVER"   = var.smtp_server,
    "SMTP_PORT"     = var.smtp_port,
    "SMTP_USER"     = var.smtp_username,
    "SMTP_PASSWORD" = var.smtp_password,
  }

  depends_on = [module.documentdb, module.network]
}


module "api_gateway" {

  source = "git::https://github.com/jeffersoncleyson/fiap-hackthon-2024-tf-api-gateway.git?ref=main"
  application_name = var.application_name
  stage_name       = var.api_gateway_stage_name
  api_gateway_name = var.api_gateway_name

  ## LAMBDA | ENDPOINTS LOGIN/LOGOUT
  lambda_login_invoke_arn = module.login.function_invoke_arn
  lambda_login_name       = module.login.function_name

  ## AUTHORIZER
  lambda_authorizer_invoke_arn = module.authorizer.function_invoke_arn
  lambda_authorizer_name       = module.authorizer.function_name

  ## USUARIO
  lambda_usuario_invoke_arn = module.usuario.function_invoke_arn
  lambda_usuario_name       = module.usuario.function_name

  ## PONTO
  lambda_ponto_invoke_arn = module.ponto.function_invoke_arn
  lambda_ponto_name       = module.ponto.function_name

  ## RELATORIO
  lambda_relatorio_invoke_arn = module.relatorio.function_invoke_arn
  lambda_relatorio_name       = module.relatorio.function_name

  depends_on = [
    module.authorizer, module.login, module.ponto, module.relatorio, module.usuario
  ]

}







