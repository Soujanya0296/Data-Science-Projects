- SETTING UP THE ENVIRONMENT

add jar /opt/cloudera/parcels/CDH/lib/hive/lib/hive-hcatalog-core-1.1.0-cdh5.11.2.jar;

set hive.exec.max.dynamic.partitions = 100000;
set hive.exec.max.dynamic.partitions.pernode = 100000;

------------------------------------------------------------------------------------------------------------------------------------------------------

-- CREATING A DATABASE

drop database if exists Hive_Case_Study_khushi;

create database Hive_Case_Study_khushi;

use Hive_Case_Study_khushi;

------------------------------------------------------------------------------------------------------------------------------------------------------

-- CREATING AN EXTERNAL TABLE

drop table yellow_tripdata_2017_cs;

create external table if not exists yellow_tripdata_2017_cs (
vendorid int, 
tpep_pickup_datetime timestamp, 
tpep_dropoff_datetime timestamp, 
passenger_count int, 
trip_distance double, 
ratecodeID int, 
store_and_fwd_flag string, 
pulocationid int, 
dolocationid int, 
payment_type int, 
fare_amount double, 
extra double, 
mta_tax double, 
tip_amount double, 
tolls_amount double, 
improvement_surcharge double, 
total_amount double
)
row format delimited fields terminated by ',' 
location '/common_folder/nyc_taxi_data/' 
tblproperties ('skip.header.line.count' = '1');

select * from yellow_tripdata_2017_cs;

------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------### BASIC DATA QUALITY CHECKS ###---------------------------------------------------------

-------------------------------------------------------------------### QUERY ###----------------------------------------------------------------------

-- 1. HOW MANY RECORDS HAS EACH TPEP PROVIDER PROVIDED? WRITE A QUERY THAT SUMMARISES THE NUMBER OF RECORDS OF EACH PROVIDER.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- From the data dictionary 'tpep provider' corresponds to 'vendorid'.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

-- vendorid   count

--    1       527386
--    2       647183

-------------------------------------------------------------------### QUERY ###----------------------------------------------------------------------

-- 2. THE DATA PROVIDED IS FOR MONTHS NOVEMBER AND DECEMBER ONLY. CHECK WHETHER THE DATA IS CONSISTENT, IF NOT MENTION ALL THE DATA QUALITY ISSUES.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Analyzing based on 'tpep_pickup_datetime' column.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where tpep_pickup_datetime < '2017-11-01 00:00:00.0' or tpep_pickup_datetime >= '2018-01-01 00:00:00.0' 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

-- vendorid   count

--    2       14

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- There are a total 14 records, all from VendorID '2' which fall out of November and December months. Lets see the details of these records below.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

select vendorid, tpep_pickup_datetime, tpep_dropoff_datetime 
from yellow_tripdata_2017_cs 
where tpep_pickup_datetime < '2017-11-01 00:00:00.0' or tpep_pickup_datetime >= '2018-01-01 00:00:00.0';

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--   vendorid        	tpep_pickup_datetime            tpep_dropoff_datetime

-- 1        2            2017-10-31 23:59:00.0            2017-11-01 00:11:00.0
-- 2        2            2017-10-31 23:59:00.0            2017-11-01 00:06:00.0
-- 3        2            2017-10-31 23:59:00.0            2017-11-01 00:10:00.0
-- 4        2            2017-10-31 11:23:00.0            2017-10-31 11:28:00.0
-- 5        2            2017-10-31 18:56:00.0            2017-11-01 18:18:00.0
-- 6        2            2017-10-31 18:33:00.0            2017-10-31 18:38:00.0
-- 7        2            2009-01-01 00:13:00.0            2009-01-01 00:32:00.0
-- 8        2            2008-12-31 10:27:00.0            2008-12-31 10:48:00.0
-- 9        2            2008-12-31 23:53:00.0            2009-01-01 00:03:00.0
-- 10       2            2003-01-01 00:58:00.0            2003-01-01 01:28:00.0
-- 11       2            2018-01-01 00:00:00.0            2018-01-01 00:12:00.0
-- 12       2            2018-01-01 00:00:00.0            2018-01-01 00:15:00.0
-- 13       2            2018-01-01 00:00:00.0            2018-01-01 00:00:00.0
-- 14       2            2018-01-01 00:04:00.0            2018-01-01 00:17:00.0


-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Out of the 14 records, most of the trips were in 2017 October and 2018 January with some outliers from 2003, 2008 and 2009 as seen from the above output.
-- Seems like VendorID '2' has given faulty records.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Analyzing based on 'tpep_dropoff_datetime' column.
-- The drop may have happened the next day hence the drop time might be till 1 jan 2018 (represent as >= 2-jan-2018).

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where tpep_dropoff_datetime < '2017-11-01 00:00:00.0' or tpep_dropoff_datetime >= '2018-01-02 00:00:00.0' 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

-- vendorid   count

--    1         1
--    2         6

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- There are a total 7 records, which fall out of November and December months.
-- VendorID '2' has performed poorly.
-- Lets see the details of these records below.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

select vendorid, tpep_pickup_datetime, tpep_dropoff_datetime 
from yellow_tripdata_2017_cs 
where tpep_dropoff_datetime < '2017-11-01 00:00:00.0' or tpep_dropoff_datetime >= '2018-01-02 00:00:00.0' 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--             vendorid        	tpep_pickup_datetime        tpep_dropoff_datetime

-- 1            1                2017-11-14 13:50:00.0        2019-04-24 19:21:00.0
-- 2            2                2003-01-01 00:58:00.0        2003-01-01 01:28:00.0
-- 3            2                2008-12-31 23:53:00.0        2009-01-01 00:03:00.0
-- 4            2                2008-12-31 10:27:00.0        2008-12-31 10:48:00.0
-- 5            2                2009-01-01 00:13:00.0        2009-01-01 00:32:00.0
-- 6            2                2017-10-31 18:33:00.0        2017-10-31 18:38:00.0
-- 7            2                2017-10-31 11:23:00.0        2017-10-31 11:28:00.0

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Out of the 7 records, the trips were spread in 2003, 2008, 2009, 2017 and 2019. 
-- Seems like VendorID '2' has given faulty records.

-------------------------------------------------------------------### QUERY ###----------------------------------------------------------------------

-- 3. YOU MIGHT HAVE ENCOUNTERED UNUSUAL OR ERRONEOUS ROWS IN THE DATASET.
-- CAN YOU CONCLUDE WHICH VENDOR IS DOING A BAD JOB IN PROVIDING THE RECORDS USING DIFFERENT COLUMNS OF THE DATASET.
-- SUMMARISE YOUR CONCLUSIONS BASED ON EVERY COLUMN WHERE THESE ERRORS ARE PRESENT.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'VENDORID'. 
-- It can only have values '1' and '2'.

select * 
from yellow_tripdata_2017_cs 
where vendorid != 1 and vendorid != 2;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

-- 0 results.

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- No erroneous rows w.r.t the column VendorID.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'TPEP_PICKUP_DATETIME'. 
-- The dropoff datetime cannot be less than the pickup datetime.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where tpep_dropoff_datetime < tpep_pickup_datetime 
group by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

-- vendorid   count

--    1       73

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- There are a total 73 records, all belonging to VendorID '1' which have dropoff datetime less than the pickup datetime.
-- Seems like VendorID '1' has given faulty records.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Also the data should belong to the months of November and December.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where tpep_pickup_datetime < '2017-11-01 00:00:00.0' or tpep_pickup_datetime >= '2018-01-01 00:00:00.0' 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

-- vendorid   count

--    2       14

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- There are a total 14 records, all from VendorID '2' which fall out of November and December months.
-- Vendor '2' has provided faulty records.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'TPEP_DROPOFF_DATETIME'. 
-- The dropoff datetime cannot be less than the pickup datetime.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where tpep_dropoff_datetime < tpep_pickup_datetime 
group by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

-- vendorid   count

--    1       73

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- There are a total 73 records, all belonging to VendorID '1' which have dropoff datetime less than the pickup datetime.
-- Seems like VendorID '1' has given faulty records.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Also the data should belong to the months of November and December. 

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where tpep_dropoff_datetime < '2017-11-01 00:00:00.0' or tpep_dropoff_datetime >= '2018-01-02 00:00:00.0' 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

-- vendorid   count

--    1         1
--    2         6

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- There are a total 7 records, which fall out of November and December months.
-- VendorID '2' has performed poorly.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'PASSENGER_COUNT' column.
-- Passenger count = 0 is considered unusual because the driver cannot start the trip with '0' passengers.
-- Passenger count > 10 is also not possible because the maximum capacity of a car cannot be more than '10'.

select vendorid, passenger_count, count(*) as `count` 
from yellow_tripdata_2017_cs 
where passenger_count = 0 or passenger_count > 10 
group by vendorid, passenger_count 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--    	vendorid    		passenger_count       	     	count

-- 1        1                        0                        6813
-- 2        2                        0                        11

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- There are a total 6813 records corresponding to '0' passenger count given by VendorID '1'.
-- There are a total 11 records corresponding to '0' passenger count given by VendorID '2'.
-- There are no records with passenger count greater than '10'.
-- Seems like VendorID '2' has performed a good job.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'TRIP_DISTANCE' column.
-- Checking for the records with 'trip_distance' < '0'

select * 
from yellow_tripdata_2017_cs 
where trip_distance < 0;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

-- 0 results.

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- No records with Trip distance less than zero.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Checking for the records with 'trip_distance' = '0'

select vendorid, trip_distance, count(*) as `count` 
from yellow_tripdata_2017_cs 
where trip_distance = 0 
group by vendorid, trip_distance 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--          vendorid         	    trip_distance               count

-- 1           1                        0                        4217
-- 2           2                        0                        3185

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- There are total 7402 records with trip distance = 0 of which 4217 belong to VendorID '1' and 3185 belong to VendorID '2'.
-- Both the vendors performed poorly.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'PULOCATIONID', 'DOLOCATIONID' column.
-- If trip distance not equal to '0' and pickup and dropoff location ID's are the same, that could be an erroneous row.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where trip_distance != 0 and pulocationid = dolocationid 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

-- vendorid   count

--    1       39317
--    2       38327

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Both the vendors performed poorly.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'RATECODEID' column.
-- Rate code ID should lie in the range 1 to 6.

select vendorid, ratecodeid, count(ratecodeid) as `count` 
from yellow_tripdata_2017_cs 
group by vendorid, ratecodeid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--           vendorid        ratecodeid              count


-- 1           1                    6                    2
-- 2           1                    4                  230
-- 3           1                    2                10544
-- 4           1                   99                    8
-- 5           1                    5                 1425
-- 6           1                    3                 1186
-- 7           1                    1               513991
-- 8           2                    6                    1
-- 9           2                    4                  356
-- 10          2                    2                14794
-- 11          2                   99                    1
-- 12          2                    5                 2368
-- 13          2                    3                 1376
-- 14          2                    1               628287

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Most of the values are in range 1 to 6 and '9' rows in total have the value '99'.
-- VendorID '1' has '8' rows with the value '99'.
-- VendorID '2' has a '1' row with the value '99'.
-- VendorID '1' has performed poorly.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'STORE_AND_FWD_FLAG' column.
-- This should include the values 'Y' or 'N'.

select vendorid, store_and_fwd_flag, count(store_and_fwd_flag) as `count` 
from yellow_tripdata_2017_cs 
group by vendorid, store_and_fwd_flag 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--         vendorid        store_and_fwd_flag        	count

-- 1           1                    N                    523435
-- 2           1                    Y                    3951
-- 3           2                    N                    647183

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- No erroneous records w.r.t this column.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'PAYMENT_TYPE' column.
-- This should include the values in the range 1 to 6.

select vendorid, payment_type, count(payment_type) as `count` 
from yellow_tripdata_2017_cs 
group by vendorid, payment_type 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--             vendorid        payment_type        	    	count

-- 1                1              4                        1521
-- 2                1              2                        166970
-- 3                1              3                        5861
-- 4                1              1                        353034
-- 5                2              3                        413
-- 6                2              1                        437222
-- 7                2              4                        144
-- 8                2              2                        209404

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- No erroneous records w.r.t this column. This column doesn't have the values '5' and '6' at all.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'FARE_AMOUNT' column.
-- Fare amount cannot be less than 0.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where fare_amount < 0 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

-- vendorid   count

--    2       558

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- No erroneous records w.r.t VendorId '1' in this column. 
-- VendorId '2' has 558 negative values.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Also fare_amount cannot be zero when trip_distance is not equal to zero.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where fare_amount = 0 and trip_distance != 0 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--        vendorid        count

-- 1        1                156
-- 2        2                11


-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Again VendorId '1' has performed badly.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'EXTRA' column.
-- This column can only have the values '0', '0.5' and '1'.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where extra != 0 and extra != 0.5 and extra != 1 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--        vendorid           count

-- 1        1                1823
-- 2        2                3033


-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Total 12 records with the values other than the specified. 
-- VendorId '1' has 4 out of range values.
-- VendorId '2' has 8 out of range values.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'MTA_TAX' column.
-- This column can only have the values '0' and '0.5'.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where mta_tax not in (0, 0.5) 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--        vendorid        count

-- 1        1                1
-- 2        2                547

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Total 548 records with the values other than the specified. 
-- VendorId '2' is performing badly.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'IMPROVEMENT_SURCHARGE' column.
-- This column can only have the values '0' and '0.3'.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where improvement_surcharge not in (0, 0.3) 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--        vendorid        count

-- 1        2                562

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Total 547 records with the values other than the specified. 
-- VendorId '2' is performing badly.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'TIP_AMOUNT' column.
-- This column cannot have the values less than '0'.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where tip_amount < 0 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--        vendorid        count

-- 1        2                4

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Total 4 records with the values other than the specified. 
-- VendorId '2' is performing badly.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'TOLLS_AMOUNT' column.
-- This column cannot have the values less than '0'.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where tolls_amount < 0 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--        vendorid        count

-- 1        2                3

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Total 3 records with the values other than the specified. 
-- VendorId '2' is performing badly.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Validating 'TOTAL_AMOUNT' column.
-- This column cannot have the values less than '0'.

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
where total_amount < 0 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--        vendorid          count

-- 1        2                558

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Total 558 records with the values other than the specified. 
-- VendorId '2' is performing badly.

------------------------------------------------------------------------------------------------------------------------------------------------------

-- Final conclusion on erroneous rows
-- There are unusual rows in the following columns

-- Pickup datetime
-- Dropoff datetime
-- Passenger count
-- Trip distance
-- PUlocationID
-- DOlocationID
-- RatecodeID
-- Fare amount
-- Extra
-- MTA Tax
-- Improvement surcharge
-- Tip amount
-- Tolls amount
-- Total amount

------------------------------------------------------------------------------------------------------------------------------------------------------

-- CREATING A CLEAN, ORC PARTITIONED TABLE FOR ANALYSIS 
-- PARTITIONING BY YEAR AND MONTH

drop table yellow_tripdata_2017_cs_partitioned_orc;

create external table if not exists yellow_tripdata_2017_cs_partitioned_orc (
vendorid int, 
tpep_pickup_datetime timestamp, 
tpep_dropoff_datetime timestamp, 
passenger_count int, 
trip_distance double, 
ratecodeID int, 
store_and_fwd_flag string, 
pulocationid int, 
dolocationid int, 
payment_type int, 
fare_amount double, 
extra double, 
mta_tax double, 
tip_amount double, 
tolls_amount double, 
improvement_surcharge double, 
total_amount double 
) 
partitioned by (yr int, mnth int) 
stored as orc 
location '/user/soujanyap0296_gmail/yellow_tripdata_2017_cs_partitioned_orc' 
tblproperties ("orc.compress"="SNAPPY");

select * 
from yellow_tripdata_2017_cs_partitioned_orc;

------------------------------------------------------------------------------------------------------------------------------------------------------

-- INSERTING THE DATA INTO THE PARTITION TABLE

insert overwrite table yellow_tripdata_2017_cs_partitioned_orc 
partition (yr, mnth) 
select vendorid int, 
tpep_pickup_datetime timestamp, 
tpep_dropoff_datetime timestamp, 
passenger_count int, 
trip_distance double, 
ratecodeID int, 
store_and_fwd_flag string, 
pulocationid int, 
dolocationid int, 
payment_type int, 
fare_amount double, 
extra double, 
mta_tax double, 
tip_amount double, 
tolls_amount double, 
improvement_surcharge double, 
total_amount double, 
year(tpep_pickup_datetime) as yr, 
month(tpep_pickup_datetime) as mnth 
from yellow_tripdata_2017_cs 
where 
year(tpep_pickup_datetime) = 2017 and 
month(tpep_pickup_datetime) in (11, 12) and 
passenger_count != 0 and 
trip_distance > 0 and 
ratecodeid in (1, 2, 3, 4, 5, 6) and 
fare_amount >= 0 and 
extra in (0, 0.5, 1) and 
mta_tax in (0, 0.5) and 
improvement_surcharge in (0, 0.3) and 
tip_amount >= 0 and 
tolls_amount >= 0 and 
total_amount >= 0;

------------------------------------------------------------------------------------------------------------------------------------------------------

-- CHECKING THE NUMBER OF RECORDS DROPPED

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- PREVIOUS NUMBER OF RECORDS

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--        vendorid           count

-- 1        1                527386
-- 2        2                647183

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- NUMBER OF RECORDS AFTER DROPPING ERRONEOUS ROWS

select vendorid, count(*) as `count` 
from yellow_tripdata_2017_cs_partitioned_orc 
group by vendorid 
order by vendorid;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--        vendorid           count

-- 1        1                514730
-- 2        2                640858

------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------### ANALYSIS-I ###--------------------------------------------------------------------

-------------------------------------------------------------------### QUERY ###----------------------------------------------------------------------

-- 1. COMPARE THE OVERALL AVERAGE FARE TRIP FOR NOVEMBER AND DECEMBER.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

select mnth, round(avg(fare_amount), 2) as average 
from yellow_tripdata_2017_cs_partitioned_orc 
group by mnth 
order by mnth;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--        mnth                average

-- 1        11                12.91
-- 2        12                12.7

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- The average fare trip in November is slightly higher than that of December.

-------------------------------------------------------------------### QUERY ###----------------------------------------------------------------------

-- 2. EXPLORE THE 'NUMBER OF PASSENGERS PER TRIP' - HOW MANY TRIPS ARE MADE BY EACH LEVEL OF 'PASSENGER_COUNT'? DO MOST PEOPLE TRAVEL SOLO OR WITH OTHER PEOPLE?

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

select passenger_count, count(*) as total_count 
from yellow_tripdata_2017_cs_partitioned_orc 
group by passenger_count 
order by total_count desc;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--          passenger_count              total_count


-- 1        1                                818589
-- 2        2                                175007
-- 3        5                                 54113        
-- 4        3                                 50244
-- 5        6                                 32920
-- 6        4                                 24712
-- 7        7                                     3

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- From the above result, it's evident that most of the passengers prefer to travel solo.

-------------------------------------------------------------------### QUERY ###----------------------------------------------------------------------

-- 3. WHICH IS THE MOST PREFERRED MODE OF PAYMENT?

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

select payment_type, count(*) as mode_count 
from yellow_tripdata_2017_cs_partitioned_orc 
group by payment_type 
order by mode_count desc;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--          payment_type        	mode_count

-- 1        1                            779828
-- 2        2                            369620
-- 3        3                              4814        
-- 4        4                              1326

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- From the above result, it's evident that most of the passengers prefer to make payment using a credit card.

-------------------------------------------------------------------### QUERY ###----------------------------------------------------------------------

-- 4. WHAT IS THE AVERAGE TIP PAID PER TRIP? COMPARE THE AVERAGE TIP WITH THE 25th, 50th AND 75th PERCENTILES. 
-- COMMENT WHETHER THE AVERAGE TIP IS A REPRESENTATIVE STATISTIC (OF THE CENTRAL TENDENCY) OF 'TIP_AMOUNT' PAID.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Calculating the average tip amount.

select round(avg(tip_amount), 2) as average 
from yellow_tripdata_2017_cs_partitioned_orc 
where fare_amount > 0;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--          average

-- 1        1.83

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- The average tip amount paid by the passengers is 1.83.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Comparing it with 25th, 50th and 75th percentiles.

select round(percentile_approx(tip_amount, 0.25), 2) as 25_percentile, 
round(percentile_approx(tip_amount, 0.50), 2) as 50_percentile, 
round(percentile_approx(tip_amount, 0.75), 2) as 75_percentile, 
round(avg(tip_amount), 2) as average 
from yellow_tripdata_2017_cs_partitioned_orc 
where fare_amount > 0;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--             25_percentile        50_percentile          75_percentile                average

-- 1                0                  1.35                        2.45                  1.83

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- The average tip amount paid is not a representative statistic of central tendency.

-------------------------------------------------------------------### QUERY ###----------------------------------------------------------------------

-- 5. EXPLORE THE EXTRA VARIABLE - WHAT FRACTION OF TOTAL TIPS HAVE AN EXTRA CHARGE LEVIED?

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

select round(sum(if (extra > 0, 1, 0))/count(*) * 100, 2) as fraction 
from yellow_tripdata_2017_cs_partitioned_orc;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--          fraction

-- 1        46.13

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Around 46% trips are levied with extra charges.

----------------------------------------------------------------### ANALYSIS-II ###-------------------------------------------------------------------

-------------------------------------------------------------------### QUERY ###----------------------------------------------------------------------

-- 1. WHAT IS THE CORRELATION BETWEEN THE NUMBER OF PASSENGERS ON ANY GIVEN TRIP, AND THE TIP PAID PER TRIP? 
-- DO MULTIPLE TRAVELLERS TIP MORE COMPARED TO SOLO TRAVELLERS?

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Finding the correlation.

select corr(tip_amount, passenger_count) as correlation 
from yellow_tripdata_2017_cs_partitioned_orc;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--                correlation

-- 1        -0.005364280000637372

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- There is a weak negative correlation between the two columns.
-- This indicates that as the passenger count increases, the tip amount decreases slightly.
-- So solo travellers tip more than multiple travellers.

-------------------------------------------------------------------### QUERY ###----------------------------------------------------------------------

-- 2. SEGREGATE THE DATA INTO 5 SEGMENTS OF 'TIP PAID':[0-5), [5-10), [10-15), [15-20) AND >= 20.  
-- CALCULATE THE PERCENTAGE SHARE OF EACH BUCKET (THE FRACTION OF TIPS FALLING IN EACH BUCKET).

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

select sum(if (tip_amount >= 0 and tip_amount < 5, 1, 0))/count(*) * 100 as `[0-5)_fraction`, 
sum(if (tip_amount >= 5 and tip_amount < 10, 1, 0))/count(*) * 100 as `[5-10)_fraction`, 
sum(if (tip_amount >= 10 and tip_amount < 15, 1, 0))/count(*) * 100 as `[10-15)_fraction`, 
sum(if (tip_amount >= 15 and tip_amount < 20, 1, 0))/count(*) * 100 as `[15-20)_fraction`, 
sum(if (tip_amount >= 20, 1, 0))/count(*) * 100 as `20_above_fraction` 
from yellow_tripdata_2017_cs_partitioned_orc 
where fare_amount > 0;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--             [0-5)_fraction                [5-10)_fraction                [10-15)_fraction            [15-20)_fraction            20_above_fraction

-- 1        	92.38737015566608            5.638113174234176       	    1.6951382265527226        0.18954113735068226            0.08983730619635077

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- The percentage share of each bucket is as shown above.

-------------------------------------------------------------------### QUERY ###----------------------------------------------------------------------

-- 3. WHICH MONTH HAS A GREATER AVERAGE 'SPEED' - NOVEMBER OR DECEMBER? NOTE THAT THE VARIABLE SPEED WILL HAVE TO BE DERIVED FROM  OTHER METRICS.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Calculating average speed for the months november & december 2017.
-- The trip distance is given in miles.
-- The timestamp is precise upto seconds. So dividing the difference with '3600' to convert it into hours.
-- We will be getting the speed in miles per hour or mph.

select mnth, avg(trip_distance/((unix_timestamp(tpep_dropoff_datetime) - unix_timestamp(tpep_pickup_datetime))/3600)) as avg_speed_mph 
from yellow_tripdata_2017_cs_partitioned_orc 
group by mnth;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--            mnth        avg_speed_mph

-- 1        11            10.970974840774534
-- 2        12            11.070490603299344

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- The month december has greater average speed than that of november due to christmas and new year eve.

-------------------------------------------------------------------### QUERY ###----------------------------------------------------------------------

-- 4. ANALYSE THE AVERAGE SPEED OF THE MOST HAPPENING DAYS OF THE YEAR, i.e. 31st DECEMBER (NEW YEAR'S EVE) AND 25th DECEMBER (CHRISTMAS).
-- COMPARE IT WITH OVERALL AVERAGE.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Calculating the average speed of the most happening days.

select from_unixtime(unix_timestamp(tpep_pickup_datetime), 'dd-MMM-yyyy') as `Most_happening_day`, 
avg(trip_distance/((unix_timestamp(tpep_dropoff_datetime) - unix_timestamp(tpep_pickup_datetime))/3600)) as avg_speed_mph 
from yellow_tripdata_2017_cs_partitioned_orc 
where trip_distance >= 0 
and mnth = 12 
and day(tpep_pickup_datetime) in (25,31) 
and year(tpep_dropoff_datetime) in (2017, 2018) 
group by from_unixtime(unix_timestamp(tpep_pickup_datetime), 'dd-MMM-yyyy') 
order by avg_speed_mph;

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--            most_happening_day              avg_speed_mph

-- 1           25-Dec-2017                15.265472922267561
-- 2           31-Dec-2017                13.249310847620007

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Christmas has more average speed than that of New Year's Eve.

-------------------------------------------------------------------### CODE ###-----------------------------------------------------------------------

-- Comparing it with the overall average.

select avg(trip_distance/((unix_timestamp(tpep_dropoff_datetime) - unix_timestamp(tpep_pickup_datetime))/3600)) as avg_speed_mph 
from yellow_tripdata_2017_cs_partitioned_orc 
where trip_distance >= 0 and year(tpep_dropoff_datetime) in (2017, 2018);

------------------------------------------------------------------### OUTPUT ###----------------------------------------------------------------------

--              avg_speed_mph

-- 1        11.021323332151729

-----------------------------------------------------------------### ANALYSIS ###---------------------------------------------------------------------

-- Both the averages are greater than the overall average.

------------------------------------------------------------------------------------------------------------------------------------------------------