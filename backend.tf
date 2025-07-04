terraform {
 backend "s3" {
   bucket = "tf-backend-trash" 
   key    = "tfstatefile"
   region = "us-east-1"
 }
}