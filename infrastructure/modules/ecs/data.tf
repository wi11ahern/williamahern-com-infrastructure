# Get ECS Optimized Linux AMI from SSM
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-ami-versions.html
# aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/recommended
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}