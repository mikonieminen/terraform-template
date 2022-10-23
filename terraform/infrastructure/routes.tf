
# # Expect the actual hosted zone to be created elsewhere and
# # treat it just as data so that when destroying the deployment
# # we won't destroy the zone as recreating it requires mapping
# # nameservers that is done in external account/system.
# #
# # Zone should be define in the environment as they are expected
# # to be per environment.
# data "aws_route53_zone" "root" {
#   zone_id = module.env.zone_id
# }


# # This is needed for Cognito User Pool Domain
# # currently points nowhere
# resource "aws_route53_record" "root" {
#   zone_id = data.aws_route53_zone.root.zone_id
#   name    = data.aws_route53_zone.root.name
#   type    = "A"

#   ttl = 300
#   records = [
#     # TODO: Change this to some actual location
#     "127.0.0.1"
#   ]
# }
