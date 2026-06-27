# ---------------------------------------------------------------------------
# General
# ---------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for all EKS resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "teeraform-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS control plane and node AMI"
  type        = string
  default     = "1.31"
}

variable "environment" {
  description = "Environment tag applied to all resources"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "Primary VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
  description = "Secondary VPC CIDR for additional pod/workload subnets (prevents IP exhaustion)"
  type        = string
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across (use 3 for HA)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (NAT gateways, public load balancers)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for primary private subnets (worker nodes) — /19 gives ~8,190 IPs per AZ"
  type        = list(string)
  default     = ["10.0.16.0/19", "10.0.48.0/19", "10.0.80.0/19"]
}

variable "extended_subnet_cidrs" {
  description = "Additional private subnets on secondary CIDR for extra capacity and future node groups"
  type        = list(string)
  default     = ["10.1.0.0/19", "10.1.32.0/19", "10.1.64.0/19"]
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway instead of one per AZ (cheaper, less resilient)"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Allow the Kubernetes API server to be reachable from the public internet"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Allow the Kubernetes API server to be reachable from within the VPC"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public Kubernetes API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------
# Self-managed node group
# ---------------------------------------------------------------------------

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.large"
}

variable "node_desired_capacity" {
  description = "Desired number of worker nodes in the Auto Scaling group"
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 6
}

variable "node_disk_size" {
  description = "Root EBS volume size in GiB for each worker node"
  type        = number
  default     = 50
}

variable "node_ami_type" {
  description = "EKS optimized AMI type: amazon-linux-2 or amazon-linux-2023"
  type        = string
  default     = "amazon-linux-2"

  validation {
    condition     = contains(["amazon-linux-2", "amazon-linux-2023"], var.node_ami_type)
    error_message = "node_ami_type must be amazon-linux-2 or amazon-linux-2023."
  }
}

variable "node_key_name" {
  description = "Optional EC2 key pair name for SSH access to worker nodes"
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# VPC CNI / IP capacity
# ---------------------------------------------------------------------------

variable "enable_vpc_cni_prefix_delegation" {
  description = "Enable prefix delegation on aws-node for higher pod density per node"
  type        = bool
  default     = true
}

variable "vpc_cni_warm_prefix_target" {
  description = "Number of /28 prefixes to pre-allocate per node (reduces pod scheduling latency)"
  type        = number
  default     = 1
}

variable "vpc_cni_minimum_ip_target" {
  description = "Minimum free IPs to keep warm on each node"
  type        = number
  default     = 10
}

# ---------------------------------------------------------------------------
# EKS add-ons
# ---------------------------------------------------------------------------

variable "enable_ebs_csi_driver" {
  description = "Install the AWS EBS CSI driver add-on for persistent volumes"
  type        = bool
  default     = true
}

variable "enable_metrics_server" {
  description = "Deploy metrics-server for kubectl top and HPA"
  type        = bool
  default     = true
}

variable "enable_aws_load_balancer_controller" {
  description = "Deploy AWS Load Balancer Controller for ALB/NLB ingress"
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Cluster access
# ---------------------------------------------------------------------------

variable "cluster_admin_principals" {
  description = "IAM principal ARNs granted cluster-admin access via EKS access entries"
  type        = list(string)
  default     = []
}
