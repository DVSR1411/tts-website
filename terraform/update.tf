resource "null_resource" "update_api" {
  provisioner "local-exec" {
    command = <<EOF
    url="${aws_api_gateway_stage.api_stage.invoke_url}/test"
    file="${path.module}/../frontend/script.js"
    sed -i "s|MyAPI|$url|g" "$file"
    echo "API URL updated"
    EOF
  }
  depends_on = [
    aws_api_gateway_deployment.api_deployment,
    aws_api_gateway_stage.api_stage
  ]
}
