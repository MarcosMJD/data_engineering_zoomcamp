-- Select
SELECT
  *
FROM
  yellow_taxi_trips
LIMIT
  100

-- Inner join. No matching elements (i.e. t."PULocationID" = zpu."LocationID") will not be including
SELECT
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT (zpu."Borough" , ' / ' , zpu."Zone") AS "pick_up_loc",
	CONCAT (zdo."Borough" , ' / ' , zdo."Zone") AS "drop_off_loc"
FROM
  	yellow_taxi_trips t,
  	zones zpu,
  	zones zdo
WHERE
	t."PULocationID" = zpu."LocationID" AND
	t."DOLocationID" = zdo."LocationID"
LIMIT
  10

-- Other way of making inner join
SELECT
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT (zpu."Borough" , ' / ' , zpu."Zone") AS "pick_up_loc",
	CONCAT (zdo."Borough" , ' / ' , zdo."Zone") AS "drop_off_loc"
FROM
  	yellow_taxi_trips t JOIN zones zpu
		ON t."PULocationID" = zpu."LocationID"
	JOIN zones zdo
		ON t."DOLocationID" = zdo."LocationID"
LIMIT
  10

-- NOT IN example

SELECT
	"DOLocationID", "PULocationID"
FROM
  	yellow_taxi_trips t
WHERE
	"DOLocationID" NOT IN (
	SELECT "LocationID" FROM Zones) 
LIMIT
  10

-- LEFT JOIN
-- Same as INNER JOIN, but in this case, where a record in right table does not 
-- exists, the record in the left table is still shown, 
-- RIGHT JOIN, same as left
-- OUTER JOIN is a combination of LEFT and RIGHT 

-- GROUP BY + count + order
SELECT
	CAST(tpep_dropoff_datetime AS DATE) AS day,
	COUNT(1) as count
FROM
  	yellow_taxi_trips t
GROUP BY day
ORDER BY count DESC;

-- GROUP BY two fields, ORDER by two fields and some calculation in each group
SELECT
	CAST(tpep_dropoff_datetime AS DATE) AS day,
	"DOLocationID",
	COUNT(1) as count,
	MAX(total_amount),
	MAX(passenger_count)
FROM
  	yellow_taxi_trips t
GROUP BY
	1, 2
ORDER BY 
	day ASC, 
	"DOLocationID" ASC;