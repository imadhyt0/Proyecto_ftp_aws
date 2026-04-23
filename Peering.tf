# --- VPC PEERING (El puente) ---
resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = aws_vpc.vpc_ftp.id
  peer_vpc_id = aws_vpc.vpc_ldap.id
  auto_accept = true
  tags        = { Name = "Peering-FTP-LDAP" }
}

# --- Rutas del Peering ---
# Enseñar al FTP cómo llegar al LDAP
resource "aws_route" "r_ftp_to_ldap" {
  route_table_id            = aws_route_table.rt_ftp.id
  destination_cidr_block    = aws_vpc.vpc_ldap.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

# Enseñar al LDAP cómo responder al FTP
resource "aws_route" "r_ldap_to_ftp" {
  route_table_id            = aws_route_table.rt_ldap_priv.id
  destination_cidr_block    = aws_vpc.vpc_ftp.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}