provider "aws" {
  region = "eu-west-1"
}


resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr,   count.index)
  availability_zone       = element(var.availability_zones,   count.index)
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.project}-${var.environment}-${element(var.availability_zones, count.index)}-public-subnet"
    Sub			= "nacl"
  }
}
// Private subnet //
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones,   count.index)
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.project}-${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
    Sub			= "nacl"
  }
}

resource "aws_flow_log" "vpc-flowlog-qa" {
  iam_role_arn    = aws_iam_role.vpc-flowlog-qa-iam-role.arn
  log_destination = aws_cloudwatch_log_group.cloudwatch_log_group-qa.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group-qa" {
  name = "cloudwatch_log_group-qa"
}

resource "aws_iam_role" "vpc-flowlog-qa-iam-role"  {
  name = "vpc-flowlog-qa-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc-flowlog-qa-iam-policy" {
  name = "VPC-FLOWLOG-POLICY"
  role = aws_iam_role.vpc-flowlog-qa-iam-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {

      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_network_acl" "DataLake_qa_Network_ACL"{
  vpc_id = aws_vpc.vpc.id
  subnet_ids = concat(aws_subnet.public_subnet.*.id, aws_subnet.private_subnet.*.id)
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 97
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }


ingress {
    protocol   = "tcp"
    rule_no    = 98
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 99
    action     = "allow"
    cidr_block = "172.22.0.0/22"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "main"
  }
}


output "subnet_id" {
  description = "The ID of the VPC"
  value       = concat(aws_subnet.public_subnet.*.id, aws_subnet.private_subnet.*.id)
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = concat(aws_vpc.vpc.*.arn, [""])[0]
}

output "vpc_id" {
  description = "The ARN of the VPC"
  value       = concat(aws_vpc.vpc.*.id, [""])[0]
}
