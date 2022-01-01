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

resource "aws_iam_policy" "dynamo" {
  name        = format("lambda-%s-dynamo-policy", var.context)
  description = "IAM policy para acesso a DynamoDB"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:*"
        ],
        "Resource" : [
          "arn:aws:dynamodb:${var.aws_region}:*:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.dynamo.arn
}
