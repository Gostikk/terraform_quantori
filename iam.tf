resource "aws_iam_role" "ec2_access_s3_role" {
  name               = "ec2seacces-role"
  assume_role_policy = file("ec2role.json")
}

resource "aws_iam_policy" "s3_ro_access" {
  name        = "s3_ro_acess"
  description = "S3 Read-only policy"
  policy      = file("s3policy.json")
}

resource "aws_iam_policy_attachment" "ec2s3-ro-attach" {
  name       = "ec2s3-ro-attachment"
  roles      = ["${aws_iam_role.ec2_access_s3_role.name}"]
  policy_arn = aws_iam_policy.s3_ro_access.arn
}

resource "aws_iam_instance_profile" "s3roacess_iam" {
  name = "s3_iam_acess"
  role = aws_iam_role.ec2_access_s3_role.name
}

resource "aws_iam_policy" "tag_creation_restriction" {
  name        = "iam_tag_policy"
  description = "Tag Creation Restriction"
  policy      = file("iamtagpolicy.json")
}