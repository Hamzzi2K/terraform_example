# aws_infra/ec2/main.tf
resource "aws_instance" "aws05_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.aws05_public_subnet.id
  security_groups = [
    data.aws_security_group.aws05_ssh_sg.id,
    data.aws_security_group.aws05_http_sg.id
  ]
  # CodeDeploy Agent, Docker 설치(ubuntu)
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y ruby wget
              apt install -y --reinstall ca-certificates
              cd /home/ubuntu
              wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto
              systemctl start codedeploy-agent
              systemctl enable codedeploy-agent
              ${file("${path.module}/user_data/docker-install.sh")}
              EOF
  tags = {
    Name = "${var.prefix}-instance"
  }
}

# 2. Code Deploy Agent, Docker 설치 '동적' 대기
resource "null_resource" "aws05_delay" {
  depends_on = [aws_instance.aws05_instance]

  # 테라폼이 EC2 내부에 접속하기 위한 마스터키 설정
  connection {
    type = "ssh"
    user = "ubuntu"
    # 🚨 윈도우 사용자명과 실제 폴더 경로에 맞춰 수정하십시오. (슬래시 / 사용 필수)
    # 예시: "C:/Users/honggildong/Downloads/aws05-key.pem"
    private_key = file("~/.ssh/aws05-key.pem")
    host        = aws_instance.aws05_instance.public_ip
  }

  # 인스턴스 내부로 들어가서 cloud-init(user_data) 설치가 끝날 때까지만 대기
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to finish...'",
      "cloud-init status --wait",
      "echo 'Ready to bake AMI!'"
    ]
  }
}
# 3. 원본 instance에서 AMI 생성
resource "aws_ami_from_instance" "aws05_ami" {
  name                    = "${var.prefix}-instance-ami"
  source_instance_id      = aws_instance.aws05_instance.id
  snapshot_without_reboot = true
  depends_on              = [null_resource.aws05_delay]
  tags = {
    Name = "${var.prefix}-instance-ami"
  }
}
