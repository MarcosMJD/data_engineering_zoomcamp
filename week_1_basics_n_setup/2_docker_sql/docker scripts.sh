## Run Postgresql

docker run -it  \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v /D/L/DataTalks/data_engineering_zoomcamp/week_1_basics_n_setup/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:13

## Problem, with gitbash it creates ny_taxi_postgres_data;C folder ¿...?
## Running the same with cmd works

docker run -it   -e POSTGRES_USER="root"  -e POSTGRES_PASSWORD="root"   -e POSTGRES_DB="ny_taxi"  -v /D/L/DataTalks/data_engineering_zoomcamp/week_1_basics_n_setup/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data -p 5432:5432   postgres:13  

#Run Pgadmin

docker run -it -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" -e PGADMIN_DEFAULT_PASSWORD="root" -p 8085:80 dpage/pgadmin4

## Network for pgadmin and postgresql connection

docker network create pg-network

docker run -it  \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v /D/L/DataTalks/data_engineering_zoomcamp/week_1_basics_n_setup/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  --network=pg-network \
  --name = pg-database \
  postgres:13

  docker run -it -e POSTGRES_USER="root"  -e POSTGRES_PASSWORD="root"   -e POSTGRES_DB="ny_taxi"  -v /D/L/DataTalks/data_engineering_zoomcamp/week_1_basics_n_setup/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data -p 5432:5432  --network=pg-network --name=pg-database  postgres:13
  docker run -it -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" -e PGADMIN_DEFAULT_PASSWORD="root" -p 8085:80 --network=pg-network --name=pgadmin  dpage/pgadmin4


## Run Ingest data python script in localhost (no docker)
python ingest_data.py --user=root --password=root --host=localhost --port=5432 --db=ny_taxi --table_name=yellow_taxi_trips --url='https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.csv'

## Create image
## Using Dockerfile in the same directory
docker build -t taxi_ingest:v001 . 

## Run image to ingest data
docker run -it --network=pg-network taxi_ingest:v001 --user=root --password=root --host=pg-database --port=5432 --db=ny_taxi --table_name=yellow_taxi_trips --url=https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.csv

## With docker-compose
## Check docker-compose.yaml
## -d is detached mode to continue with terminal
docker-compose up -d

#Note to clear containers and caches:
docker-compose down --volumes --rmi all
or also 
docker-compose down -v --rmi all --remove-orphans
