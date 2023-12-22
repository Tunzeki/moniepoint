-- Get monthly total number of trips on Saturdays from Jan 01, 2014 to Dec 31, 2016
SELECT
  DATE_FORMAT(pickup_date, '%Y-%m') AS month_of_year, -- month_of_year
    COUNT(*) AS sat_trip_count
FROM tripdata 
GROUP BY month_of_year 
HAVING 
  month_of_year BETWEEN '2014-01' AND '2016-12' 
  AND toDayOfWeek(pickup_date) == 6 -- toDayOfWeek(date) assumes Monday as the first day of the week...
ORDER BY month_of_year ASC; -- and represents it with 1, Tuesday with 2, ..., Saturday with 6, and Sunday with 7

-- Get number of Saturdays in each month_of_year from Jan 01, 2014 to Dec 31, 2016
SELECT 
DATE_FORMAT(saturdays, '%Y-%m') AS month_of_year,
COUNT (DISTINCT saturdays) AS number_of_sat_in_the_month -- NUMBER OF SATURDAYS IN THE MONTH
FROM
(SELECT pickup_date AS saturdays -- ALL SATURDAYS IN THE MONTH
FROM
(
SELECT
  pickup_date -- ALL DAYS OF THE MONTH
FROM tripdata 
WHERE DATE_FORMAT(pickup_date, '%Y-%m') BETWEEN '2014-01' AND '2016-12'
) AS days_of_the_month
WHERE toDayOfWeek(pickup_date) == 6) AS saturdays_dates
GROUP BY month_of_year
ORDER BY month_of_year ASC;


-- average number of trips on Saturdays between Jan 01, 2014 and Dec 31, 2016
-- = total number of Saturday trips each month / number of Saturdays in the month
SELECT
  a.month_of_year,
  (a.sat_trip_count / b.number_of_sat_in_the_month) AS sat_mean_trip_count
FROM 
(
  -- Get monthly total number of trips on Saturdays from Jan 01, 2014 to Dec 31, 2016
  SELECT
      DATE_FORMAT(pickup_date, '%Y-%m') AS month_of_year, -- month_of_year
      COUNT(*) AS sat_trip_count
  FROM 
  tripdata 
  GROUP BY month_of_year 
  HAVING 
  month_of_year BETWEEN '2014-01' AND '2016-12' 
  AND toDayOfWeek(pickup_date) == 6 -- toDayOfWeek(date) assumes Monday as the first day of the week...
  ORDER BY month_of_year ASC -- and represents it with 1, Tuesday with 2, ..., Saturday with 6, and Sunday with 7
) AS a
INNER JOIN 
(
    -- Get number of Saturdays in each month from Jan 01, 2014 to Dec 31, 2016
    SELECT 
        DATE_FORMAT(saturdays, '%Y-%m') AS month_of_year,
        COUNT (DISTINCT saturdays) AS number_of_sat_in_the_month -- NUMBER OF SATURDAYS IN THE MONTH
    FROM
    (
        SELECT 
            pickup_date AS saturdays -- ALL SATURDAYS IN THE MONTH
        FROM
        (
            SELECT
                pickup_date -- ALL DAYS OF THE MONTH
            FROM 
            tripdata 
            WHERE DATE_FORMAT(pickup_date, '%Y-%m') BETWEEN '2014-01' AND '2016-12'
        ) AS days_of_the_month
        WHERE toDayOfWeek(pickup_date) == 6
    ) AS saturdays_dates
    GROUP BY month_of_year
    ORDER BY month_of_year ASC
) AS b
ON a.month_of_year = b.month_of_year;


-- Get monthly total fare for all Saturday trips from Jan 01, 2014 to Dec 31, 2016
SELECT
  DATE_FORMAT(pickup_date, '%Y-%m') AS month_of_year, -- month_of_year
  SUM(fare_amount) AS sat_total_fare
FROM tripdata 
GROUP BY month_of_year 
HAVING 
  month_of_year BETWEEN '2014-01' AND '2016-12' 
  AND toDayOfWeek(pickup_date) == 6 -- toDayOfWeek(date) assumes Monday as the first day of the week...
ORDER BY month_of_year ASC; -- and represents it with 1, Tuesday with 2, ..., Saturday with 6, and Sunday with 7

-- Get monthly total trip duration for all Saturdays trips from Jan 01, 2014 to Dec 31, 2016
SELECT
  DATE_FORMAT(pickup_date, '%Y-%m') AS month_of_year, -- month_of_year
  SUM(date_diff('second', pickup_datetime, dropoff_datetime)) AS total_trip_duration
FROM tripdata 
GROUP BY month_of_year 
HAVING 
  month_of_year BETWEEN '2014-01' AND '2016-12' 
  AND toDayOfWeek(pickup_date) == 6 -- toDayOfWeek(date) assumes Monday as the first day of the week...
ORDER BY month_of_year ASC; -- and represents it with 1, Tuesday with 2, ..., Saturday with 6, and Sunday with 7

-- Get monthly total number of trips on Sundays from Jan 01, 2014 to Dec 31, 2016
SELECT
  DATE_FORMAT(pickup_date, '%Y-%m') AS month_of_year, -- month_of_year
    COUNT(*) AS sun_trip_count
FROM tripdata 
GROUP BY month_of_year 
HAVING 
  month_of_year BETWEEN '2014-01' AND '2016-12' 
  AND toDayOfWeek(pickup_date) == 7 -- toDayOfWeek(date) assumes Monday as the first day of the week...
ORDER BY month_of_year ASC; -- and represents it with 1, Tuesday with 2, ..., Saturday with 6, and Sunday with 7

-- Get number of Sundays in each month from Jan 01, 2014 to Dec 31, 2016
SELECT 
DATE_FORMAT(sundays, '%Y-%m') AS month_of_year,
COUNT (DISTINCT sundays) AS number_of_sun_in_the_month -- NUMBER OF SUNDAYS IN THE MONTH
FROM
(SELECT pickup_date AS sundays -- ALL SUNDAYS IN THE MONTH
FROM
(
SELECT
  pickup_date -- ALL DAYS OF THE MONTH
FROM tripdata 
WHERE DATE_FORMAT(pickup_date, '%Y-%m') BETWEEN '2014-01' AND '2016-12'
) AS days_of_the_month
WHERE toDayOfWeek(pickup_date) == 7) AS sundays_dates
GROUP BY month_of_year
ORDER BY month_of_year ASC;

/*
  Average number of trips on Saturdays = 
  total number of Saturday trips each month / number of Saturdays in the month

  Average fare (fare_amount) per trip on Saturdays = 
  total fare for all Saturday trips in a month / total number of Saturday trips that month

  Pick up time does not always start at 00 seconds, neither does drop_off time always end at 00 seconds
  Therefore, using hour / minute as the unit in the date_diff function will cause over/underestimation 
  of the trip duration, due to rounding off.
  Use second as the unit in the date_diff function and 
  convert average duration per trip to minute in the query output.
  Average duration per trip on Saturdays =
  total duration of all Saturday trips in a month / total number of Saturday trips that month

  Similar arithmetic applies for finding the average number of trips on Sundays,
  the average fare per trip on Sundays, and the average duration per trip on Sundays
*/ 

SELECT
  a.month_of_year AS `month`, -- round off averages to 1 decimal place
  round((a.sat_trip_count / b.number_of_sat_in_the_month), 1) AS sat_mean_trip_count,
  round((a.sat_total_fare / a.sat_trip_count), 1) AS sat_mean_fare_per_trip,
  round((a.sat_total_trip_duration / a.sat_trip_count) / 60, 1) AS sat_mean_duration_per_trip, -- in minutes
  round((c.sun_trip_count / d.number_of_sun_in_the_month), 1) AS sun_mean_trip_count,
  round((c.sun_total_fare / c.sun_trip_count), 1) AS sun_mean_fare_per_trip,
  round((c.sun_total_trip_duration / c.sun_trip_count) / 60, 1) AS sun_mean_duration_per_trip -- in minutes
FROM 
(
  -- Get monthly total number of trips on Saturdays from Jan 01, 2014 to Dec 31, 2016
  SELECT
      DATE_FORMAT(pickup_date, '%Y-%m') AS month_of_year, -- month_of_year
      COUNT(*) AS sat_trip_count,
      SUM(fare_amount) AS sat_total_fare,
      SUM(date_diff('second', pickup_datetime, dropoff_datetime)) AS sat_total_trip_duration
  FROM 
  tripdata 
  GROUP BY month_of_year 
  HAVING 
  month_of_year BETWEEN '2014-01' AND '2016-12' 
  AND toDayOfWeek(pickup_date) == 6 -- toDayOfWeek(date) assumes Monday as the first day of the week...
  ORDER BY month_of_year ASC -- and represents it with 1, Tuesday with 2, ..., Saturday with 6, and Sunday with 7
) AS a
INNER JOIN 
(
  -- Get number of Saturdays in each month from Jan 01, 2014 to Dec 31, 2016
  SELECT 
      DATE_FORMAT(saturdays, '%Y-%m') AS month_of_year,
      COUNT (DISTINCT saturdays) AS number_of_sat_in_the_month -- NUMBER OF SATURDAYS IN THE MONTH
  FROM
  (
      SELECT 
          pickup_date AS saturdays -- ALL SATURDAYS IN THE MONTH
      FROM
      (
          SELECT
              pickup_date -- ALL DAYS OF THE MONTH
          FROM 
          tripdata 
          WHERE DATE_FORMAT(pickup_date, '%Y-%m') BETWEEN '2014-01' AND '2016-12'
      ) AS days_of_the_month
      WHERE toDayOfWeek(pickup_date) == 6
  ) AS saturdays_dates
  GROUP BY month_of_year
  ORDER BY month_of_year ASC
) AS b
ON a.month_of_year = b.month_of_year
INNER JOIN 
(
  -- Get monthly total number of trips on Sundays from Jan 01, 2014 to Dec 31, 2016
  SELECT
    DATE_FORMAT(pickup_date, '%Y-%m') AS month_of_year, -- month_of_year
      COUNT(*) AS sun_trip_count,
      SUM(fare_amount) AS sun_total_fare,
      SUM(date_diff('second', pickup_datetime, dropoff_datetime)) AS sun_total_trip_duration
  FROM tripdata 
  GROUP BY month_of_year 
  HAVING 
    month_of_year BETWEEN '2014-01' AND '2016-12' 
    AND toDayOfWeek(pickup_date) == 7
  ORDER BY month_of_year ASC
) AS c 
ON a.month_of_year = c.month_of_year
INNER JOIN
(
  -- Get number of Sundays in each month from Jan 01, 2014 to Dec 31, 2016
  SELECT 
  DATE_FORMAT(sundays, '%Y-%m') AS month_of_year,
  COUNT (DISTINCT sundays) AS number_of_sun_in_the_month -- NUMBER OF SUNDAYS IN THE MONTH
  FROM
  (SELECT pickup_date AS sundays -- ALL SUNDAYS IN THE MONTH
  FROM
  (
  SELECT
    pickup_date -- ALL DAYS OF THE MONTH
  FROM tripdata 
  WHERE DATE_FORMAT(pickup_date, '%Y-%m') BETWEEN '2014-01' AND '2016-12'
  ) AS days_of_the_month
  WHERE toDayOfWeek(pickup_date) == 7) AS sundays_dates
  GROUP BY month_of_year
  ORDER BY month_of_year ASC
) AS d 
ON a.month_of_year = d.month_of_year;