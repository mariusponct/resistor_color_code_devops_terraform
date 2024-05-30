
resource "aws_ecs_cluster" "rcc-cluster" {
  name = "resistor_color_code-cluster"
}

resource "aws_ecs_task_definition" "rcc-td" {
  family                   = "resistor_color_code_td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "resistor_color_code",
    "image": "docker.io/mariuspnct/resistorapp:8112c80",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 5001,
        "hostPort": 5001,
        "protocol": "tcp"
      }
    ]
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "rcc-service" {
  name            = "resistor_color_code-service"
  cluster         = aws_ecs_cluster.rcc-cluster.id
  task_definition = aws_ecs_task_definition.rcc-td.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.rcc_subnet.id]
    security_groups  = [aws_security_group.rcc_SG.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.rcc-tg.arn
    container_name   = "resistor_color_code"
    container_port   = 5001
  }
}


