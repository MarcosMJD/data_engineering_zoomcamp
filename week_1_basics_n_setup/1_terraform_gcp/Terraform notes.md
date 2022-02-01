## Download Terraform binary (Windows version) 
https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_windows_amd64.zip

## Download and install GCP SDK for Windows

https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe
It adds binary path to PATH environment variable.
Test with gcloud -v
If it does not work:
  Add to PATH 
  C:\Users\MARCOS\AppData\Local\Google\Cloud SDK\google-cloud-sdk\bin
  And also set CLOUDSDK_PYTHON=~/Anaconda3/python or any other python installation dir

## Create a new project in GCP

  When creating a project, use a project id that is unique, edit it since it can not be modified later on.

## Create a service account
Sercice account authorize applications to perform authotisez API calls. They are not user accounts of Google Workspace Domain
  IAM -> Service accounts
    Add one
    Add Viewer role
    No need to add multiple users (I gess that are users within the organization with a GCP account (Google Workspace Domain?))
    Actions -> Manage Keys -> Create new keys, copy the url (actually download the json)
    Save the json in a safe directory...i.e. .. .\gcp\...json
    set GOOGLE_APPLICATION_CREDENTIALS=C:\Users\MARCOS\.google\credentials\dtc-ne-5b655c8dee4a.json
    Run to authenticate the application accessing google cloud service account (i.e. GCP SDK)
    gcloud auth application-default login
      Do the oauth stuff

  Note: It is possible to authenticate without oauth (gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS)

## Set up permissions for GCS y Big Query

Google Cloud Storage GCS (Data Lake). It is a bucket with data stored as flat files (csv, jsons, parket files).
BigQuery (data wharehouse)

Add permissions to the service account:
IAM & Admin -> IAM -> Edit principal
Storage Admin (Create "bucket")
Storage Object Admin (Manmage objects in "bucket")
BigQuery ADmin

Note: In production environment, new custom roles are made with specific permissions. i.e. Terraform with admin, but data pipelines with those specific (more restricted)

## Enable APIS for the SDK to communicate though IAM
https://console.cloud.google.com/apis/library/iam.googleapis.com
https://console.cloud.google.com/apis/library/iamcredentials.googleapis.com

## Create Terraform config files

terraform-version
main.tf
  backend is where the tf state file will be stores, can be local, gcs bucket, aws s3...
variables.tf
  Note that project degault is dtc-gcp-339512. If this is not set, when executing commands, terraform will ask for the project id

## Run terraform

terraform init
  Gets plugins (for GCP provider) and sets tf status file
terraform plan
  Important: Use git bash. Command with set env variable does not find the file
  export GOOGLE_APPLICATION_CREDENTIALS="c:/Users/Marcos/.google/credentials/dtc-ne-5b655c8dee4a.json
  ./terraform.exe plan

  "plan" command compares the status with the config files to see the changes to be applied

terraform apply (changes)

google_bigquery_dataset.dataset: Creating...
google_storage_bucket.data-lake-bucket: Creating...
google_storage_bucket.data-lake-bucket: Creation complete after 1s [id=dtc_data_lake_dtc-gcp-339512]
google_bigquery_dataset.dataset: Creation complete after 2s [id=projects/dtc-gcp-339512/datasets/trips_data_all]


IMPORTANT USE PROJECT ID NOT PROJECT NAME!!!
i.e. dtc-gcp-339512

terraform destroy

After destroy the state file still has the latest configuration, so running again will setup the environment (I guess that storage is deleted with destroy)



