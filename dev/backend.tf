terraform {
 backend "s3" {
   bucket = "tf-trash" 
   key    = "tfstatefile"
   region = "us-east-1"
 }
}
#Destroyed today
