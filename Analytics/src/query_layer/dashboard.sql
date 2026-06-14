-- OVERVIEW QUERY LAYER
-- PostgreSQL/Supabase version
-- Params:
--   $1 = project_id text
--   $2 = period text: 'today' | '7d' | '30d' | '90d' | 'custom'
--   $3 = custom_start_date date nullable
--   $4 = custom_end_date date nullable
--
-- Source: public.v_daily_metrics_global

WITH params AS (
  SELECT
    $1::text AS project_id,
    COALESCE($2::text, '30d') AS period,
    CASE
      WHEN COALESCE($2::text, '30d') = 'custom' THEN $3::date
      WHEN COALESCE($2::text, '30d') = 'today'  THEN current_date
      WHEN COALESCE($2::text, '30d') = '7d'     THEN current_date - interval '6 days'
      WHEN COALESCE($2::text, '30d') = '30d'    THEN current_date - interval '29 days'
      WHEN COALESCE($2::text, '30d') = '90d'    THEN current_date - interval '89 days'
      ELSE current_date - interval '29 days'
    END::date AS start_date,
    CASE
      WHEN COALESCE($2::text, '30d') = 'custom' THEN $4::date
      ELSE current_date
    END::date AS end_date
),
base AS (
  SELECT v.*
  FROM public.v_daily_metrics_global v
  JOIN params p ON p.project_id = v.project_id
  WHERE v.date BETWEEN p.start_date AND p.end_date
)
SELECT
  COALESCE(SUM(users), 0)::bigint AS users,
  COALESCE(SUM(visitors), 0)::bigint AS visitors,
  COALESCE(SUM(sessions), 0)::bigint AS sessions,
  COALESCE(SUM(pageviews), 0)::bigint AS pageviews,
  COALESCE(SUM(transactions), 0)::bigint AS transactions,
  ROUND(COALESCE(SUM(revenue), 0)::numeric, 2) AS revenue,

  ROUND(COALESCE(SUM(transactions)::numeric / NULLIF(SUM(sessions), 0), 0) * 100, 2) AS conversion_rate,

  COALESCE(SUM(engaged_sessions), 0)::bigint AS engaged_sessions,
  ROUND(COALESCE(SUM(engaged_sessions)::numeric / NULLIF(SUM(sessions), 0), 0) * 100, 2) AS engagement_rate,
  ROUND(COALESCE((SUM(sessions) - SUM(engaged_sessions))::numeric / NULLIF(SUM(sessions), 0), 0) * 100, 2) AS bounce_rate,

  COALESCE(SUM(mobile_sessions), 0)::bigint AS mobile_sessions,
  COALESCE(SUM(desktop_sessions), 0)::bigint AS desktop_sessions,
  COALESCE(SUM(tablet_sessions), 0)::bigint AS tablet_sessions,

  COALESCE(SUM(organic_sessions), 0)::bigint AS organic_sessions,
  COALESCE(SUM(paid_sessions), 0)::bigint AS paid_sessions,
  COALESCE(SUM(social_sessions), 0)::bigint AS social_sessions,
  COALESCE(SUM(direct_sessions), 0)::bigint AS direct_sessions,

  COALESCE(SUM(product_view_sessions), 0)::bigint AS product_view_sessions,
  COALESCE(SUM(add_to_cart_sessions), 0)::bigint AS add_to_cart_sessions,
  COALESCE(SUM(checkout_sessions), 0)::bigint AS checkout_sessions,
  COALESCE(SUM(purchase_sessions), 0)::bigint AS purchase_sessions
FROM base;
