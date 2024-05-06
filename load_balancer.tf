
resource "aws_security_group" "lb_SG" {
  name        = "lb-SG"
  description = "Allow inbound traffic on port 80"
  vpc_id      = aws_vpc.rcc_vpc.id

  tags = {
    Name = "application_load_balancer-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "lb_inbound_rules" {
  security_group_id = aws_security_group.lb_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "lb_outbound_rules" {
  security_group_id = aws_security_group.lb_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_lb" "rcc-lb" {
  name               = "resistor-color-code-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_SG.id]
  subnets            = [aws_subnet.rcc_subnet.id, aws_subnet.rcc_subnet_2.id]

  enable_deletion_protection = false

}

resource "aws_lb_target_group" "rcc-tg" {
  name        = "resistor-color-code-lb-tg"
  target_type = "ip"
  port        = 5001
  protocol    = "HTTP"
  vpc_id      = aws_vpc.rcc_vpc.id
}

resource "aws_lb_listener" "rcc-listener" {
  load_balancer_arn = aws_lb.rcc-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rcc-tg.arn
  }
}
