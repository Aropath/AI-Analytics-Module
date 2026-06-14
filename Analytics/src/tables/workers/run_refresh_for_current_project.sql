
-- Run this after creating aggregate tables + refresh functions.
-- It refreshes all dashboard aggregates for your current project.

SELECT public.refresh_all_dashboard_aggregates(
  'eb16114f-d4ec-4652-80e0-aa4ffb3f25f7',
  (current_date - interval '60 days')::date,
  current_date
);

-- Quick checks
SELECT * FROM public.v_daily_metrics_global
WHERE project_id = 'eb16114f-d4ec-4652-80e0-aa4ffb3f25f7'
ORDER BY date DESC
LIMIT 10;

SELECT * FROM public.v_channel_performance
WHERE project_id = 'eb16114f-d4ec-4652-80e0-aa4ffb3f25f7'
ORDER BY date DESC, sessions DESC
LIMIT 20;

SELECT * FROM public.v_page_performance
WHERE project_id = 'eb16114f-d4ec-4652-80e0-aa4ffb3f25f7'
ORDER BY date DESC, views DESC
LIMIT 20;

SELECT * FROM public.v_product_revenue
WHERE project_id = 'eb16114f-d4ec-4652-80e0-aa4ffb3f25f7'
ORDER BY date DESC, revenue DESC
LIMIT 20;
