data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = var.cluster_name

  common_tags = merge(
    {
      Environment = var.environment
      Cluster     = var.cluster_name
    },
    var.tags
  )

  azs = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))

  cluster_subnet_ids = concat(
    aws_subnet.private[*].id,
    aws_subnet.extended[*].id,
    aws_subnet.public[*].id
  )

  node_subnet_ids = aws_subnet.private[*].id

  cluster_admin_principals = length(var.cluster_admin_principals) > 0 ? var.cluster_admin_principals : [
    data.aws_caller_identity.current.arn
  ]

  eks_ami_ssm_parameter = var.node_ami_type == "amazon-linux-2023" ? (
    "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
  ) : (
    "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2/recommended/image_id"
  )
}

data "aws_ssm_parameter" "eks_ami" {
  name = local.eks_ami_ssm_parameter
}
