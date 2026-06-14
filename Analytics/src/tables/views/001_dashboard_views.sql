
-- Dashboard-facing views.

CREATE OR REPLACE VIEW public.v_daily_metrics_global AS
SELECT
  project_id,
  date,

  sum(users) AS users,
  sum(sessions) AS sessions,
  sum(pageviews) AS pageviews,
  sum(transactions) AS transactions,
  round(sum(revenue)::numeric, 2) AS revenue,

  coalesce(sum(transactions)::numeric / nullif(sum(sessions), 0), 0) AS conversion_rate,

  sum(engaged_sessions) AS engaged_sessions,
  coalesce(sum(engaged_sessions)::numeric / nullif(sum(sessions), 0), 0) AS engagement_rate,
  coalesce((sum(sessions) - sum(engaged_sessions))::numeric / nullif(sum(sessions), 0), 0) AS bounce_rate,

  sum(mobile_sessions) AS mobile_sessions,
  sum(desktop_sessions) AS desktop_sessions,
  sum(tablet_sessions) AS tablet_sessions,

  sum(organic_sessions) AS organic_sessions,
  sum(paid_sessions) AS paid_sessions,
  sum(social_sessions) AS social_sessions,
  sum(direct_sessions) AS direct_sessions,

  sum(visitors) AS visitors,

  sum(product_view_sessions) AS product_view_sessions,
  sum(add_to_cart_sessions) AS add_to_cart_sessions,
  sum(checkout_sessions) AS checkout_sessions,
  sum(purchase_sessions) AS purchase_sessions,

  max(updated_at) AS updated_at
FROM public.daily_metrics
GROUP BY project_id, date;


CREATE OR REPLACE VIEW public.v_channel_performance AS
SELECT
  project_id,
  date,
  acquisition_channel,
  sessions,
  users,
  conversions,
  coalesce(conversions::numeric / nullif(sessions, 0), 0) AS conversion_rate,
  revenue,
  updated_at
FROM public.fact_channel_performance;


CREATE OR REPLACE VIEW public.v_page_performance AS
SELECT
  project_id,
  date,
  page_location,
  views,
  users,
  sessions,
  avg_time_seconds,
  bounce_rate,
  conversions,
  updated_at
FROM public.fact_page_performance;


CREATE OR REPLACE VIEW public.v_product_revenue AS
SELECT
  project_id,
  date,
  product_id AS item_id,
  item_name,
  item_brand,
  item_category,
  units_sold,
  revenue,
  transactions,
  updated_at
FROM public.fact_product_revenue;


CREATE OR REPLACE VIEW public.v_cohort_retention AS
SELECT
  project_id,
  cohort_month,
  month_number,
  users_retained,
  cohort_users,
  retention_rate,
  updated_at
FROM public.fact_cohort_retention;
