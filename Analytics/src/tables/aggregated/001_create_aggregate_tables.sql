
-- Supabase/PostgreSQL aggregate tables for your own tracker.
-- Source tables:
--   public.events
--   public.sessions
-- Project metadata:
--   app.projects

-- 1) Daily overview metrics
CREATE TABLE IF NOT EXISTS public.daily_metrics (
  project_id text NOT NULL REFERENCES app.projects(id) ON DELETE CASCADE,
  date date NOT NULL,
  country text NOT NULL DEFAULT 'Unknown',

  users bigint NOT NULL DEFAULT 0,
  sessions bigint NOT NULL DEFAULT 0,
  pageviews bigint NOT NULL DEFAULT 0,
  transactions bigint NOT NULL DEFAULT 0,
  revenue numeric(14,2) NOT NULL DEFAULT 0,

  conversion_rate numeric(12,6) NOT NULL DEFAULT 0,

  engaged_sessions bigint NOT NULL DEFAULT 0,
  engagement_rate numeric(12,6) NOT NULL DEFAULT 0,
  bounce_rate numeric(12,6) NOT NULL DEFAULT 0,

  mobile_sessions bigint NOT NULL DEFAULT 0,
  desktop_sessions bigint NOT NULL DEFAULT 0,
  tablet_sessions bigint NOT NULL DEFAULT 0,

  organic_sessions bigint NOT NULL DEFAULT 0,
  paid_sessions bigint NOT NULL DEFAULT 0,
  social_sessions bigint NOT NULL DEFAULT 0,
  direct_sessions bigint NOT NULL DEFAULT 0,

  visitors bigint NOT NULL DEFAULT 0,

  product_view_sessions bigint NOT NULL DEFAULT 0,
  add_to_cart_sessions bigint NOT NULL DEFAULT 0,
  checkout_sessions bigint NOT NULL DEFAULT 0,
  purchase_sessions bigint NOT NULL DEFAULT 0,

  updated_at timestamptz NOT NULL DEFAULT now(),

  PRIMARY KEY (project_id, date, country)
);

CREATE INDEX IF NOT EXISTS idx_daily_metrics_project_date
  ON public.daily_metrics(project_id, date DESC);


-- 2) Channel performance
CREATE TABLE IF NOT EXISTS public.fact_channel_performance (
  project_id text NOT NULL REFERENCES app.projects(id) ON DELETE CASCADE,
  date date NOT NULL,
  acquisition_channel text NOT NULL,

  sessions bigint NOT NULL DEFAULT 0,
  users bigint NOT NULL DEFAULT 0,
  conversions bigint NOT NULL DEFAULT 0,
  conversion_rate numeric(12,6) NOT NULL DEFAULT 0,
  revenue numeric(14,2) NOT NULL DEFAULT 0,

  updated_at timestamptz NOT NULL DEFAULT now(),

  PRIMARY KEY (project_id, date, acquisition_channel)
);

CREATE INDEX IF NOT EXISTS idx_channel_project_date
  ON public.fact_channel_performance(project_id, date DESC);


-- 3) Page performance
CREATE TABLE IF NOT EXISTS public.fact_page_performance (
  project_id text NOT NULL REFERENCES app.projects(id) ON DELETE CASCADE,
  date date NOT NULL,
  page_location text NOT NULL,

  views bigint NOT NULL DEFAULT 0,
  users bigint NOT NULL DEFAULT 0,
  sessions bigint NOT NULL DEFAULT 0,
  avg_time_seconds numeric(12,2) NOT NULL DEFAULT 0,
  bounce_rate numeric(12,6) NOT NULL DEFAULT 0,
  conversions bigint NOT NULL DEFAULT 0,

  updated_at timestamptz NOT NULL DEFAULT now(),

  PRIMARY KEY (project_id, date, page_location)
);

CREATE INDEX IF NOT EXISTS idx_page_project_date
  ON public.fact_page_performance(project_id, date DESC);

CREATE INDEX IF NOT EXISTS idx_page_project_location
  ON public.fact_page_performance(project_id, page_location);


-- 4) Product revenue
CREATE TABLE IF NOT EXISTS public.fact_product_revenue (
  project_id text NOT NULL REFERENCES app.projects(id) ON DELETE CASCADE,
  date date NOT NULL,

  product_id text NOT NULL,
  item_name text,
  item_brand text,
  item_category text,

  units_sold bigint NOT NULL DEFAULT 0,
  revenue numeric(14,2) NOT NULL DEFAULT 0,
  transactions bigint NOT NULL DEFAULT 0,

  updated_at timestamptz NOT NULL DEFAULT now(),

  PRIMARY KEY (project_id, date, product_id)
);

CREATE INDEX IF NOT EXISTS idx_product_project_date
  ON public.fact_product_revenue(project_id, date DESC);


-- 5) Cohort retention
CREATE TABLE IF NOT EXISTS public.fact_cohort_retention (
  project_id text NOT NULL REFERENCES app.projects(id) ON DELETE CASCADE,
  cohort_month date NOT NULL,
  month_number int NOT NULL,

  users_retained bigint NOT NULL DEFAULT 0,
  cohort_users bigint NOT NULL DEFAULT 0,
  retention_rate numeric(12,6) NOT NULL DEFAULT 0,

  updated_at timestamptz NOT NULL DEFAULT now(),

  PRIMARY KEY (project_id, cohort_month, month_number)
);

CREATE INDEX IF NOT EXISTS idx_cohort_project_month
  ON public.fact_cohort_retention(project_id, cohort_month DESC);
