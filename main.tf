terraform {
  required_version = ">= 0.12.7"
}

locals{
    vpc_id = "vpc-test123"
    region = "eu-east-1"
    cluster_name = "dev-eks-cluster"
    subnets = ["subnet-123", "subnet-125", "subnet-126"]
    cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    asg_desired_capacity = 1
    asg_max_size = 3
    asg_min_size = 1
    instance_type = "m4.large"
    spot_price = "0.20"
}

provider "aws" {
  region  = local.region
}

module "eks-cluster" {
  source       = "terraform-aws-modules/eks/aws"
  version = "v7.0.1"
  cluster_name = local.cluster_name
  subnets = local.subnets
  vpc_id  = local.vpc_id
  worker_groups = [
    {
      spot_price = local.spot_price
      asg_desired_capacity = local.asg_desired_capacity
      asg_max_size = local.asg_max_size
      asg_min_size = local.asg_min_size
      instance_type = local.instance_type
      name = "worker-group"
      additional_userdata = "Worker group configurations"
      tags = [{
          key                 = "worker-group-tag"
          value               = "worker-group-1"
          propagate_at_launch = true
      }]
    }
  ]
  map_users = [
      {
        userarn = "arn:aws:iam::AWS_ACCOUNT:user/AWS_USERNAME"
        username = "AWS_USERNAME"
        groups = ["system:masters"]
      },
    ]
  cluster_enabled_log_types = local.cluster_enabled_log_types
  tags = {
    environment = "dev-env"
  }
}
