## Week 1 Homework

In this homework we'll prepare the environment 
and practice with terraform and SQL

## Question 1. Google Cloud SDK

Install Google Cloud SDK. What's the version you have? 

To get the version, run `gcloud --version`

```
Google Cloud SDK 369.0.0
bq 2.0.72
core 2022.01.14
gsutil 5.6
```

## Google Cloud account 

Create an account in Google Cloud and create a project.


## Question 2. Terraform 

Now install terraform and go to the terraform directory (`week_1_basics_n_setup/1_terraform_gcp/terraform`)

After that, run

* `terraform init`
* `terraform plan`
* `terraform apply` 

Apply the plan and copy the output (after running `apply`) to the form.

It should be the entire output - from the moment you typed `terraform init` to the very end.

```
terraform init

Initializing the backend...

Successfully configured the backend "local"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding latest version of hashicorp/google...
- Installing hashicorp/google v4.8.0...
- Installed hashicorp/google v4.8.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.


terraform plan
var.project
  Your GCP Project ID

  Enter a value: dtc-ne  


Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.dataset will be created
  + resource "google_bigquery_dataset" "dataset" {
      + creation_time              = (known after apply)
      + dataset_id                 = "trips_data_all"
      + delete_contents_on_destroy = false
      + etag                       = (known after apply)
      + id                         = (known after apply)
      + last_modified_time         = (known after apply)
      + location                   = "europe-west6"
      + project                    = "ny-taxi"
      + self_link                  = (known after apply)

      + access {
          + domain         = (known after apply)
          + group_by_email = (known after apply)
          + role           = (known after apply)
          + special_group  = (known after apply)
          + user_by_email  = (known after apply)

          + view {
              + dataset_id = (known after apply)
              + project_id = (known after apply)
              + table_id   = (known after apply)
            }
        }
    }

  # google_storage_bucket.data-lake-bucket will be created
  + resource "google_storage_bucket" "data-lake-bucket" {
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "EUROPE-WEST6"
      + name                        = "dtc_data_lake_ny-taxi"
      + project                     = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + uniform_bucket_level_access = true
      + url                         = (known after apply)

      + lifecycle_rule {
          + action {
              + type = "Delete"
            }

          + condition {
              + age                   = 30
              + matches_storage_class = []
              + with_state            = (known after apply)
            }
        }

      + versioning {
          + enabled = true
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

terraform apply

var.project
  Your GCP Project ID

  Enter a value: dtc-ne


Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.dataset will be created
  + resource "google_bigquery_dataset" "dataset" {
      + creation_time              = (known after apply)
      + dataset_id                 = "trips_data_all"
      + delete_contents_on_destroy = false
      + etag                       = (known after apply)
      + id                         = (known after apply)
      + last_modified_time         = (known after apply)
      + location                   = "europe-west6"
      + project                    = "dtc-ne"
      + self_link                  = (known after apply)

      + access {
          + domain         = (known after apply)
          + group_by_email = (known after apply)
          + role           = (known after apply)
          + special_group  = (known after apply)
          + user_by_email  = (known after apply)

          + view {
              + dataset_id = (known after apply)
              + project_id = (known after apply)
              + table_id   = (known after apply)
            }
        }
    }

  # google_storage_bucket.data-lake-bucket will be created
  + resource "google_storage_bucket" "data-lake-bucket" {
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "EUROPE-WEST6"
      + name                        = "dtc_data_lake_dtc-ne"
      + project                     = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + uniform_bucket_level_access = true
      + url                         = (known after apply)

      + lifecycle_rule {
          + action {
              + type = "Delete"
            }

          + condition {
              + age                   = 30
              + matches_storage_class = []
              + with_state            = (known after apply)
            }
        }

      + versioning {
          + enabled = true
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_bigquery_dataset.dataset: Creating...
google_storage_bucket.data-lake-bucket: Creating...
google_storage_bucket.data-lake-bucket: Creation complete after 1s [id=dtc_data_lake_dtc-ne]
google_bigquery_dataset.dataset: Creation complete after 1s [id=projects/dtc-ne/datasets/trips_data_all]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.


terraform destroy

var.project
  Your GCP Project ID

  Enter a value: dtc-ne

google_bigquery_dataset.dataset: Refreshing state... [id=projects/dtc-ne/datasets/trips_data_all]
google_storage_bucket.data-lake-bucket: Refreshing state... [id=dtc_data_lake_dtc-ne]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # google_bigquery_dataset.dataset will be destroyed
  - resource "google_bigquery_dataset" "dataset" {
      - creation_time                   = 1643040438016 -> null
      - dataset_id                      = "trips_data_all" -> null
      - default_partition_expiration_ms = 0 -> null
      - default_table_expiration_ms     = 0 -> null
      - delete_contents_on_destroy      = false -> null
      - etag                            = "WeTUhY+hHO0wd+SJo0u+mA==" -> null
      - id                              = "projects/dtc-ne/datasets/trips_data_all" -> null
      - labels                          = {} -> null
      - last_modified_time              = 1643040438016 -> null
      - location                        = "europe-west6" -> null
      - project                         = "dtc-ne" -> null
      - self_link                       = "https://bigquery.googleapis.com/bigquery/v2/projects/dtc-ne/datasets/trips_data_all" -> null

      - access {
          - role          = "OWNER" -> null
          - user_by_email = "dtc-de-user@dtc-ne.iam.gserviceaccount.com" -> null
        }
      - access {
          - role          = "OWNER" -> null
          - special_group = "projectOwners" -> null
        }
      - access {
          - role          = "READER" -> null
          - special_group = "projectReaders" -> null
        }
      - access {
          - role          = "WRITER" -> null
          - special_group = "projectWriters" -> null
        }
    }

  # google_storage_bucket.data-lake-bucket will be destroyed
  - resource "google_storage_bucket" "data-lake-bucket" {
      - default_event_based_hold    = false -> null
      - force_destroy               = true -> null
      - id                          = "dtc_data_lake_dtc-ne" -> null
      - labels                      = {} -> null
      - location                    = "EUROPE-WEST6" -> null
      - name                        = "dtc_data_lake_dtc-ne" -> null
      - project                     = "dtc-ne" -> null
      - requester_pays              = false -> null
      - self_link                   = "https://www.googleapis.com/storage/v1/b/dtc_data_lake_dtc-ne" -> null
      - storage_class               = "STANDARD" -> null
      - uniform_bucket_level_access = true -> null
      - url                         = "gs://dtc_data_lake_dtc-ne" -> null

      - lifecycle_rule {
          - action {
              - type = "Delete" -> null
            }

          - condition {
              - age                        = 30 -> null
              - days_since_custom_time     = 0 -> null
              - days_since_noncurrent_time = 0 -> null
              - matches_storage_class      = [] -> null
              - num_newer_versions         = 0 -> null
              - with_state                 = "ANY" -> null
            }
        }

      - versioning {
          - enabled = true -> null
        }
    }

Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

google_storage_bucket.data-lake-bucket: Destroying... [id=dtc_data_lake_dtc-ne]
google_bigquery_dataset.dataset: Destroying... [id=projects/dtc-ne/datasets/trips_data_all]
google_storage_bucket.data-lake-bucket: Destruction complete after 0s
google_bigquery_dataset.dataset: Destruction complete after 1s

Destroy complete! Resources: 2 destroyed.
```

## Prepare Postgres 

Run Postgres and load data as shown in the videos

We'll use the yellow taxi trips from January 2021:

```bash
wget https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.csv
```

You will also need the dataset with zones:

```bash 
wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv
```

Download this data and put it to Postgres

## Question 3. Count records 

How many taxi trips were there on January 15?

Consider only trips that started on January 15.

```
SELECT
	CAST(tpep_pickup_datetime AS DATE) AS start_day,
	COUNT(1)
FROM
	yellow_taxi_data
WHERE CAST(tpep_pickup_datetime AS DATE) = '2021-1-15'
GROUP BY start_day;
```

`"2021-01-15"	53024`

## Question 4. Largest tip for each day

Find the largest tip for each day. 
On which day it was the largest tip in January?

Use the pick up time for your calculations.

(note: it's not a typo, it's "tip", not "trip")

```
SELECT
	CAST(tpep_pickup_datetime AS DATE) AS start_day,
	COUNT(1),
	MAX(tip_amount) as max_tip
FROM
	yellow_taxi_data
GROUP BY start_day
ORDER BY max_tip DESC
LIMIT 1;
```

`"2021-01-20"	49437	1140.44`

```
Check with
SELECT
	CAST(tpep_pickup_datetime AS DATE) AS start_day,
	tip_amount
FROM yellow_taxi_data WHERE CAST(tpep_pickup_datetime AS DATE) = '2021-01-20'
ORDER BY tip_amount DESC;
-- WHERE needs CAST etc, start_day will not work because it is not evaluated yet.
```

## Question 5. Most popular destination

What was the most popular destination for passengers picked up 
in central park on January 14?

Use the pick up time for your calculations.

Enter the zone name (not id). If the zone name is unknown (missing), write "Unknown" 

````
SELECT
	CAST (t.tpep_pickup_datetime AS DATE) AS day,
	zdo."Zone" AS destination,
	COUNT(zdo."Zone") as total
FROM
	yellow_taxi_data t,
	zones zpu,
	zones zdo
WHERE 
	t."PULocationID" = zpu."LocationID" AND
	t."DOLocationID" = zdo."LocationID" AND
	CAST(t.tpep_pickup_datetime AS DATE) = '2021-01-14' AND
	zpu."Zone" = 'Central Park'
GROUP BY CAST (t.tpep_pickup_datetime AS DATE), destination
ORDER BY total DESC
LIMIT 1;
```

`"2021-01-14"	"Upper East Side South"	97`

## Question 6. Most expensive locations

What's the pickup-dropoff pair with the largest 
average price for a ride (calculated based on `total_amount`)?

Enter two zone names separated by a slash

For example:

"Jamaica Bay / Clinton East"

If any of the zone names are unknown (missing), write "Unknown". For example, "Unknown / Clinton East". 

```
SELECT
	CONCAT ( COALESCE(zpu."Zone", 'Unknown'), ' / ', COALESCE(zdo."Zone", 'Unknown')) as trip,
	AVG(t.total_amount) AS average
FROM
	yellow_taxi_data t,
	zones zpu,
	zones zdo
WHERE
	t."PULocationID" = zpu."LocationID" AND
	t."DOLocationID" = zdo."LocationID" 
GROUP BY zdo."Zone", zpu."Zone"
ORDER BY average DESC
```

`"Alphabet City / Unknown"	2292.4`

## Submitting the solutions

* Form for submitting: https://forms.gle/yGQrkgRdVbiFs8Vd7
* You can submit your homework multiple times. In this case, only the last submission will be used. 

Deadline: 24 January, 17:00 CET
