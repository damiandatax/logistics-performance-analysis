DROP VIEW IF EXISTS driver_performance_view;
CREATE OR REPLACE VIEW driver_performance_view AS
SELECT
    d.driver_id,
    d.first_name,
    d.last_name,
    COUNT(t.trip_id) AS total_trips,
    ROUND(SUM(l.revenue)::numeric, 2) 						AS total_revenue,
    ROUND(AVG(l.revenue)::numeric, 2) 						AS avg_revenue_per_trip,
    ROUND(AVG(t.actual_distance_miles)::numeric, 2) 		AS avg_distance_miles,
    ROUND(AVG(t.fuel_gallons_used)::numeric, 2) 			AS avg_fuel_used,
    ROUND(AVG(t.average_mpg)::numeric, 2) 					AS avg_mpg,
    ROUND(AVG(t.idle_time_hours)::numeric, 2) 				AS avg_idle_time,
    CASE
        WHEN AVG(t.average_mpg) >= 6.52
            AND AVG(t.idle_time_hours) <= 7.05
            THEN 'High Performer'
        WHEN AVG(t.average_mpg) < 6.49
            OR AVG(t.idle_time_hours) > 7.10
            THEN 'Development Needed'
        ELSE 'Standard'
    END AS driver_segment
FROM drivers d
JOIN trips t
    ON t.driver_id = d.driver_id
JOIN loads l
	ON t.load_id = l.load_id
WHERE t.driver_id <> ''
GROUP BY
    d.driver_id,
    d.first_name,
    d.last_name;


SELECT *
FROM driver_performance_view
ORDER BY avg_mpg DESC
LIMIT 20;


SELECT
    driver_segment,
    COUNT(*) AS number_of_drivers,
    ROUND(AVG(total_trips)::numeric, 2) 				AS avg_trips_per_driver,
    ROUND(AVG(avg_distance_miles)::numeric, 2) 			AS avg_distance_miles,
    ROUND(AVG(avg_mpg)::numeric, 2) 					AS avg_mpg,
    ROUND(AVG(avg_idle_time)::numeric, 2) 				AS avg_idle_time
FROM driver_performance_view
GROUP BY driver_segment
ORDER BY avg_mpg DESC;

SELECT
    first_name || ' ' || last_name AS driver_name,
    total_trips,
    total_revenue,
    avg_revenue_per_trip,
    avg_mpg,
    avg_idle_time,
    driver_segment
FROM public.driver_performance_view
ORDER BY total_revenue DESC
LIMIT 10;
