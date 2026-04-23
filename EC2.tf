resource "aws_instance" "srv_ftp" {
  ami           = "ami-0e2c8ccd9e036d13a" # Ubuntu 24.04
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sub_pub_ftp.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.sg_ftp.id]
  iam_instance_profile   = aws_iam_instance_profile.profile_ftp.name

  # ESTA ES LA LÍNEA NUEVA:
  user_data = file("instalar_ftp.sh")

  tags = { Name = "Servidor-FTP-Ubuntu" }
}

resource "aws_instance" "srv_ldap" {
  ami           = "ami-0533af06891040f3b" # Amazon Linux 2023
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sub_priv_ldap.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.sg_ldap.id]

  # ESTA ES LA LÍNEA NUEVA:
  user_data = file("instalar_ldap.sh")

  tags = { Name = "Servidor-LDAP-Privado" }
}