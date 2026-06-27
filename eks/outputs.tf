output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded CA certificate for kubectl"
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster control plane"
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "Security group ID attached to worker nodes"
  value       = aws_security_group.node.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (NAT, public load balancers)"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Primary private subnet IDs for worker nodes"
  value       = aws_subnet.private[*].id
}

output "extended_subnet_ids" {
  description = "Extended private subnet IDs on secondary CIDR for additional capacity"
  value       = aws_subnet.extended[*].id
}

output "all_cluster_subnet_ids" {
  description = "All subnet IDs registered with the EKS cluster"
  value       = local.cluster_subnet_ids
}

output "node_autoscaling_group_name" {
  description = "Name of the self-managed node Auto Scaling group"
  value       = aws_autoscaling_group.node.name
}

output "node_iam_role_arn" {
  description = "IAM role ARN used by worker nodes"
  value       = aws_iam_role.node.arn
}

output "configure_kubectl" {
  description = "Command to configure kubectl for this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.this.name}"
}

output "estimated_private_ip_capacity" {
  description = "Approximate assignable IPs across primary and extended private subnets"
  value = {
    primary_subnet_ips_per_az  = 8190
    extended_subnet_ips_per_az = 8190
    total_azs                  = length(var.private_subnet_cidrs)
    total_estimated_ips        = (8190 + 8190) * length(var.private_subnet_cidrs)
    prefix_delegation_enabled  = var.enable_vpc_cni_prefix_delegation
  }
}

output "addons_enabled" {
  description = "EKS add-ons and applications deployed"
  value = {
    vpc_cni                      = aws_eks_addon.vpc_cni.addon_version
    coredns                      = aws_eks_addon.coredns.addon_version
    kube_proxy                   = aws_eks_addon.kube_proxy.addon_version
    ebs_csi_driver               = var.enable_ebs_csi_driver ? aws_eks_addon.ebs_csi[0].addon_version : null
    metrics_server               = var.enable_metrics_server
    aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  }
}
