
-- Refresh functions for dashboard aggregate tables.
-- Your background worker should call these functions.

CREATE OR REPLACE FUNCTION public.analytics_channel(p_source text, p_medium text)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE
    WHEN lower(coalesce(p_medium, '')) = 'organic' THEN 'Organic Search'
    WHEN lower(coalesce(p_medium, '')) IN ('cpc', 'ppc', 'paid', 'paid_search') THEN 'Paid Search'
    WHEN lower(coalesce(p_medium, '')) LIKE '%social%'
      OR lower(coalesce(p_source, '')) IN ('instagram', 'facebook', 'linkedin', 'twitter', 'x', 'youtube') THEN 'Social Media'
    WHEN lower(coalesce(p_medium, '')) = 'email'
      OR lower(coalesce(p_source, '')) = 'newsletter' THEN 'Email'
    WHEN lower(coalesce(p_source, '')) IN ('direct', '(direct)')
      OR lower(coalesce(p_medium, '')) IN ('none', '(none)') THEN 'Direct'
    ELSE 'Referral'
  END
$$;


CREATE OR REPLACE FUNCTION public.refresh_daily_metrics(
  p_project_id text DEFAULT NULL,
  p_from date DEFAULT (current_date - interval '30 days')::date,
  p_to date DEFAULT current_date
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM public.daily_metrics dm
  WHERE dm.date BETWEEN p_from AND p_to
    AND (p_project_id IS NULL OR dm.project_id = p_project_id);

  INSERT INTO public.daily_metrics (
    project_id, date, country,
    users, sessions, pageviews, transactions, revenue, conversion_rate,
    engaged_sessions, engagement_rate, bounce_rate,
    mobile_sessions, desktop_sessions, tablet_sessions,
    organic_sessions, paid_sessions, social_sessions, direct_sessions,
    visitors, product_view_sessions, add_to_cart_sessions, checkout_sessions, purchase_sessions,
    updated_at
  )
  WITH event_session_flags AS (
    SELECT
      s.project_id,
      s.id AS session_id,
      s.user_id,
      s.anonymous_id,
      date(s.started_at) AS date,
      coalesce(s.country, 'Unknown') AS country,
      lower(coalesce(s.device, s.platform, 'unknown')) AS device_type,
      lower(coalesce(s.source, 'direct')) AS source,
      lower(coalesce(s.medium, 'none')) AS medium,
      coalesce(s.bounced, false) AS bounced,
      coalesce(s.duration, 0) AS duration,

      count(e.id) FILTER (WHERE e.event = 'page_view') AS pageviews,
      bool_or(e.event = 'product_view') AS has_product_view,
      bool_or(e.event = 'add_to_cart') AS has_add_to_cart,
      bool_or(e.event IN ('checkout_started', 'begin_checkout')) AS has_checkout,
      bool_or(e.event = 'purchase') AS has_purchase,
      coalesce(sum(e.value) FILTER (WHERE e.event = 'purchase'), 0) AS revenue
    FROM public.sessions s
    LEFT JOIN public.events e
      ON e.project_id = s.project_id
     AND e.session_id = s.id
    WHERE date(s.started_at) BETWEEN p_from AND p_to
      AND (p_project_id IS NULL OR s.project_id = p_project_id)
    GROUP BY
      s.project_id, s.id, s.user_id, s.anonymous_id, date(s.started_at),
      coalesce(s.country, 'Unknown'), lower(coalesce(s.device, s.platform, 'unknown')),
      lower(coalesce(s.source, 'direct')), lower(coalesce(s.medium, 'none')),
      coalesce(s.bounced, false), coalesce(s.duration, 0)
  )
  SELECT
    project_id,
    date,
    country,

    count(DISTINCT coalesce(user_id, anonymous_id, session_id)) AS users,
    count(DISTINCT session_id) AS sessions,
    coalesce(sum(pageviews), 0) AS pageviews,
    count(*) FILTER (WHERE has_purchase) AS transactions,
    round(coalesce(sum(revenue), 0)::numeric, 2) AS revenue,

    coalesce((count(*) FILTER (WHERE has_purchase))::numeric / nullif(count(DISTINCT session_id), 0), 0) AS conversion_rate,

    count(*) FILTER (WHERE bounced = false AND (duration >= 10 OR pageviews > 1 OR has_product_view OR has_add_to_cart OR has_checkout OR has_purchase)) AS engaged_sessions,
    coalesce(
      (count(*) FILTER (WHERE bounced = false AND (duration >= 10 OR pageviews > 1 OR has_product_view OR has_add_to_cart OR has_checkout OR has_purchase)))::numeric
      / nullif(count(DISTINCT session_id), 0),
      0
    ) AS engagement_rate,
    coalesce(
      (count(*) FILTER (WHERE bounced = true))::numeric / nullif(count(DISTINCT session_id), 0),
      0
    ) AS bounce_rate,

    count(*) FILTER (WHERE device_type = 'mobile') AS mobile_sessions,
    count(*) FILTER (WHERE device_type = 'desktop') AS desktop_sessions,
    count(*) FILTER (WHERE device_type = 'tablet') AS tablet_sessions,

    count(*) FILTER (WHERE medium = 'organic') AS organic_sessions,
    count(*) FILTER (WHERE medium IN ('cpc', 'ppc', 'paid', 'paid_search')) AS paid_sessions,
    count(*) FILTER (WHERE medium LIKE '%social%') AS social_sessions,
    count(*) FILTER (WHERE source IN ('direct', '(direct)') OR medium IN ('none', '(none)')) AS direct_sessions,

    count(DISTINCT coalesce(user_id, anonymous_id, session_id)) AS visitors,

    count(*) FILTER (WHERE has_product_view) AS product_view_sessions,
    count(*) FILTER (WHERE has_add_to_cart) AS add_to_cart_sessions,
    count(*) FILTER (WHERE has_checkout) AS checkout_sessions,
    count(*) FILTER (WHERE has_purchase) AS purchase_sessions,

    now()
  FROM event_session_flags
  GROUP BY project_id, date, country;
END;
$$;


CREATE OR REPLACE FUNCTION public.refresh_fact_channel_performance(
  p_project_id text DEFAULT NULL,
  p_from date DEFAULT (current_date - interval '30 days')::date,
  p_to date DEFAULT current_date
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM public.fact_channel_performance f
  WHERE f.date BETWEEN p_from AND p_to
    AND (p_project_id IS NULL OR f.project_id = p_project_id);

  INSERT INTO public.fact_channel_performance (
    project_id, date, acquisition_channel, sessions, users, conversions, conversion_rate, revenue, updated_at
  )
  WITH session_level AS (
    SELECT
      s.project_id,
      date(s.started_at) AS date,
      public.analytics_channel(s.source, s.medium) AS acquisition_channel,
      s.id AS session_id,
      coalesce(s.user_id, s.anonymous_id, s.id) AS user_key,
      bool_or(e.event = 'purchase') AS has_purchase,
      coalesce(sum(e.value) FILTER (WHERE e.event = 'purchase'), 0) AS revenue
    FROM public.sessions s
    LEFT JOIN public.events e
      ON e.project_id = s.project_id
     AND e.session_id = s.id
    WHERE date(s.started_at) BETWEEN p_from AND p_to
      AND (p_project_id IS NULL OR s.project_id = p_project_id)
    GROUP BY s.project_id, date(s.started_at), public.analytics_channel(s.source, s.medium), s.id, coalesce(s.user_id, s.anonymous_id, s.id)
  )
  SELECT
    project_id,
    date,
    acquisition_channel,
    count(DISTINCT session_id) AS sessions,
    count(DISTINCT user_key) AS users,
    count(*) FILTER (WHERE has_purchase) AS conversions,
    coalesce((count(*) FILTER (WHERE has_purchase))::numeric / nullif(count(DISTINCT session_id), 0), 0) AS conversion_rate,
    round(coalesce(sum(revenue), 0)::numeric, 2) AS revenue,
    now()
  FROM session_level
  GROUP BY project_id, date, acquisition_channel;
END;
$$;


CREATE OR REPLACE FUNCTION public.refresh_fact_page_performance(
  p_project_id text DEFAULT NULL,
  p_from date DEFAULT (current_date - interval '30 days')::date,
  p_to date DEFAULT current_date
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM public.fact_page_performance f
  WHERE f.date BETWEEN p_from AND p_to
    AND (p_project_id IS NULL OR f.project_id = p_project_id);

  INSERT INTO public.fact_page_performance (
    project_id, date, page_location, views, users, sessions, avg_time_seconds, bounce_rate, conversions, updated_at
  )
  WITH page_events AS (
    SELECT
      e.project_id,
      date(e.ts) AS date,
      coalesce(e.path, e.page_url, e.url, '/') AS page_location,
      e.session_id,
      coalesce(e.user_id, e.anonymous_id, e.session_id) AS user_key,
      e.event,
      s.duration,
      s.bounced
    FROM public.events e
    LEFT JOIN public.sessions s
      ON s.project_id = e.project_id
     AND s.id = e.session_id
    WHERE date(e.ts) BETWEEN p_from AND p_to
      AND (p_project_id IS NULL OR e.project_id = p_project_id)
      AND coalesce(e.path, e.page_url, e.url) IS NOT NULL
  )
  SELECT
    project_id,
    date,
    page_location,
    count(*) FILTER (WHERE event = 'page_view') AS views,
    count(DISTINCT user_key) AS users,
    count(DISTINCT session_id) AS sessions,
    round(coalesce(avg(duration), 0)::numeric, 2) AS avg_time_seconds,
    coalesce((count(DISTINCT session_id) FILTER (WHERE bounced = true))::numeric / nullif(count(DISTINCT session_id), 0), 0) AS bounce_rate,
    count(*) FILTER (WHERE event = 'purchase') AS conversions,
    now()
  FROM page_events
  GROUP BY project_id, date, page_location;
END;
$$;


CREATE OR REPLACE FUNCTION public.refresh_fact_product_revenue(
  p_project_id text DEFAULT NULL,
  p_from date DEFAULT (current_date - interval '30 days')::date,
  p_to date DEFAULT current_date
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM public.fact_product_revenue f
  WHERE f.date BETWEEN p_from AND p_to
    AND (p_project_id IS NULL OR f.project_id = p_project_id);

  INSERT INTO public.fact_product_revenue (
    project_id, date, product_id, item_name, item_brand, item_category, units_sold, revenue, transactions, updated_at
  )
  SELECT
    e.project_id,
    date(e.ts) AS date,
    coalesce(e.product_id, 'unknown') AS product_id,
    coalesce(e.event_properties ->> 'item_name', e.event_properties ->> 'product_name', e.product_id, 'Unknown Product') AS item_name,
    coalesce(e.event_properties ->> 'item_brand', e.event_properties ->> 'brand') AS item_brand,
    coalesce(e.category, e.event_properties ->> 'item_category', 'uncategorized') AS item_category,
    coalesce(sum(e.quantity), 0) AS units_sold,
    round(coalesce(sum(e.value), 0)::numeric, 2) AS revenue,
    count(DISTINCT coalesce(e.order_id, e.id)) AS transactions,
    now()
  FROM public.events e
  WHERE date(e.ts) BETWEEN p_from AND p_to
    AND (p_project_id IS NULL OR e.project_id = p_project_id)
    AND e.event = 'purchase'
  GROUP BY
    e.project_id,
    date(e.ts),
    coalesce(e.product_id, 'unknown'),
    coalesce(e.event_properties ->> 'item_name', e.event_properties ->> 'product_name', e.product_id, 'Unknown Product'),
    coalesce(e.event_properties ->> 'item_brand', e.event_properties ->> 'brand'),
    coalesce(e.category, e.event_properties ->> 'item_category', 'uncategorized');
END;
$$;


CREATE OR REPLACE FUNCTION public.refresh_fact_cohort_retention(
  p_project_id text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM public.fact_cohort_retention f
  WHERE p_project_id IS NULL OR f.project_id = p_project_id;

  INSERT INTO public.fact_cohort_retention (
    project_id, cohort_month, month_number, users_retained, cohort_users, retention_rate, updated_at
  )
  WITH user_sessions AS (
    SELECT
      project_id,
      coalesce(user_id, anonymous_id) AS user_key,
      date_trunc('month', started_at)::date AS activity_month
    FROM public.sessions
    WHERE coalesce(user_id, anonymous_id) IS NOT NULL
      AND (p_project_id IS NULL OR project_id = p_project_id)
    GROUP BY project_id, coalesce(user_id, anonymous_id), date_trunc('month', started_at)::date
  ),
  user_first_visit AS (
    SELECT
      project_id,
      user_key,
      min(activity_month) AS cohort_month
    FROM user_sessions
    GROUP BY project_id, user_key
  ),
  cohort_activity AS (
    SELECT
      ufv.project_id,
      ufv.cohort_month,
      us.activity_month,
      ((extract(year FROM us.activity_month)::int - extract(year FROM ufv.cohort_month)::int) * 12
        + (extract(month FROM us.activity_month)::int - extract(month FROM ufv.cohort_month)::int)) AS month_number,
      us.user_key
    FROM user_first_visit ufv
    JOIN user_sessions us
      ON us.project_id = ufv.project_id
     AND us.user_key = ufv.user_key
  ),
  cohort_counts AS (
    SELECT
      project_id,
      cohort_month,
      month_number,
      count(DISTINCT user_key) AS users_retained
    FROM cohort_activity
    WHERE month_number BETWEEN 0 AND 12
    GROUP BY project_id, cohort_month, month_number
  ),
  cohort_size AS (
    SELECT
      project_id,
      cohort_month,
      count(DISTINCT user_key) AS cohort_users
    FROM user_first_visit
    GROUP BY project_id, cohort_month
  )
  SELECT
    c.project_id,
    c.cohort_month,
    c.month_number,
    c.users_retained,
    cs.cohort_users,
    coalesce(c.users_retained::numeric / nullif(cs.cohort_users, 0), 0) AS retention_rate,
    now()
  FROM cohort_counts c
  JOIN cohort_size cs
    ON cs.project_id = c.project_id
   AND cs.cohort_month = c.cohort_month;
END;
$$;


CREATE OR REPLACE FUNCTION public.refresh_all_dashboard_aggregates(
  p_project_id text DEFAULT NULL,
  p_from date DEFAULT (current_date - interval '30 days')::date,
  p_to date DEFAULT current_date
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM public.refresh_daily_metrics(p_project_id, p_from, p_to);
  PERFORM public.refresh_fact_channel_performance(p_project_id, p_from, p_to);
  PERFORM public.refresh_fact_page_performance(p_project_id, p_from, p_to);
  PERFORM public.refresh_fact_product_revenue(p_project_id, p_from, p_to);
  PERFORM public.refresh_fact_cohort_retention(p_project_id);
END;
$$;
