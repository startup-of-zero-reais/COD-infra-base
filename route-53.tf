
resource "aws_route53_record" "api_gateway" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api_gateway_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gateway_domain.cloudfront_zone_id
    evaluate_target_health = true
  }
}
