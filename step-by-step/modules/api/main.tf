# Example from https://github.com/terraform-aws-modules/terraform-aws-apigateway-v2/blob/master/examples/vpc-link-http/main.tf

resource "random_pet" "this" {
  # Generates a random pet name which can be used to identify resources
  length = 2
}

###################
# HTTP API Gateway
###################

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "${random_pet.this.id}-http-vpc-links"
  description   = "HTTP API Gateway with VPC links"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_api_domain_name = false

  integrations = {
    "ANY /" = {
      lambda_arn             = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "GET /alb-internal-route" = {
      connection_type    = "VPC_LINK"
      vpc_link           = "my-vpc"
      integration_uri    = module.alb.http_tcp_listener_arns[0]
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"
    }

    "$default" = {
      lambda_arn = module.lambda_function.lambda_function_arn
    }
  }

  vpc_links = {
    my-vpc = {
      name               = "example"
      security_group_ids = [module.api_gateway_security_group.security_group_id]
      subnet_ids         = var.public_subnets
    }
  }

  tags = {
    Name = "private-api"
  }
}

module "api_gateway_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "api-gateway-sg-${random_pet.this.id}"
  description = "API Gateway group for example usage"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]

  egress_rules = ["all-all"]
}


############################
# Application Load Balancer
############################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "alb-${random_pet.this.id}"

  vpc_id          = var.vpc_id
  security_groups = [module.alb_security_group.security_group_id]
  subnets         = var.public_subnets

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]

  target_groups = [
    {
      name_prefix = "l1-"
      target_type = "lambda"
    }
  ]
}

module "alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "alb-sg-${random_pet.this.id}"
  description = "ALB for example usage"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]

  egress_rules = ["all-all"]
}


#############################################
# Using packaged function from Lambda module
#############################################

locals {
  package_url = "https://raw.githubusercontent.com/terraform-aws-modules/terraform-aws-lambda/master/examples/fixtures/python3.8-zip/existing_package.zip"
  downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
}

resource "null_resource" "download_package" {
  triggers = {
    downloaded = local.downloaded
  }

  provisioner "local-exec" {
    command = "curl -L -o ${local.downloaded} ${local.package_url}"
  }
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${random_pet.this.id}-lambda"
  description   = "My awesome lambda function"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.downloaded

  attach_network_policy  = true
  vpc_subnet_ids         = var.private_subnets
  vpc_security_group_ids = [module.lambda_security_group.security_group_id]

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*/*"
    }
  }
}

module "lambda_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "lambda-sg-${random_pet.this.id}"
  description = "Lambda security group for example usage"
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.api_gateway_security_group.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
}
