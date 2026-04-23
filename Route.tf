# --- Gateways de Internet ---
resource "aws_internet_gateway" "igw_ftp" {
  vpc_id = aws_vpc.vpc_ftp.id
  tags   = { Name = "IGW-FTP" }
}

resource "aws_internet_gateway" "igw_ldap_aux" {
  vpc_id = aws_vpc.vpc_ldap.id
  tags   = { Name = "IGW-LDAP-Auxiliar" }
}

# --- NAT Gateway (La salida segura para el LDAP) ---
resource "aws_eip" "nat_eip" { domain = "vpc" }

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.sub_pub_nat.id
  tags          = { Name = "NAT-Gateway-LDAP" }
}

# --- Tablas de Enrutamiento ---
# Tabla Pública FTP
resource "aws_route_table" "rt_ftp" {
  vpc_id = aws_vpc.vpc_ftp.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_ftp.id
  }
}
resource "aws_route_table_association" "a_ftp" {
  subnet_id      = aws_subnet.sub_pub_ftp.id
  route_table_id = aws_route_table.rt_ftp.id
}

# Tabla Pública LDAP (Solo para el NAT)
resource "aws_route_table" "rt_ldap_pub" {
  vpc_id = aws_vpc.vpc_ldap.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_ldap_aux.id
  }
}
resource "aws_route_table_association" "a_ldap_nat" {
  subnet_id      = aws_subnet.sub_pub_nat.id
  route_table_id = aws_route_table.rt_ldap_pub.id
}

# Tabla Privada LDAP (El tráfico web sale por el NAT)
resource "aws_route_table" "rt_ldap_priv" {
  vpc_id = aws_vpc.vpc_ldap.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}
resource "aws_route_table_association" "a_ldap_priv" {
  subnet_id      = aws_subnet.sub_priv_ldap.id
  route_table_id = aws_route_table.rt_ldap_priv.id
}