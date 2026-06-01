CREATE OR REPLACE VIEW driver_segment_revenue_view AS
SELECT
    COALESCE(driver_segment, 'Unclassified') AS driver_segment,
    SUM(total_revenue) AS total_revenue
FROM driver_performance_view
GROUP BY 1;

SELECT *
FROM driver_segment_revenue_view
ORDER BY total_revenue DESC;

SELECT
    driver_segment,
    COUNT(*) AS drivers,
    SUM(total_revenue) AS revenue
FROM driver_performance_view
GROUP BY driver_segment
ORDER BY revenue DESC;

SELECT
    total_revenue
FROM driver_performance_view
ORDER BY total_revenue DESC
LIMIT 10;

CREATE OR REPLACE VIEW driver_segment_summary_view AS
SELECT
    driver_segment,
    COUNT(*) AS drivers,
    ROUND(AVG(avg_mpg)::numeric, 2) AS avg_mpg,
    ROUND(AVG(avg_idle_time)::numeric, 2) AS avg_idle_time,
    ROUND(AVG(total_trips)::numeric, 2) AS avg_trips
FROM driver_performance_view
GROUP BY driver_segment;

SELECT *
FROM driver_segment_summary_view
ORDER BY drivers DESC;