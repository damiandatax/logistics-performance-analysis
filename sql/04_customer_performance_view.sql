CREATE VIEW customer_performance_view AS
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.customer_name,
        ROUND(SUM(l.revenue)::numeric, 2) AS total_revenue,
        COUNT(t.trip_id) AS total_trips,
        ROUND(AVG(l.revenue / NULLIF(t.actual_distance_miles, 0))::numeric, 2) AS avg_revenue_per_mile,
        ROUND(AVG(t.idle_time_hours)::numeric, 2) AS avg_idle_time
    FROM customers c
    JOIN loads l
        ON l.customer_id = c.customer_id
    JOIN trips t
        ON t.load_id = l.load_id
    GROUP BY c.customer_id, c.customer_name
),
customer_tiers AS (
    SELECT
        *,
        NTILE(4) OVER (
            ORDER BY total_revenue DESC
        ) AS customer_tier,
        ROUND(total_revenue / SUM(total_revenue) OVER () * 100, 2) AS revenue_share_pct
    FROM customer_metrics
)
SELECT
    customer_id,
    customer_name,
    total_revenue,
    total_trips,
    avg_revenue_per_mile,
    avg_idle_time,
    customer_tier,
    revenue_share_pct,
    CASE
        WHEN customer_tier = 1 THEN 'Strategic'
        WHEN customer_tier = 4 THEN 'Low value'
        ELSE 'Standard'
    END AS customer_segment
FROM customer_tiers;

SELECT
    customer_segment,
    COUNT(*) AS number_of_customers
FROM customer_performance_view
GROUP BY customer_segment
ORDER BY number_of_customers DESC;