# resource "tls_private_key" "deploy_key" {
#   algorithm = "RSA"
#   rsa_bits = 4096
# }

# resource "local_file" "private_key" {
#   content = tls_private_key.deploy_key.private_key_pem
#   filename = "${path.module}/deploy_key.pem"
#   file_permission = 400

#   depends_on = [
#     tls_private_key.deploy_key
#   ]
# }

# resource "aws_key_pair" "deploy" {
#   key_name   = "deploy_key"
#   public_key = tls_private_key.deploy_key.public_key_openssh

#   tags = {
#     Creator = "OlehSobchuk"
#   }
# }
