resource "aws_cloudwatch_log_group" "main" {
  name              = "/shopflow/application"
  retention_in_days = 7
}

resource "aws_sns_topic" "alerts" {
  name = "shopflow-alerts"
}