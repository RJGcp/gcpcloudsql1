variable "project_id" {
  type        = string
  default     = "rjbakup1"
}

variable "project_id_2" {
  type        = string
  default     = "omega-ether-256603"
}

variable "bucket_name" {
  type        = string
  default     = "rjbkpd"
}

variable "gcp_region" {
  type = string
  default = "asia-south1"
}

variable "instance_name" {
  type = string
  default = "rjbackup"
}

variable "instance_name_2" {
  type = string
  default = "rjbackup"
}

variable "backupRetention" {
    type = string
    default = "1"
}

variable "stagBackupRetention" {
    type = string
    default = "2"
}

variable "role" {
  type = string 
  default = "projects/rjbakup1/roles/sqlBackupCreator"
}
variable "role_1" {
  type = string 
  default = "projects/omega-ether-256603/roles/sqlBackupCreator"
}