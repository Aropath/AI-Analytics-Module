-- TRAILING 12 MONTH METRICS QUERY
-- Params:
--   $1 = project_id text
--
-- Source: public.v_daily_metrics_global
-- Note: This is useful later for long-term analytics, not required for MVP Overview.

WITH raw AS (
  SELECT
    date,
    revenue,
    users,
    sessions,
    transactions
  FROM public.v_daily_metrics_global
  WHERE project_id = $1::text
),
ttm AS (
  SELECT
    date,
    revenue,
    users,
    sessions,
    transactions,

    SUM(revenue) OVER (
      ORDER BY date
      ROWS BETWEEN 364 PRECEDING AND CURRENT ROW
    ) AS ttm_revenue,

    SUM(users) OVER (
      ORDER BY date
      ROWS BETWEEN 364 PRECEDING AND CURRENT ROW
    ) AS ttm_users,

    SUM(sessions) OVER (
      ORDER BY date
      ROWS BETWEEN 364 PRECEDING AND CURRENT ROW
    ) AS ttm_sessions,

    SUM(transactions) OVER (
      ORDER BY date
      ROWS BETWEEN 364 PRECEDING AND CURRENT ROW
    ) AS ttm_transactions
  FROM raw
),
metrics AS (
  SELECT
    date,
    ttm_users,
    ttm_sessions,
    ttm_transactions,
    ttm_revenue,

    COALESCE(ttm_sessions::numeric / NULLIF(ttm_users, 0), 0) AS sessions_per_user,
    COALESCE(ttm_transactions::numeric / NULLIF(ttm_sessions, 0), 0) AS conversion_rate,
    COALESCE(ttm_transactions::numeric / NULLIF(ttm_users, 0), 0) AS transactions_per_user,

    COALESCE(ttm_revenue::numeric / NULLIF(ttm_users, 0), 0) AS revenue_per_user,
    COALESCE(ttm_revenue::numeric / NULLIF(ttm_sessions, 0), 0) AS revenue_per_session,
    COALESCE(ttm_revenue::numeric / NULLIF(ttm_transactions, 0), 0) AS average_order_value,

    COALESCE(
      (ttm_users - LAG(ttm_users, 365) OVER (ORDER BY date))::numeric
      / NULLIF(LAG(ttm_users, 365) OVER (ORDER BY date), 0),
      0
    ) AS user_growth_yoy,

    COALESCE(
      (ttm_sessions - LAG(ttm_sessions, 365) OVER (ORDER BY date))::numeric
      / NULLIF(LAG(ttm_sessions, 365) OVER (ORDER BY date), 0),
      0
    ) AS session_growth_yoy,

    COALESCE(
      (ttm_revenue - LAG(ttm_revenue, 365) OVER (ORDER BY date))::numeric
      / NULLIF(LAG(ttm_revenue, 365) OVER (ORDER BY date), 0),
      0
    ) AS revenue_growth_yoy
  FROM ttm
)
SELECT *
FROM metrics
ORDER BY date;
