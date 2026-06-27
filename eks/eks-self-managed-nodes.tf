resource "aws_launch_template" "node" {
  name_prefix   = "${local.name}-node-"
  image_id      = data.aws_ssm_parameter.eks_ami.value
  instance_type = var.node_instance_type
  key_name      = var.node_key_name

  vpc_security_group_ids = [aws_security_group.node.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.node.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_disk_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.name}-node"
    })
  }

  user_data = base64encode(templatefile("${path.module}/templates/userdata.tpl", {
    cluster_name       = aws_eks_cluster.this.name
    cluster_endpoint   = aws_eks_cluster.this.endpoint
    cluster_ca         = aws_eks_cluster.this.certificate_authority[0].data
    node_ami_type      = var.node_ami_type
    bootstrap_extra_args = "--use-max-pods true"
  }))

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_eks_cluster.this]
}

resource "aws_autoscaling_group" "node" {
  name_prefix         = "${local.name}-node-"
  vpc_zone_identifier = local.node_subnet_ids

  desired_capacity = var.node_desired_capacity
  min_size         = var.node_min_size
  max_size         = var.node_max_size

  health_check_type         = "EC2"
  health_check_grace_period = 300
  wait_for_capacity_timeout = "10m"

  launch_template {
    id      = aws_launch_template.node.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(
      local.common_tags,
      {
        Name                                        = "${local.name}-node"
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      }
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_eks_cluster.this]
}
