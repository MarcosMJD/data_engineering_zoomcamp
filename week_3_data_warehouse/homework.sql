-- Create external fhv table
CREATE OR REPLACE EXTERNAL TABLE `trips_data_all.external_fhv_tripdata`
OPTIONS (
    format = 'PARQUET',
    uris = ['gs://dtc_data_lake_dtc-gcp-339512/raw/fhv_tripdata_2019-*.parquet', 'gs://dtc_data_lake_dtc-gcp-339512/raw/fhv_tripdata_2020-*.parquet']
);

-- Partition by dropoff_datetime
-- Total table size is  2.14 GB
CREATE OR REPLACE TABLE `trips_data_all.fhv_tripdata_partitioned`
PARTITION BY DATE(dropoff_datetime) AS 
SELECT * FROM `trips_data_all.external_fhv_tripdata`;

-- Check partitions: 760 partitions (why if 764 unique values? maybe invalid values are not used). Result in less than 1GB per patition
SELECT table_name, partition_id, total_rows
FROM `trips_data_all.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'fhv_tripdata_partitioned'
ORDER BY total_rows DESC;

-- Clustering by dropoff_datetime
-- DATE(dropoff_datetime) does not work gives error
CREATE OR REPLACE TABLE `trips_data_all.fhv_tripdata_clustered`
CLUSTER BY dropoff_datetime AS 
SELECT * FROM `trips_data_all.external_fhv_tripdata`;

-- Clustered by base
CREATE OR REPLACE TABLE `trips_data_all.fhv_tripdata_clustered_by_base`
CLUSTER BY dispatching_base_num AS 
SELECT * FROM `trips_data_all.external_fhv_tripdata`;

-- PARTITION BY dropoff_datetime and CLUSTER by dispatching_base_num
CREATE OR REPLACE TABLE `trips_data_all.fhv_tripdata_partitioned_do_and_clustered_by_ba`
PARTITION BY DATE(dropoff_datetime)
CLUSTER BY dispatching_base_num AS 
SELECT * FROM `trips_data_all.external_fhv_tripdata`;

--
-- Question 1: What is count for fhv vehicles data for year 2019 *
--

SELECT COUNT(1) FROM `dtc-gcp-339512.trips_data_all.fhv_tripdata_partitioned`
WHERE DATE(pickup_datetime) BETWEEN '2019-01-01' AND '2019-12-31'
-- Query complete (0.6 sec elapsed, 419.4 MB processed)
-- 42084899

--
-- Question 2: How many distinct dispatching_base_num we have in fhv for 2019 *: 792
-- 

SELECT COUNT(DISTINCT (dispatching_base_num)) FROM `dtc-gcp-339512.trips_data_all.fhv_tripdata_partitioned_do_and_clustered_by_ba`
WHERE DATE(pickup_datetime) BETWEEN '2019-01-01' AND '2019-12-31';
-- Query complete (0.5 sec elapsed, 716.3 MB processed): 792

SELECT COUNT(DISTINCT (dispatching_base_num)) FROM `dtc-gcp-339512.trips_data_all.fhv_tripdata_partitioned`
WHERE DATE(pickup_datetime) BETWEEN '2019-01-01' AND '2019-12-31';
-- Query complete (0.6 sec elapsed, 842.6 MB processed): 792

--
-- Question 3: Best strategy to optimise if query always filter by dropoff_datetime and order by dispatching_base_num *
-- 
-- Partition by dropoff_datetime <- Even if the partitions are less than 1GB in size
-- Partition by dispatching_base_num
-- Partition by dropoff_datetime and cluster by dispatching_base_num
-- Partition by dispatching_base_num and cluster by dropoff_datetime

-- Get number of unique dispatching_base_num: 880
SELECT COUNT(DISTINCT (dispatching_base_num)) FROM trips_data_all.external_fhv_tripdata;
-- Get number of unique DATE(dropoff_datetime) 764
SELECT COUNT(DISTINCT (DATE(dropoff_datetime))) FROM trips_data_all.external_fhv_tripdata;

-- PARTITION VS CLUSTERING ON DROPOFF_DATETIME
-- BETTER PARTITION ALTHOUG SMALL PARTITIONS (<1GB). TOTAL 760 PARTITIONS

-- Query filter by dropoff_datetime and order by dispatching_base_num - partitioned
-- Query complete (0.9 sec elapsed, 1.3 MB processed)
SELECT * FROM `dtc-gcp-339512.trips_data_all.fhv_tripdata_partitioned`
WHERE DATE(dropoff_datetime) = '2019-03-02'
ORDER BY dispatching_base_num;

-- Clustered by dropoff
SELECT * FROM trips_data_all.fhv_tripdata_clustered
WHERE DATE(dropoff_datetime) = '2019-03-02'
ORDER BY dispatching_base_num;
-- Query complete (0.8 sec elapsed, 29.5 MB processed)

-- PARTITION VS CLUSTERING ON dispatching_base_num

-- Partition by dispatching_base_num not possible, since it is string type.

-- Clustering by dispatching_base_num

SELECT * FROM trips_data_all.fhv_tripdata_clustered_by_base
WHERE DATE(dropoff_datetime) IN ('2019-01-02','2019-01-12','2019-01-22')
ORDER BY dispatching_base_num;
-- Query complete (3.9 sec elapsed, 2.1 GB processed) Note, table is 2.14BG in size

SELECT * FROM trips_data_all.fhv_tripdata_partitioned
WHERE DATE(dropoff_datetime) IN ('2019-01-02','2019-01-12','2019-01-22')
ORDER BY dispatching_base_num;
-- Query complete (1.6 sec elapsed, 21.7 MB processed)

-- HUGE DIFFERENCE when using partitioned vs clustered. Note that no aggregation function or several columns are used.


-- PARTITION VS PARTITION PLUS CLUSTERING when aggregating and filtering
-- Not much difference. Maybe depends on the type of query and due to the small size of the table. In question 4 another query makes the difference.

SELECT dispatching_base_num, COUNT(dispatching_base_num) FROM trips_data_all.fhv_tripdata_partitioned_do_and_clustered_by_ba
WHERE DATE(dropoff_datetime) B= '2019-03-02'
GROUP BY dispatching_base_num
ORDER BY dispatching_base_num;
-- Query complete (0.4 sec elapsed, 550.2 KB processed)
SELECT dispatching_base_num, COUNT(dispatching_base_num) FROM trips_data_all.fhv_tripdata_partitioned
WHERE DATE(dropoff_datetime) = '2019-03-02'
GROUP BY dispatching_base_num
ORDER BY dispatching_base_num;
-- Query complete (0.3 sec elapsed, 550.2 KB processed)

SELECT dispatching_base_num, COUNT(dispatching_base_num) FROM trips_data_all.fhv_tripdata_partitioned_do_and_clustered_by_ba
WHERE DATE(dropoff_datetime) BETWEEN '2019-03-02' AND '2020-06-01'
GROUP BY dispatching_base_num
ORDER BY dispatching_base_num;
-- Query complete (0.5 sec elapsed, 335.6 MB processed)

SELECT dispatching_base_num, COUNT(dispatching_base_num) FROM trips_data_all.fhv_tripdata_partitioned
WHERE DATE(dropoff_datetime) BETWEEN '2019-03-02' AND '2020-06-01'
GROUP BY dispatching_base_num
ORDER BY dispatching_base_num;
-- Query complete (0.5 sec elapsed, 335.6 MB processed)

-- 
-- Question 4: What is the count, estimated and actual data processed for query which counts trip between 2019/01/01 and 2019/03/31 
-- for dispatching_base_num B00987, B02060, B02279 *
-- 

SELECT COUNT(1)
FROM `dtc-gcp-339512.trips_data_all.fhv_tripdata_partitioned`
WHERE DATE(dropoff_datetime) BETWEEN '2019-01-01' AND '2019-03-31' 
AND dispatching_base_num IN ('B00987', 'B02060', 'B02279');
-- Query complete (0.4 sec elapsed, 400.1 MB processed) : 26643

SELECT COUNT(1)
FROM `dtc-gcp-339512.trips_data_all.fhv_tripdata_partitioned_do_and_clustered_by_ba`
WHERE DATE(dropoff_datetime) BETWEEN '2019-01-01' AND '2019-03-31' 
AND dispatching_base_num IN ('B00987', 'B02060', 'B02279');

-- Query complete (0.4 sec elapsed, 163.9 MB processed)

-- 
-- Question 5: What will be the best partitioning or clustering strategy when filtering on dispatching_base_num and SR_Flag *
-- Partition by dispatching_base_num and cluster by SR_Flag
-- Partition by SR_Flag and cluster by dispatching_base_num <-
-- Cluster by dispatching_base_num and SR_Flag
-- Partition by dispatching_base_num and SR_Flag
--

-- Partition by base is not possible (STRING). By SR_Flag is ok

SELECT COUNT(DISTINCT(SR_Flag)) from trips_data_all.external_fhv_tripdata;
SELECT SR_Flag, COUNT(SR_Flag) from trips_data_all.external_fhv_tripdata
GROUP BY SR_Flag;
-- 43 partitions from 2.14GB
-- Total data per SR_Flag value from 0 to 2369823 (SR_Flag = 1). Very different sizes

SELECT COUNT(DISTINCT(SR_Flag)) from trips_data_all.external_fhv_tripdata;
SELECT MAX(SR_Flag), MIN(SR_Flag) from trips_data_all.external_fhv_tripdata;
-- 1 to 43, 

CREATE OR REPLACE TABLE `trips_data_all.fhv_tripdata_partitioned_flag_and_clustered_by_ba`
PARTITION BY RANGE_BUCKET(SR_Flag, GENERATE_ARRAY(1, 43, 1))  
CLUSTER BY dispatching_base_num AS 
SELECT * FROM `trips_data_all.external_fhv_tripdata`;

CREATE OR REPLACE TABLE `trips_data_all.fhv_tripdata_partitioned_clustered_by_ba_and_flag`
CLUSTER BY SR_Flag, dispatching_base_num AS 
SELECT * FROM `trips_data_all.external_fhv_tripdata`;

SELECT COUNT(dispatching_base_num) FROM `trips_data_all.fhv_tripdata_partitioned_flag_and_clustered_by_ba`
WHERE SR_Flag = 1 AND dispatching_base_num IN ('B00987', 'B02060', 'B02279', 'B02510');
-- Query complete (0.2 sec elapsed, 14.3 MB processed)

SELECT COUNT(dispatching_base_num) FROM `trips_data_all.fhv_tripdata_partitioned_clustered_by_ba_and_flag`
WHERE SR_Flag = 1 AND dispatching_base_num IN ('B00987', 'B02060', 'B02279', 'B02510');
-- Query complete (0.2 sec elapsed, 55.2 MB processed)

--
-- Question 6: What improvements can be seen by partitioning and clustering for data size less than 1 GB *
--
-- No improvements <=
-- Can be worse due to metadata <=
-- Huge improvement in data processed
-- Huge improvement in query performance

--
-- Question 7: In which format does BigQuery save data
-- 
-- Columnar