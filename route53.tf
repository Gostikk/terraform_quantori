resource "aws_route53_zone" "testzone" {
  name = "tflab.inner"
}

output "ns-servers" {
  value = aws_route53_zone.testzone.name_servers
}