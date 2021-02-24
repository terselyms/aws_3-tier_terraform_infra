resource "aws_route53_zone" "minsigi1019" {
  name = "minsigi1019.shop"

  vpc {
    vpc_id = aws_vpc.minsik-vpc.id
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.minsigi1019.zone_id
  name    = "www.minsigi1019.shop"
  type    = "A"

  alias {
    name                   = aws_lb.web-alb.dns_name
    zone_id                = aws_lb.web-alb.zone_id
    evaluate_target_health = true
  }
}

output "name-server"{
  value = aws_route53_zone.minsigi1019.name_servers
}
