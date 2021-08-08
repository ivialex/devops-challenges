resource "random_pet" "lambda_bucket_name" {
  prefix = "lambda-cocus"
  length = 2
}

resource "aws_s3_bucket" "lambda_s3_bucket" {
  bucket = random_pet.lambda_bucket_name.id

  acl           = "private"
  force_destroy = true
}
data "archive_file" "lambda_layer_prettytable" {
  type = "zip"

  source_dir  = "${path.module}/lambda_layer/lambda_layer_prettytable"
  output_path = "${path.module}/lambda_layer/lambda_layer_prettytable_payload.zip"
}

resource "aws_s3_bucket_object" "lambda_layer_prettytable_object" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id

  key    = "lambda_layer_prettytable_payload.zip"
  source = data.archive_file.lambda_layer_prettytable.output_path

  etag = filemd5(data.archive_file.lambda_layer_prettytable.output_path)
}

data "archive_file" "lambda_layer_dotenv" {
  type = "zip"

  source_dir  = "${path.module}/lambda_layer/lambda_layer_dotenv"
  output_path = "${path.module}/lambda_layer/lambda_layer_dotenv_payload.zip"
}

resource "aws_s3_bucket_object" "lambda_layer_dotenv_object" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id

  key    = "lambda_layer_dotenv_payload.zip"
  source = data.archive_file.lambda_layer_dotenv.output_path

  etag = filemd5(data.archive_file.lambda_layer_dotenv.output_path)
}

data "archive_file" "lambda_layer_wcwidth" {
  type = "zip"

  source_dir  = "${path.module}/lambda_layer/lambda_layer_wcwidth"
  output_path = "${path.module}/lambda_layer/lambda_layer_wcwidth_payload.zip"
}

resource "aws_s3_bucket_object" "lambda_layer_wcwidth_object" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id

  key    = "lambda_layer_wcwidth_payload.zip"
  source = data.archive_file.lambda_layer_wcwidth.output_path

  etag = filemd5(data.archive_file.lambda_layer_wcwidth.output_path)
}

data "archive_file" "lambda_cocus" {
  type = "zip"

  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_cocus.zip"
}

resource "aws_s3_bucket_object" "lambda_s3_bucket_object" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id

  key    = "lambda_cocus.zip"
  source = data.archive_file.lambda_cocus.output_path

  etag = filemd5(data.archive_file.lambda_cocus.output_path)
}

resource "aws_lambda_layer_version" "lambda_layer_prettytable" {
  layer_name = "lambda_layer_prettytable"

  s3_bucket = aws_s3_bucket.lambda_s3_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_layer_prettytable_object.key

  compatible_runtimes = ["python3.8"]

  source_code_hash = data.archive_file.lambda_layer_prettytable.output_base64sha256
}

resource "aws_lambda_layer_version" "lambda_layer_dotenv" {
  layer_name = "lambda_layer_dotenv"

  s3_bucket = aws_s3_bucket.lambda_s3_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_layer_dotenv_object.key

  compatible_runtimes = ["python3.8"]

  source_code_hash = data.archive_file.lambda_layer_dotenv.output_base64sha256
}

resource "aws_lambda_layer_version" "lambda_layer_wcwidth" {
  layer_name = "lambda_layer_wcwidth"

  s3_bucket = aws_s3_bucket.lambda_s3_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_layer_wcwidth_object.key

  compatible_runtimes = ["python3.8"]

  source_code_hash = data.archive_file.lambda_layer_wcwidth.output_base64sha256
}

resource "aws_lambda_function" "lambda_cocus" {
  function_name = "lambda-cocus-challenge-ivialex"

  s3_bucket = aws_s3_bucket.lambda_s3_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_s3_bucket_object.key

  runtime = "python3.8"
  handler = "main.lambda_handler" #lambda_function

  source_code_hash = data.archive_file.lambda_cocus.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  layers = [aws_lambda_layer_version.lambda_layer_prettytable.arn, 
            aws_lambda_layer_version.lambda_layer_dotenv.arn,
            aws_lambda_layer_version.lambda_layer_wcwidth.arn]
  
  environment {
    variables = {
      KEY_ID = var.aws_access_key,
      SECRET_KEY = var.aws_secret_key,
      REGION_NAME = var.aws_region
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch" {
  name = "/aws/lambda/${aws_lambda_function.lambda_cocus.function_name}"

  retention_in_days = 30
}
