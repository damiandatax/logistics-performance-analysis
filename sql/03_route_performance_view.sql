CREATE OR REPLACE VIEW route_performance_view AS
SELECT
    l.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state,
   	r.origin_city || ' → ' || r.destination_city AS route_name,
    r.typical_distance_miles,
    r.base_rate_per_mile,
    r.fuel_surcharge_rate,
    r.typical_transit_days,
    COUNT(t.trip_id) AS total_trips,
    ROUND(
        SUM(l.revenue)::numeric,
        2
    ) AS total_revenue,
    ROUND(
        AVG(
            l.revenue / NULLIF(t.actual_distance_miles, 0)
        )::numeric,
        2
    ) AS avg_revenue_per_mile,
    ROUND(
        AVG(t.idle_time_hours)::numeric,
        2
    ) AS avg_idle_time,
    ROUND(
        AVG(t.average_mpg)::numeric,
        2
    ) AS avg_mpg,
    CASE
        WHEN AVG(
            l.revenue / NULLIF(t.actual_distance_miles, 0)
        ) >= 2.50
            THEN 'High profitability'
        WHEN AVG(
            l.revenue / NULLIF(t.actual_distance_miles, 0)
        ) >= 2.00
            THEN 'Medium profitability'
        ELSE 'Low profitability'
    END AS profitability_segment
FROM loads l
JOIN trips t
    ON t.load_id = l.load_id
JOIN routes r
    ON r.route_id = l.route_id
GROUP BY
    l.route_id,
    r.origin_city,
    r.origin_state,
    r.destination_city,
    r.destination_state,
    r.typical_distance_miles,
    r.base_rate_per_mile,
    r.fuel_surcharge_rate,
    r.typical_transit_days;

SELECT *
FROM route_performance_view
ORDER BY avg_revenue_per_mile DESC
LIMIT 20;

SELECT
	route_id,
    route_name,
    total_revenue
FROM route_performance_view
ORDER BY total_revenue DESC
LIMIT 5;