output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.lambda_cocus.function_name
}

output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."

  value = aws_s3_bucket.lambda_s3_bucket.id
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda.invoke_url
}

# output "lambda_layer_prettytable_arn" {
#   description = "The Amazon Resource Name (ARN) of the Lambda Layer with version."

#   value = aws_lambda_layer_version.lambda_layer_prettytable.arn
# }

# output "lambda_layer_dotenv_arn" {
#   description = "The Amazon Resource Name (ARN) of the Lambda Layer with version."

#   value = aws_lambda_layer_version.lambda_layer_dotenv.arn
# }
