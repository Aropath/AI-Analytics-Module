-- TOP COUNTRIES QUERY
-- Params:
--   $1 = project_id text
--   $2 = period text: 'today' | '7d' | '30d' | '90d' | 'custom'
--   $3 = custom_start_date date nullable
--   $4 = custom_end_date date nullable
--
-- Source: public.daily_metrics because country exists there, not in v_daily_metrics_global

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
)
SELECT
  COALESCE(dm.country, 'Unknown') AS country,
  COALESCE(SUM(dm.users), 0)::bigint AS users,
  COALESCE(SUM(dm.sessions), 0)::bigint AS sessions
FROM public.daily_metrics dm
JOIN params p ON p.project_id = dm.project_id
WHERE dm.date BETWEEN p.start_date AND p.end_date
GROUP BY COALESCE(dm.country, 'Unknown')
ORDER BY users DESC
LIMIT 5;
