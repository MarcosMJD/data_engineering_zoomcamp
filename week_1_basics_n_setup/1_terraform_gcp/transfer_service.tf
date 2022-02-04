# From example https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_transfer_job

# Allows management of a single API service for a Google Cloud Platform project. 
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
# "resource_type" "given resource name"
resource "google_project_service" "storagetransfer" {
  project = var.project
  service = "storagetransfer.googleapis.com"
}

# Use this data source to retrieve Storage Transfer service account for this project
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_transfer_project_service_account
data "google_storage_transfer_project_service_account" "default" {
  project = var.project
}

# Creates a new bucket in Google cloud storage service (GCS). Once a bucket has been created, its location can't be changed.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
# For some reason, resource given name and name parameter can not be the same?
resource "google_storage_bucket" "s3-backup-bucket" {
  name          = "s3-backup-bucket-name"
  storage_class = "STANDARD"
  project       = var.project
  location      = "EU"
}

# Non-authoritative. Updates the IAM policy to grant a role to a new member. Other members for the role for the bucket are preserved.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam
resource "google_storage_bucket_iam_member" "transfer-service-terraform-iam" {
  bucket     = google_storage_bucket.s3-backup-bucket.name
  role       = "roles/storage.admin"
  member     = "serviceAccount:${data.google_storage_transfer_project_service_account.default.email}"
  depends_on = [google_storage_bucket.s3-backup-bucket]
}

# Creates a new Transfer Job in Google Cloud Storage Transfer.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_transfer_job
resource "google_storage_transfer_job" "s3-bucket-transfer-example" {
  description = "Test run 1"
  project     = var.project

  transfer_spec {
    transfer_options {
      delete_objects_unique_in_sink = false #  (Optional) Whether objects that exist only in the sink should be deleted
    }
    aws_s3_data_source {
      bucket_name = "de-engineering-bucket"

      aws_access_key {
        access_key_id     = var.access_key_id # https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html
        secret_access_key = var.aws_secret_key
      }
    }
    gcs_data_sink {
      bucket_name = google_storage_bucket.s3-backup-bucket.name
      path = ""
    }
  }

  schedule {
    schedule_start_date {
      year  = 2022
      month = 02
      day   = 03
    }
    schedule_end_date {
      year  = 2022
      month = 02
      day   = 03
    }
  }

  depends_on = [google_storage_bucket_iam_member.transfer-service-terraform-iam]
}