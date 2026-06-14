-- ACQUISITION CHANNELS QUERY
-- Params:
--   $1 = project_id text
--   $2 = period text: 'today' | '7d' | '30d' | '90d' | 'custom'
--   $3 = custom_start_date date nullable
--   $4 = custom_end_date date nullable
--
-- Source: public.v_channel_performance

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
channels AS (
  SELECT unnest(ARRAY[
    'Organic Search',
    'Paid Search',
    'Social Media',
    'Direct',
    'Email',
    'Referral'
  ]) AS acquisition_channel
),
agg AS (
  SELECT
    v.acquisition_channel,
    SUM(v.sessions) AS sessions,
    SUM(v.conversions) AS conversions,
    COALESCE(SUM(v.conversions)::numeric / NULLIF(SUM(v.sessions), 0), 0) AS conversion_rate,
    SUM(v.revenue) AS revenue
  FROM public.v_channel_performance v
  JOIN params p ON p.project_id = v.project_id
  WHERE v.date BETWEEN p.start_date AND p.end_date
  GROUP BY v.acquisition_channel
)
SELECT
  c.acquisition_channel AS source,
  COALESCE(a.sessions, 0)::bigint AS sessions,
  COALESCE(a.conversions, 0)::bigint AS conversions,
  ROUND(COALESCE(a.conversion_rate, 0) * 100, 2) AS conversion_rate,
  ROUND(COALESCE(a.revenue, 0)::numeric, 2) AS revenue
FROM channels c
LEFT JOIN agg a ON a.acquisition_channel = c.acquisition_channel
ORDER BY
  CASE c.acquisition_channel
    WHEN 'Organic Search' THEN 1
    WHEN 'Paid Search' THEN 2
    WHEN 'Social Media' THEN 3
    WHEN 'Direct' THEN 4
    WHEN 'Email' THEN 5
    WHEN 'Referral' THEN 6
    ELSE 99
  END;
