-- Lost at Sea SQL is a SQL learning game developed by Robin Lord. https://lost-at-sql.therobinlord.com/
-- The following are queries written to answer the 20 question tasks.

-- Chapter 1
Select Issues
FROM Malfunctions

-- Chapter 2
SELECT issues, fix
FROM malfunctions

-- Chapter 3
SELECT *
FROM crew

-- Chapter 4
Select *
FROM crew
WHERE role = 'first officer'

-- Chapter 5
SELECT *
FROM pods_list
WHERE status = 'functioning' AND range  > 1500

-- Chaper 6
SELECT *
FROM circuits
WHERE area = 'pod o3' 
OR status IS NOT 'green'

-- Chapter 7
SELECT last_location,
COUNT(staff_name) AS crew_count
FROM crew
GROUP BY last_location

-- Chapter 8
Select last_location, status,
COUNT(staff_name) AS crew_count
FROM crew
GROUP BY last_location, status

-- Chapter 9
Select pod_group,
sum(weight_kg) AS total_weight, -- Aggregate functions to create new column w/ calculations
max(distance_to_pod) AS max_distance
FROM crew
WHERE status IS NOT 'deceased'
GROUP BY pod_group

-- Chapter 10
Select staff_name, weight_kg
From crew
Order by weight_kg

-- Chapter 11
Select staff_name, weight_kg,
CASE -- Conditional operation to add context to various situations 
	WHEN weight_kg > 10 then weight_kg
	ELSE weight_kg * 10
END AS fixed_weight
FROM crew
ORDER BY weight_kg ASC

-- Chapter 12
-- Step 1
Select staff_name, pod_group, weight_kg
FROM crew
WHERE status IS NOT 'deceased'
-- Step 2
Select staff_name, pod_group,
CASE
	WHEN weight_kg > 10 then weight_kg
    ELSE weight_kg * 10
END AS fixed_weight
FROM filtered_crew
-- Step 3
Select pod_group,
sum(fixed_weight) AS total_weight
FROM fixed_crew
GROUP BY pod_group
-- Step 4
Select *
FROM grouped_crew
WHERE total_weight > 1000
ORDER BY total_weight DESC

-- Chapter 13
SELECT staff_name, party_status
FROM crew
JOIN evacuation_groups ON crew.pod_group = evacuation_groups.pod_group -- Joining two tables into a single dataset
WHERE party_status IS NOT 'boarded'

-- Chapter 14
-- Step 1 
SELECT *
FROM original_crew
LEFT JOIN crew ON crew.staff_id = original_crew.staff_id -- Returns all the rows from the left table and the matching rows from the right table
-- Step 2
SELECT *
FROM joined_crew
WHERE last_location IS null
-- Step 3
WITH
  joined_crew AS (
    SELECT *
    FROM original_crew
      LEFT JOIN crew ON original_crew.staff_id = crew.staff_id
  )
SELECT *
FROM joined_crew
WHERE last_location IS NULL 

-- Chapter 15
-- Step 1 
Select staff_name, 
GROUP_CONCAT(role) AS combined_roles -- Combine multiple rows of data into a single string
FROM staffing_changes
GROUP BY staff_name
-- Step 2
Select *
FROM full_crew
FULL OUTER JOIN grouped_changes ON full_crew.staff_name = grouped_changes.staff_name
-- Step 3
SELECT * -- (% Wildcard used with the 'LIKE' operator)
FROM joined_crew
WHERE last_location IS NULL 
AND combined_roles NOT LIKE '%Transfer' -- Retrieves all rows where combined_roles column does not end with 'Transfer'
AND combined_roles NOT LIKE '%Injured%' -- Retrieves all rows where combined_roles column does not contain 'Injured' anywhere

-- Chapter 16
Select *
FROM joined_crew
WHERE last_location IS NULL
AND combined_roles NOT LIKE '%Transfer'
AND (combined_roles NOT LIKE '%Injured%' 
OR combined_roles LIKE '%Injured%Returned%')

-- Chapter 17
-- Step 1
SELECT *,
  ROW_NUMBER() OVER ( -- Assigns a row number to each row
    PARTITION BY depot -- Performs calculation independently, allowing rows with the same 'deport' value to have consecutive row numbers
    ORDER BY timestamp DESC
  ) AS reverse_ordered
FROM depot_records
-- Step 2
SELECT staff_name, staff_id, depot, timestamp
FROM found_last
WHERE reverse_ordered = 1

-- Chapter 18
-- Step 1 
SELECT *,
strftime('%s', start_time) AS start_seconds,
strftime('%s', end_time) AS end_seconds
FROM phone_logs
-- Step 2
Select *, 
end_seconds - start_seconds AS duration
FROM date_to_seconds
-- Step 3
SELECT phone_number
FROM calculated_duration
WHERE incoming_outgoing = 'Incoming'
  AND staff_id = 'mm833'
  AND duration > 1
-- Step 4
SELECT *
FROM phone_logs
WHERE phone_number IN suspect_numbers
  AND staff_id IS NOT 'mm833'
-- Step 5
SELECT DISTINCT staff_name, phone_number
FROM suspect_individuals
-- Step 6
SELECT *,
  count(staff_name) OVER (
    PARTITION BY phone_number
  ) AS staff_count
FROM distinct_calls
-- Step 7
SELECT staff_name
FROM counted_staff
WHERE staff_count = 1

-- Chapter 19
-- Step 1 
UNION lift_locations to Timestamp -- Removes duplicate rows 
WITH
  combined_locations AS (
    SELECT time, lift_name, deck
    FROM lift_locations
    UNION ALL
    SELECT Timestamp, lift_name, Location
    FROM lift_locations_2
  ),
-- Step 2 
  found_latest_location AS (
    SELECT *,
      ROW_NUMBER() OVER (
        PARTITION BY lift_name
        ORDER BY time DESC
      ) AS recency
    FROM combined_locations
  ),
-- Step 3 
  cleaned_lift_list as (
    SELECT lift_name,
      CAST(REPLACE (deck, 'Deck ', '') as FLOAT) as deck
    FROM found_latest_location
    where recency = 1
  ),
-- Step 4
  categorised_issues AS (
    SELECT lift_name, malfunction,
      CASE
		WHEN malfunction = 'Flooded'
        OR malfunction = 'Short circuit' THEN 1
        ELSE 0
      END AS risk_of_electrocution,
      CASE
        WHEN malfunction = 'Broken drive shaft'
        OR 'Loss of oxygen' THEN 1
        ELSE 0
      END AS inoperable,
      CASE
        WHEN malfunction = 'Lubricant leak' THEN 1
        ELSE 0
      END AS noisy
    FROM lift_malfunctions
  ),
  -- Step 5
  usable_lifts AS (
    SELECT lift_name,
      sum(noisy) AS noisy
    FROM categorised_issues
    GROUP BY lift_name
    HAVING
      sum(risk_of_electrocution) < 2
      AND inoperable = 0
  )
SELECT *
FROM cleaned_lift_list
  JOIN usable_lifts ON cleaned_lift_list.lift_name = usable_lifts.lift_name
WHERE
  deck < 2 
  Location
FROM lift_locations_2
  END)
  
-- Chapter 20
DELETE FROM readings
WHERE timestamp > '1962-06-04'