# --- Subred de la VPC FTP ---
resource "aws_subnet" "sub_pub_ftp" {
  vpc_id                  = aws_vpc.vpc_ftp.id
  cidr_block              = "172.31.1.0/24"
  map_public_ip_on_launch = true # IP Pública para el FTP
  tags                    = { Name = "Subred-Publica-FTP" }
}

# --- Subredes de la VPC LDAP ---
# 1. Subred pequeña pública solo para alojar el NAT Gateway
resource "aws_subnet" "sub_pub_nat" {
  vpc_id                  = aws_vpc.vpc_ldap.id
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = true
  tags                    = { Name = "Subred-NAT-Publica" }
}

# 2. Subred PRIVADA REAL donde vivirá el LDAP (Aislado)
resource "aws_subnet" "sub_priv_ldap" {
  vpc_id                  = aws_vpc.vpc_ldap.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = false # Sin IP pública, 100% privado
  tags                    = { Name = "Subred-Privada-LDAP" }
}