CREATE TABLE IF NOT EXISTS app.checklist (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id text NOT NULL REFERENCES app.projects(id) ON DELETE CASCADE,
  rule_id text NOT NULL,
  title text NOT NULL,
  reason text NOT NULL,
  difficulty text NOT NULL,
  impact text NOT NULL,
  priority_score numeric NOT NULL DEFAULT 0,
  estimated_revenue_lift numeric NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'pending',
  cycle_start date NOT NULL DEFAULT current_date,
  cycle_end date NOT NULL DEFAULT current_date + interval '30 days',
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_checklist_project_cycle
ON app.checklist(project_id, cycle_start, cycle_end);

CREATE UNIQUE INDEX IF NOT EXISTS uq_checklist_project_rule_cycle
ON app.checklist(project_id, rule_id, cycle_start);