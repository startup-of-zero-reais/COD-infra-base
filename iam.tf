resource "aws_iam_role" "this" {
  name = format("lambda-%s-role", var.context)

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = format("%s-%s", var.context, var.environment)
  })
}
