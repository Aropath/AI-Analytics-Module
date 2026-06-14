-- COHORT RETENTION QUERY
-- Params:
--   $1 = project_id text
--   $2 = period text: 'today' | '7d' | '30d' | '90d' | 'custom'
--   $3 = custom_start_date date nullable
--   $4 = custom_end_date date nullable
--
-- Source: public.v_cohort_retention

WITH params AS (
  SELECT
    $1::text AS project_id,
    COALESCE($2::text, '30d') AS period,
    CASE
      WHEN COALESCE($2::text, '30d') = 'custom' THEN date_trunc('month', $3::date)::date
      WHEN COALESCE($2::text, '30d') = 'today'  THEN date_trunc('month', current_date)::date
      WHEN COALESCE($2::text, '30d') = '7d'     THEN date_trunc('month', current_date - interval '6 days')::date
      WHEN COALESCE($2::text, '30d') = '30d'    THEN date_trunc('month', current_date - interval '29 days')::date
      WHEN COALESCE($2::text, '30d') = '90d'    THEN date_trunc('month', current_date - interval '89 days')::date
      ELSE date_trunc('month', current_date - interval '29 days')::date
    END AS start_month,
    CASE
      WHEN COALESCE($2::text, '30d') = 'custom' THEN date_trunc('month', $4::date)::date
      ELSE date_trunc('month', current_date)::date
    END AS end_month
)
SELECT
  v.cohort_month,
  v.month_number,
  v.users_retained,
  v.cohort_users,
  ROUND(v.retention_rate * 100, 2) AS retention_rate
FROM public.v_cohort_retention v
JOIN params p ON p.project_id = v.project_id
WHERE v.cohort_month BETWEEN p.start_month AND p.end_month
ORDER BY v.cohort_month, v.month_number;
