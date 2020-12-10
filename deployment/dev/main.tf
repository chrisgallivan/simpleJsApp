############################################################
##### Provider Configuration ##############################
###########################################################


provider "aws" {
   region = "us-east-2"
   access_key = var.deployment_username
   secret_key = var.deployment_password
}



###########################################################
##### Provided by App Team ################################
###########################################################

 resource aws_lambda_function "apollo13-hello-world" {
  s3_bucket= aws_s3_bucket.mybucket123.bucket
  s3_key    = aws_s3_bucket_object.object.key
  source_code_hash = filebase64sha256(var.local_artifact_location)
  #fill in the remaining required attributes
  function_name      = "apollo13-hello-world"       
  description        = "Our Demo Lambda"
  handler            = "index.hello"
  runtime            = "nodejs12.x"
  role           = "arn:aws:iam::501628865135:role/bronco"
 }

 resource "aws_api_gateway_rest_api" "apollo13-hello-world" {
  name        = "Apollo13ServerlessExample"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.apollo13-hello-world.id
   parent_id   = aws_api_gateway_rest_api.apollo13-hello-world.root_resource_id
   path_part   = "{proxy+}"
}
resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.apollo13-hello-world.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "ANY"
   authorization = "NONE"
 }
 resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.apollo13-hello-world.id
   resource_id = aws_api_gateway_method.proxy.resource_id
   http_method = aws_api_gateway_method.proxy.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.apollo13-hello-world.invoke_arn
 }
 resource "aws_api_gateway_method" "proxy_root" {
   rest_api_id   = aws_api_gateway_rest_api.apollo13-hello-world.id
   resource_id   = aws_api_gateway_rest_api.apollo13-hello-world.root_resource_id
   http_method   = "ANY"
   authorization = "NONE"
 }
 resource "aws_api_gateway_integration" "lambda_root" {
   rest_api_id = aws_api_gateway_rest_api.apollo13-hello-world.id
   resource_id = aws_api_gateway_method.proxy_root.resource_id
   http_method = aws_api_gateway_method.proxy_root.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.apollo13-hello-world.invoke_arn
 }
 resource "aws_api_gateway_deployment" "apollo13-hello-world" {
   depends_on = [
     aws_api_gateway_integration.lambda,
     aws_api_gateway_integration.lambda_root,
   ]

   rest_api_id = aws_api_gateway_rest_api.apollo13-hello-world.id
   stage_name  = "test"
 }
 resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.apollo13-hello-world.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.apollo13-hello-world.execution_arn}/*/*"
 }

 output "base_url" {
  value = aws_api_gateway_deployment.apollo13-hello-world.invoke_url
}

resource "aws_s3_bucket" "mybucket123" {
  bucket = "chris-gallivan-usa"
  acl    = "private"
  
   versioning {
    enabled = true
  }
  
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.mybucket123.bucket
  key    = "my_object_key"
  source = var.local_artifact_location

   }
