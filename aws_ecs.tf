####################################################
# ECS IAM Role
####################################################
resource "aws_iam_role" "ecs_task_execution_role" {
  name                = "ecs_task_execution_role"
  assume_role_policy  = jsonencode({
    Version           = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
   managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ]
}

resource "aws_iam_role_policy" "kms_decrypt_policy" {
  name = "ecs_task_execution_role_policy_kms"
  role = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
          "kms:Decrypt"
        ],
        "Resource": ["*"]
      }
    ]
  })
}

####################################################
# ECS cluster
####################################################
resource "aws_ecs_cluster" "main" {
  name = "ECS-Cluster"
}

####################################################
# NGINX container
####################################################
resource "aws_ecs_task_definition" "main" {
  family                    = "nginx_nextjs"
  cpu                       = 1024
  memory                    = 2048
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn             = aws_iam_role.ecs_task_execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  container_definitions = <<EOL
  [
    {
      "name": "nginx",
      "image": "234660340542.dkr.ecr.ap-northeast-1.amazonaws.com/nginx:latest",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "network_mode": "awsvpc",
      "portMappings": [{
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }]
    },
    {
      "name": "nextjs",
      "image": "234660340542.dkr.ecr.ap-northeast-1.amazonaws.com/next_app:latest",
      "cpu": 512,
      "memory": 1014,
      "essential": true,
      "network_mode": "awsvpc",
      "portMappings": [{"containerPort": 3000}]
    }
  ]
  EOL
}

resource "aws_ecs_service" "nginx" {
  depends_on = [aws_lb_listener_rule.main]
  name = "nginx_nextjs"
  cluster = aws_ecs_cluster.main.name
  launch_type = "FARGATE"
  desired_count = 1
  task_definition = aws_ecs_task_definition.main.arn
  network_configuration {
    subnets = [aws_subnet.public_1a.id]
    security_groups = [aws_security_group.app.id]
    # ECR S3 bucket get
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "nginx"
    container_port   = "80"
  }
}

####################################################
# ALB -> NGINX container
####################################################
resource "aws_lb_target_group" "main" {
  name_prefix = "alb"
  vpc_id = aws_vpc.this.id
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    port = 80
    path = "/"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = aws_lb_listener.https.arn
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
  condition {
    path_pattern {
      values = [var.domain]
    }
  }
}
