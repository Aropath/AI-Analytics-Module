-- PAGE PERFORMANCE QUERY
-- Params:
--   $1 = project_id text
--   $2 = period text: 'today' | '7d' | '30d' | '90d' | 'custom'
--   $3 = custom_start_date date nullable
--   $4 = custom_end_date date nullable
--
-- Source: public.v_page_performance

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
  v.page_location,
  COALESCE(SUM(v.views), 0)::bigint AS views,
  COALESCE(SUM(v.users), 0)::bigint AS users,
  COALESCE(SUM(v.sessions), 0)::bigint AS sessions,
  ROUND(AVG(v.avg_time_seconds)::numeric, 2) AS avg_time_seconds,
  ROUND(AVG(v.bounce_rate)::numeric * 100, 2) AS bounce_rate,
  COALESCE(SUM(v.conversions), 0)::bigint AS conversions
FROM public.v_page_performance v
JOIN params p ON p.project_id = v.project_id
WHERE v.date BETWEEN p.start_date AND p.end_date
GROUP BY v.page_location
ORDER BY views DESC
LIMIT 10;
