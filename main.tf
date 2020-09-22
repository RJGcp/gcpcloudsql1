locals {
  services_to_enable = [
    "cloudscheduler.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}
locals {
    project_id = [
      "rjbakup1",
      "omega-ether-256603"
    ]
}

resource "google_project_service" "service" {
  for_each  = toset(local.services_to_enable)
  project   = var.project_id
  service   = each.value
}

resource "google_project_service" "service1" {
  for_each  = toset(local.services_to_enable)
  project   = var.project_id_2
  service   = each.value
}

data "archive_file" "backup_trigger_zip" {
  type        = "zip"
  source_dir  = "${path.module}/backup-trigger"
  output_path = "${path.module}/backup_trigger.zip"
}

resource "google_storage_bucket" "cloud_function_bucket" {
  name     = var.bucket_name
  project  = var.project_id
  location = var.gcp_region
}

resource "google_storage_bucket_object" "backup_trigger_zip" {
  name   = "backup_trigger.zip"
  bucket = google_storage_bucket.cloud_function_bucket.name
  source = "${path.module}/backup_trigger.zip"
}

resource "google_pubsub_topic" "function_pub_sub" {
  project = var.project_id
  name    = "my-database-backup-topic"
}

resource "google_project_iam_custom_role" "custom_role" {
  for_each    = toset(local.project_id)
  project     = each.value
  role_id     = "sqlBackupCreator"
  title       = "sqlBackupCreator"
  description = "Roles for cloud functions to trigger manual backups"
  permissions = ["cloudsql.backupRuns.create", "cloudsql.backupRuns.get", "cloudsql.backupRuns.list", "cloudsql.backupRuns.delete"]
}

resource "google_service_account" "backup_trigger" {
  project      = var.project_id
  account_id   = "backup"
  display_name = "backup_trigger_cloud_function_sa"
}
resource "google_project_iam_member" "backup_trigger" {
  provider = google-beta
  project  = var.project_id
  member   = "serviceAccount:${google_service_account.backup_trigger.email}"
  role     = var.role
}

resource "google_service_account" "backup_trigger_1" {
  project      = var.project_id_2
  account_id   = "backup"
  display_name = "backup_trigger_cloud_function_sa"
}
resource "google_project_iam_member" "backup_trigger_1" {
  provider = google-beta
  project  = var.project_id_2
  member   = "serviceAccount:${google_service_account.backup_trigger.email}"
  role     = var.role_1
}

# resource "google_app_engine_application" "app" {
#  project     = var.project_id
#  location_id = "asia-south1"
# }

resource "google_cloudfunctions_function" "backup_trigger_function" {
  name                  = "backup-trigger-function"
  region                = var.gcp_region
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.cloud_function_bucket.name
  source_archive_object = "backup_trigger.zip"
  entry_point           = "backup"
  runtime               = "nodejs8"
  project               =  var.project_id
  service_account_email = google_service_account.backup_trigger.email

  environment_variables = {
    PROJECT_ID    = var.project_id
    PROJECT_ID_1  = var.project_id_2
    INSTANCE_NAME = var.instance_name
    INSTANCE_NAME_2 = var.instance_name_2
    backupRetention  = var.backupRetention
    stagBackupRetention = var.stagBackupRetention
  }

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = "projects/${var.project_id}/topics/${google_pubsub_topic.function_pub_sub.name}"
    failure_policy {
      retry = false
    }
  }
}


resource "google_cloud_scheduler_job" "cloud_function_trigger" {
  name     = "my-cloud-function-trigger"
  schedule = "0 1 * * *"
  project  = var.project_id
  region   = var.gcp_region

  pubsub_target {
    topic_name = "projects/${var.project_id}/topics/${google_pubsub_topic.function_pub_sub.name}"
    data       = base64encode("{project1: rjbakup1, database1: rjbackup, backupRetention: 1,stagBackupRetention: 2,project: omega-ether-256603, database: rjbackup}")
  }
# depends_on = [google_app_engine_application.app]
}

