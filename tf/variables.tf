variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "us-west-2"
}
variable "bucket_prefix" {
  type        = string
  description = "The prefix for the S3 bucket"
  default     = "crc-website"
}
variable "domain_name" {
  type        = string
  description = "The domain name to use"
  default     = "musing-brian.com"
}