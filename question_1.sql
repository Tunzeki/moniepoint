-- Get monthly total number of trips on Saturdays from Jan 01, 2014 to Dec 31, 2016
SELECT
  DATE_FORMAT(pickup_date, '%Y-%m') AS month_of_year, -- month_of_year
    COUNT(*) AS sat_trip_count
FROM tripdata 
GROUP BY month_of_year 
HAVING 
  month_of_year BETWEEN '2014-01' AND '2016-12' 
  AND toDayOfWeek(pickup_date) == 6 -- toDayOfWeek(date) assumes Monday as the first day of the week and represents it with 1, Tuesday with 2, ..., Saturday with 6, and Sunday with 7
ORDER BY month_of_year ASC;

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
    AND toDayOfWeek(pickup_date) == 6 -- toDayOfWeek(date) assumes Monday as the first day of the week and represents it with 1, Tuesday with 2, ..., Saturday with 6, and Sunday with 7
    ORDER BY month_of_year ASC
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





