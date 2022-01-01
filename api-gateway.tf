resource "aws_api_gateway_rest_api" "this" {
  name           = format("%s-%s", var.project, var.context)
  api_key_source = var.api_key_source

  tags = merge(local.common_tags, {
    Environment = var.environment,
    Project     = var.project,
    Name        = format("%s-%s", var.project, var.context),
    Stage       = var.stage,
  })
}

resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "v1_healthcheck" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "healthcheck"
}

resource "aws_api_gateway_method" "healthcheck" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.v1_healthcheck.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "healthcheck" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.v1_healthcheck.id
  http_method = aws_api_gateway_method.healthcheck.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.v1_healthcheck.id
  http_method = aws_api_gateway_method.healthcheck.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "healthcheck" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.v1_healthcheck.id
  http_method = aws_api_gateway_method.healthcheck.http_method
  status_code = 200

  response_templates = {
    "application/json" = jsonencode({
      statusCode = 200
      message    = "OK"
    })
  }
}

# Domain name api gateway

resource "aws_api_gateway_domain_name" "api_gateway_domain" {
  domain_name     = format("api.%s", var.domain_name)
  certificate_arn = data.aws_acm_certificate.cert.arn

  tags = local.common_tags
}

resource "aws_api_gateway_base_path_mapping" "api_base_path_mapping" {
  api_id      = aws_api_gateway_rest_api.this.id
  domain_name = aws_api_gateway_domain_name.api_gateway_domain.domain_name
}

# API Gateway deployment

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on        = [aws_api_gateway_integration.healthcheck]
  rest_api_id       = aws_api_gateway_rest_api.this.id
  stage_name        = var.stage
  description       = "API deployment"
  stage_description = "API deployment"

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.v1_healthcheck.id,
      aws_api_gateway_method.healthcheck.id,
      aws_api_gateway_integration.healthcheck.id,
    ]))
  }
}
