CREATE OR REPLACE VIEW executive_dashboard_view AS
SELECT
    ROUND(SUM(l.revenue)::numeric, 2) AS total_revenue,
    COUNT(t.trip_id) AS total_trips,
    ROUND(AVG(t.average_mpg)::numeric, 2) AS fleet_avg_mpg,
    ROUND(AVG(t.idle_time_hours)::numeric, 2) AS fleet_avg_idle_time,
    COUNT(DISTINCT l.customer_id) AS active_customers,
    COUNT(DISTINCT l.route_id) AS active_routes,
    COUNT(DISTINCT t.driver_id) AS active_drivers
FROM trips t
JOIN loads l
    ON l.load_id = t.load_id;


SELECT *
FROM executive_dashboard_view;