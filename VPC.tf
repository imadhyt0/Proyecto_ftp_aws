# --- VPC FTP (Pública) ---
resource "aws_vpc" "vpc_ftp" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "VPC-FTP-Publica" }
}

# --- VPC LDAP (Privada) ---
resource "aws_vpc" "vpc_ldap" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "VPC-LDAP-Privada" }
}