variable "environment" {
  
}

variable "managed_by" {
  
}

variable "table_name" {
  
}

resource "aws_dynamodb_table" "table" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "N"
  }

  tags = {
    name        = var.table_name
    environment = var.environment
    managed_by  = var.managed_by
  }
}