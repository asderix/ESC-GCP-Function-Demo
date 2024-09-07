terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    google = {
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  credentials = file(var.credential_json_path)
  project = var.project_id
  region  = var.region
}

# --- Variables, seperate it in production ---

variable "credential_json_path" {
  description = "File path to the GCP credential JSON file"
  type = string
}

variable "project_id" {
  description = "Id of the GCP project."
  type = string
}

variable "region" {
  description = "GCP region."
  type = string
  default = "europe-west6"
}

variable "bucket_name" {
  description = "GCP bucket name."
  type = string
  default = "esc_cloud_function"
}

variable "function_name" {
  description = "Name of the Cloud function."
  type = string
  default = "explainpersonsim"
}

variable "bin_file_name" {
  description = "Filename of the zip file containing the jar assembly."
  type = string
  default = "EscCloudFunctionsExample.zip"
}

# --- End of variables ---

resource "null_resource" "download_file" {
  provisioner "local-exec" {
    command = "curl -L -o ${var.bin_file_name} https://esc.asderix.com/download/EscCloudFunctionsExample.zip"
  }
}

resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}_${var.bucket_name}"
  location = var.region
}

resource "google_storage_bucket_object" "function_source" {
  name   = var.bin_file_name
  bucket = google_storage_bucket.function_bucket.name
  source = var.bin_file_name
  
  depends_on = [null_resource.download_file]
}

resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  location    = var.region
  build_config {
    runtime      = "java17"
    entry_point  = "example.PersonNameExplanation"
    source {
      storage_source {
        bucket = "${var.project_id}_${var.bucket_name}"
        object = var.bin_file_name
      }
    }
  }

  service_config {
    available_memory = "256M"
    ingress_settings = "ALLOW_ALL"
    max_instance_count = 5
  }
  
  depends_on = [google_storage_bucket_object.function_source]
}

resource "google_cloud_run_service_iam_member" "invoker" {
  project  = google_cloudfunctions2_function.function.project
  location = google_cloudfunctions2_function.function.location
  service  = google_cloudfunctions2_function.function.name
  role     = "roles/run.invoker"
  member   = "allUsers"
  
  depends_on = [google_cloudfunctions2_function.function]
}

output "function_uri" {
  value = "${google_cloudfunctions2_function.function.service_config[0].uri}?nameA=Hanspeter%20Müller&nameB=Hans-Peter%20Müller-Meyer"
}


