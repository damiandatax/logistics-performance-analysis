WITH customer_revenue AS (
    SELECT
        c.customer_name,
        ROUND(SUM(l.revenue)::numeric, 2) AS total_revenue,
        COUNT(t.trip_id) AS total_trips
    FROM customers c
    JOIN loads l
        ON l.customer_id = c.customer_id
    JOIN trips t
        ON t.load_id = l.load_id
    GROUP BY c.customer_name
),
pareto AS (
    SELECT
        customer_name,
        total_revenue,
        total_trips,
        ROUND(total_revenue / SUM(total_revenue) OVER () * 100, 2) AS revenue_share_pct,
        ROUND(
            SUM(total_revenue) OVER (
                ORDER BY total_revenue DESC
            ) / SUM(total_revenue) OVER () * 100,
            2
        ) AS cumulative_revenue_pct
    FROM customer_revenue
)
SELECT
    customer_name,
    total_revenue,
    total_trips,
    revenue_share_pct,
    cumulative_revenue_pct,
    CASE
        WHEN cumulative_revenue_pct <= 80 THEN 'Top 80% Revenue'
        ELSE 'Remaining Customers'
    END AS pareto_segment
FROM pareto
ORDER BY total_revenue DESC;

-- Driver ranking analysis
SELECT
    driver_id,
    first_name,
    last_name,
    total_trips,
    avg_mpg,
    avg_idle_time,
    driver_segment,
    RANK() OVER (
        ORDER BY avg_mpg DESC
    ) AS mpg_rank,
    DENSE_RANK() OVER (
        ORDER BY avg_idle_time ASC
    ) AS idle_time_rank,
    NTILE(4) OVER (
        ORDER BY avg_mpg DESC
    ) AS mpg_tier
FROM driver_performance_view
ORDER BY mpg_rank;

-- Route ranking analysis
SELECT
    route_id,
    origin_city,
    destination_city,
    total_trips,
    total_revenue,
    avg_revenue_per_mile,
    avg_idle_time,
    profitability_segment,
    RANK() OVER (
        ORDER BY avg_revenue_per_mile DESC
    ) AS profitability_rank,
    NTILE(4) OVER (
        ORDER BY avg_revenue_per_mile DESC
    ) AS profitability_tier
FROM route_performance_view
ORDER BY profitability_rank;