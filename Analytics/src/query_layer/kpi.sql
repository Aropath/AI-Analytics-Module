-- LONG RANGE KPI QUERY
-- Params:
--   $1 = project_id text
--
-- Source: public.v_daily_metrics_global
-- Note: This requires at least 730 days of aggregate data for YoY comparison to be meaningful.

WITH base AS (
  SELECT *
  FROM public.v_daily_metrics_global
  WHERE project_id = $1::text
),
current_period AS (
  SELECT *
  FROM base
  WHERE date >= current_date - interval '365 days'
),
previous_period AS (
  SELECT *
  FROM base
  WHERE date BETWEEN current_date - interval '730 days'
                 AND current_date - interval '366 days'
),
current_totals AS (
  SELECT
    COALESCE(SUM(revenue), 0) AS revenue_365,
    COALESCE(SUM(transactions), 0) AS conversions_365,
    COALESCE(SUM(users), 0) AS users_365,
    COALESCE(SUM(sessions), 0) AS sessions_365
  FROM current_period
),
previous_totals AS (
  SELECT
    COALESCE(SUM(revenue), 0) AS previous_revenue_365
  FROM previous_period
)
SELECT
  c.revenue_365,
  c.conversions_365,
  c.users_365,
  c.sessions_365,
  COALESCE(c.conversions_365::numeric / NULLIF(c.sessions_365, 0), 0) AS conversion_rate,
  COALESCE((c.revenue_365 - p.previous_revenue_365) / NULLIF(p.previous_revenue_365, 0), 0) AS revenue_growth
FROM current_totals c
CROSS JOIN previous_totals p;
