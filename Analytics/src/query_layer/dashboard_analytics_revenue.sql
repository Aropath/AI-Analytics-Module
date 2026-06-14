-- PRODUCT REVENUE QUERY
-- Params:
--   $1 = project_id text
--   $2 = period text: 'today' | '7d' | '30d' | '90d' | 'custom'
--   $3 = custom_start_date date nullable
--   $4 = custom_end_date date nullable
--
-- Source: public.v_product_revenue

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
  v.item_id,
  COALESCE(v.item_name, v.item_id) AS item_name,
  v.item_brand,
  v.item_category,
  COALESCE(SUM(v.units_sold), 0)::bigint AS units_sold,
  ROUND(COALESCE(SUM(v.revenue), 0)::numeric, 2) AS revenue,
  COALESCE(SUM(v.transactions), 0)::bigint AS transactions
FROM public.v_product_revenue v
JOIN params p ON p.project_id = v.project_id
WHERE v.date BETWEEN p.start_date AND p.end_date
GROUP BY v.item_id, v.item_name, v.item_brand, v.item_category
ORDER BY revenue DESC
LIMIT 6;
