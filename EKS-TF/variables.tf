variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "mario-v2-cluster"
}

variable "ecr_repo_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "mario-v2-app-repo"
}
