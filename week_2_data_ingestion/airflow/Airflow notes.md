Airflow notes

Create .wslconfig under home directory

[wsl2]
memory=20GB # Limits VM memory in WSL 2 
processors=4 # Makes the WSL 2 VM use 4 virtual processors

Restart wsl with powershell
  Restart-Service LxssManager


Use git bash by default

Create airflow directory
download with wget the official yaml file
curl -LfO https://airflow.apache.org/docs/apache-airflow/stable/docker-compose.yaml

Set AIRFLOW__CORE__LOAD_EXAMPLES: 'false' to avoid creation of examples in the airflow web console

Create subdirs
mkdir -p ./dags ./logs ./plugins

Set env variables for the yaml file
AIRFLOW_UID tells which user so that related files under those dirs will be created by the user and not the root user. Note: User group shall be set to 0.
So by doing this, user and group ids in these directories and the folders in the containers.

In bash: 
echo -e "AIRFLOW_UID=$(id -u)" > .env
  AIRFLOW_UID=197610

Note: running id ->  uid=197610(MARCOS) gid=197121 groups=197121
Note -e is enable backslash

In  Windows command shell just MARCOS?
Is it needed to set group id to 0 in Windows, seems to do not need... check yaml file, initialization section:

echo -e "\033[1;33mWARNING!!!: AIRFLOW_UID not set!\e[0m"
          echo "If you are on Linux, you SHOULD follow the instructions below to set "
          echo "AIRFLOW_UID environment variable, otherwise files will be owned by root."
          echo "For other operating systems you can get rid of the warning with manually created .env file:"
          echo "    See: https://airflow.apache.org/docs/apache-airflow/stable/start/docker.html#setting-the-right-airflow-user"

Also works by setting the variable directly (no .env) with export or in the yaml file

Befor runnnig docker compose we must build out custom base image of airflow.
This will include google cloud sdk, install requirements.txt python libs (google client for airflow and pyarrow to work with parquet files) and also set the USER id previously created.

Modify yaml file: Comment image and uncomment build and add...
 # image: ${AIRFLOW_IMAGE_NAME:-apache/airflow:2.2.3}
  build:
    context: .
    dockerfile: ./Dockerfile

Set google credentials vars
GOOGLE_APPLICATION_CREDENTIALS: /.google/credentials/google_credentials.json
    AIRFLOW_CONN_GOOGLE_CLOUD_DEFAULT: 'google-cloud-platform://?extra__google_cloud_platform__key_path=/.google/credentials/google_credentials.json'
    GCP_PROJECT_ID: 'pivotal-surfer-336713'
    GCP_GCS_BUCKET: "dtc_data_lake_pivotal-surfer-336713"
  Change project id, etc.
Use own project id and bucket id created with Terraform

And volume for credentials as read only
   - ~/.google/credentials/:/.google/credentials:ro

For that we need Dockerfile and run
docker build .
or better docker-compose build to build images: 
airflow_airflow-init
airflow_airflow-scheduler
airflow_airflow-triggerer
airflow_airflow-webserver
airflow_airflow-worker
airflow_flower
Then 
docker-compose up airflow-init.
This will cause creating redis and posgres images and run the three services as containers. Than init service will exited
Then run docker-compose up to run or recreate? all services

Use docker-compose ps to check which services are up.

Then, open browser at localhost:8888
Login with ariflow:airflow
Dags should be there

Dags

Dags can be used as context manager (with DAG), a regular constructor that can be passed to other functions, or a bash decorator to turn a funcion into a dag generator
Tasks are added as operators, sensors (wait for an external event to happen) or task flows (are actually decorators for a custom python function to be packed as a task). These are subclasses of BaseOperator.
There are operators from official providers (to create a big query table) or customs python operators.
Bash operator, python operator, operators from official providers.
Dependencies are done with >>
Tasks in a dag may run in different workers or different machines, so there are mechanisms to setup access to a data resource (connections, hooks or pools)
States of a task: normally none->scheduled>queued>running>success

Note: AIRFLOW_HOME=/opt/airflow is set in Dockerfile and hence used in all images inherited from x-airflow-common
Note: The name of the dataset is trips_data_all when creating with terraform. The id is id=projects/dtc-gcp-339512/datasets/trips_data_all
however, in the dag file we use 
BIGQUERY_DATASET = os.environ.get("BIGQUERY_DATASET", 'trips_data_all')
 "tableReference": {
                "projectId": PROJECT_ID,
                "datasetId": BIGQUERY_DATASET,
                "tableId": "external_table",
So project id and dataset id are separated.    

NOte: "Cloud composer for airflow would save the .csv file in memory"

BigQueryCreateExternalTableOperator extracts the schema from the parquet file and creates the table


INGEST TO LOCAL POSTGRES
Modify yaml to a new one -> docker-compose-local.yaml
Then change the mapping of the dags volume
    - ./dags_local:/opt/airflow/dags
    - Set to use Dockerfile-local
    - Comment google vars
Remember to create the .env file for the userid (if in Linux?)
Modify Dockerfile -> Dockerfile-local and comment references to google sdk etc.
Same for requirements local

docker-compose -f ./docker-compose-local.yaml build
  This will create the images (overwritting the old ones)
docker-compose -f docker-compose-local.yaml up   
  This will initialize, , with no more new containers. Seems that docker-compose updates the old ones?
docker-compose -f ./docker-compose-local.yaml up airflow-init
  This will finally run, with no more new containers.
docker-compose -f ./dock.... up


NOte
Airflow does not include wget command, so in the Dockerfile we can add apt-get wget and remake the instances.
curl ... L flag means follow redirects. It is useful

WIth docker ps, we can know the id of the worker
docker exec -it 7ce56d6764bc bash
to run a bash on it
For some reason with git bash does not work, with command does

Use less or more commands to check the file

Check Jinja template {{}} for the generation of the csv filename for the download. Also execution_date var 

We could run the docketized ingestion script inside the airflow docker, docker inside docker, but it is more complex
Check towardsdatascience/using-apache-airflow-dockoperator-with-docker-compose-57d0217c8219

Note
pip install --no-cache-dir  means no cache and will make small images.

In order to run the ingest script, we must pass the posgresql local database.
We edit .env to add
PG_HOST=pgdatabase
PG_USER=root
PG_PASSWORD=root
PG_PORT=5432
PG_DATABASE=ny_taxi

And the .yaml local to make use of them when making images

    PG_HOST: "${PG_HOST}"
    PG_USER: "${PG_USER}"
    PG_PASSWORD: "${PG_PASSWORD}"
    PG_PORT: "${PG_PORT}"
    PG_DATABASE: "${PG_DATABASE}"  

This is only needed in the worker, we put then there

Delete trips table from local ny_taxi database. Run the .yaml file and use pgadmin

To connect the local posgres network to the airflow, we modify the docker-compose.yaml of the local network.
But as new filename
docker-compose-airflow-connection.yaml


and in pgdatabase service add
newtworks:
  - airflow
To run the pgdatabase in the airflow network

And this is the actual connection
networks:
  airflow:
    external:
      name: airflow_default

Also check pgadmin dedirects to 8085 otherwise will conflit with airflow webserver

Note that postgres in airflow yaml does not expose ports outside the network.
But local postgres does.
Both in the same network.No problem with two postgres in the same network with same ports.
For example, pgadmin when setting the server we use the container name and port.

Note: Docker-compose uses the directory name as the name of the network. All containers in the same yaml are in the network.
Note: Docker runs a container in a specific network with the parameter -network. 

All tasks shall be idempotent
In case it fails and is retried, the result is the same. For example, if the ingestion fails and retries, since the table is replaced if already exists, it is idempotent.

Fix the exception in ingest script with try catch to avoid failure in airflow task execution.

Mount ./data volume in ./opt/airflow/data and use it to dowload the files and create the files. After that, we can delete the files locally
Just add a       TEMP_STORAGE_PATH: /opt/airflow/data   env var in the worker and use it in the data_ingestion_local script
No need for ""
Will have to rebuild the containers.

Homework

Just modify the scripts to create a docker-compose yaml, Dockerfile and requirements for the homework
Modify gcs yellow dag ingestion with start, end dates     "start_date": datetime(2019,1,1),     "end_date": datetime(2020,12,3), and 
schedule_interval="0 6 2 * *",

Make similar scripts for fhv and zones

To test xcom, it is needed to add         provide_context=True, when creating the tasks from PythonOperators. 
Then the functions called will have def upload_to_gcs(bucket, object_name, **kwargs):
From kwargs we get the "ti" parameter, the task object from to call xcom to send the messages or get them

Dag auto discover 

This is how the default Airflow setup is configured. If you go into your webserver container, something like docker exec -it dtc-de_webserver_1 bash
and then look into the contents of
airflow.cfg file, you’ll find the below block somewhere:
# Number of seconds after which a DAG file is parsed. The DAG file is parsed every
# ``min_file_process_interval`` number of seconds. Updates to DAGs are reflected after
# this interval. Keeping this number low will increase CPU usage.
min_file_process_interval = 30

# How often (in seconds) to scan the DAGs directory for new files. Default to 5 minutes.
dag_dir_list_interval = 300



