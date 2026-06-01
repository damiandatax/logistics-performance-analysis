SELECT *
FROM trips
WHERE driver_id = '';

SELECT 
    COUNT(*) AS total_trips,
    SUM(
        CASE
            WHEN driver_id = '' THEN 1
            ELSE 0
        END
    ) AS missing_driver_id,
    ROUND(
        SUM(
            CASE
                WHEN driver_id = '' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS missing_driver_pct
FROM trips;