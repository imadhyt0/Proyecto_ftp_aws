resource "aws_security_group" "sg_ftp" {
  name   = "SG-FTP"
  vpc_id = aws_vpc.vpc_ftp.id

  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Puertos Pasivos
    from_port   = 60000
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_ldap" {
  name   = "SG-LDAP"
  vpc_id = aws_vpc.vpc_ldap.id

  ingress { # Solo permitimos LDAP desde la red del FTP
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  ingress { # Para poder entrar por SSH desde el FTP (Salto)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}