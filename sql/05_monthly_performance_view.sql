DROP VIEW IF EXISTS monthly_performance_view;
CREATE OR REPLACE VIEW monthly_performance_view AS
WITH monthly_metrics AS (
    SELECT
        DATE_TRUNC('month', t.dispatch_date::date) AS month,
        ROUND(SUM(l.revenue)::numeric, 2) AS total_revenue,
        COUNT(t.trip_id) AS total_trips,
        ROUND(AVG(t.idle_time_hours)::numeric, 2) AS avg_idle_time
    FROM trips t
    JOIN loads l
        ON l.load_id = t.load_id
    GROUP BY DATE_TRUNC('month', t.dispatch_date::date)
),
monthly_growth AS (
    SELECT
        month,
        total_revenue,
        total_trips,
        avg_idle_time,
        LAG(total_revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue,
        ROUND(
            (
                total_revenue - LAG(total_revenue) OVER (ORDER BY month)
            ) / NULLIF(LAG(total_revenue) OVER (ORDER BY month), 0) * 100,
            2
        ) AS revenue_growth_pct,
        ROUND(
            AVG(total_revenue) OVER (
                ORDER BY month
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            )::numeric,
            2
        ) AS revenue_3_rolling_avg
    FROM monthly_metrics
)
SELECT
    month,
    total_revenue,
    total_trips,
    avg_idle_time,
    previous_month_revenue,
    revenue_growth_pct,
    revenue_3_rolling_avg,
    CASE
        WHEN revenue_growth_pct IS NULL THEN 'No previous month'
        WHEN revenue_growth_pct > 5 THEN 'Growth'
        WHEN revenue_growth_pct < -5 THEN 'Decline'
        ELSE 'Stable'
    END AS revenue_trend_category
FROM monthly_growth;


SELECT *
FROM monthly_performance_view
ORDER BY month;

