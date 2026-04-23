resource "aws_iam_role" "role_s3" {
  name = "role-ftp-s3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_full" {
  role       = aws_iam_role.role_s3.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# ESTA ES LA PARTE QUE TERRAFORM ESTÁ BUSCANDO Y NO ENCUENTRA:
resource "aws_iam_instance_profile" "profile_ftp" {
  name = "profile-ftp"
  role = aws_iam_role.role_s3.name
}