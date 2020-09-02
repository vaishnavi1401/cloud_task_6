provider "aws" {
  region                  = "ap-south-1"
  profile                 = "vaishnavi"
}

provider "kubernetes" {
  config_context_cluster  = "minikube"
}
resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "mywordpress"
    labels = {
      test = "MyExampleApp"
    }
  }
  spec {
    replicas = 1
       strategy {
            type = "RollingUpdate"
        }
    selector {
       match_labels = {
                type = "cms"
                env = "prod"
            }
    }
    template {
      metadata {
      labels ={
               type = "cms"
               env = "prod"
                }
      }
      spec {
        container {
          image = "wordpress"
          name  = "wordpress"
          port{
            container_port = 80
          }
          }
        }
      }
    }
  }
resource "kubernetes_service" "Nodeport" {
  depends_on=[kubernetes_deployment.wordpress]
  metadata {
    name = "terraform-example"
  }
    spec {
        type = "NodePort"
        selector = {
          type = "cms"
        }
        port {
            port = 80
            target_port = 80
            protocol = "TCP"
        }
    }
}
resource "aws_db_instance" "mywpdb" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydatabase"
  username             = "vaishnavi"
  password             = "123456789"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible = true
}