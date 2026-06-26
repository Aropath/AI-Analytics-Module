import { query } from "./db";
import { fetchDashboardData } from "./dashboard";
import { fetchPagePerformance } from "./pagePerformance";
import { evaluateChecklistRules, ChecklistMetrics } from "./checklistRules";
import { calculatePriorityScore, calculateRevenueLift } from "./checklistScoring";

type ChecklistRow = {
  id: string;
  rule_id: string;
  title: string;
  reason: string;
  difficulty: string;
  impact: string;
  priority_score: string;
  estimated_revenue_lift: string;
  status: string;
  cycle_start: string;
  cycle_end: string;
  completed_at: string | null;
};

function num(value: unknown): number {
  const n = Number(value);
  return Number.isFinite(n) ? n : 0;
}

export async function fetchGrowthChecklist(
  projectId: string,
  period = "30d"
) {
  const existing = await query<ChecklistRow>(
    `
    SELECT *
    FROM app.checklist
    WHERE project_id = $1
      AND current_date BETWEEN cycle_start AND cycle_end
    ORDER BY priority_score DESC, created_at ASC
    LIMIT 8
    `,
    [projectId]
  );

  if (existing.length > 0) {
    return existing.map(formatChecklistRow);
  }

  const dashboard = await fetchDashboardData(projectId, period);
  const pages = await fetchPagePerformance(projectId, period);

  const sessions = num(dashboard.sessions);
  const directSessions = num(dashboard.direct_sessions);

  const metrics: ChecklistMetrics = {
    revenue: num(dashboard.revenue),
    sessions,
    conversionRate: num(dashboard.conversion_rate),
    bounceRate: num(dashboard.bounce_rate),
    directTrafficRate: sessions > 0 ? (directSessions / sessions) * 100 : 0,
    productViewSessions: num(dashboard.product_view_sessions),
    addToCartSessions: num(dashboard.add_to_cart_sessions),
    checkoutSessions: num(dashboard.checkout_sessions),
    purchaseSessions: num(dashboard.purchase_sessions),
    avgSessionDuration: 0,
    maxPageBounceRate: Math.max(
      0,
      ...pages.map((p: any) => num(p.bounce_rate))
    ),
  };

  const generated = evaluateChecklistRules(metrics)
    .map((rule) => ({
      ...rule,
      priorityScore: calculatePriorityScore(rule),
      estimatedRevenueLift: calculateRevenueLift(metrics.revenue, rule.revenueLiftPercent),
    }))
    .sort((a, b) => b.priorityScore - a.priorityScore)
    .slice(0, 8);

  for (const item of generated) {
    await query(
      `
      INSERT INTO app.checklist (
        project_id,
        rule_id,
        title,
        reason,
        difficulty,
        impact,
        priority_score,
        estimated_revenue_lift
      )
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
      ON CONFLICT (project_id, rule_id, cycle_start) DO NOTHING
      `,
      [
        projectId,
        item.ruleId,
        item.title,
        item.reason,
        item.difficulty,
        item.impact,
        item.priorityScore,
        item.estimatedRevenueLift,
      ]
    );
  }

  const rows = await query<ChecklistRow>(
    `
    SELECT *
    FROM app.checklist
    WHERE project_id = $1
      AND current_date BETWEEN cycle_start AND cycle_end
    ORDER BY priority_score DESC, created_at ASC
    LIMIT 8
    `,
    [projectId]
  );

  return rows.map(formatChecklistRow);
}

export async function completeChecklistItem(projectId: string, itemId: string) {
  const rows = await query<ChecklistRow>(
    `
    UPDATE app.checklist
    SET status = 'completed',
        completed_at = now()
    WHERE id = $1
      AND project_id = $2
    RETURNING *
    `,
    [itemId, projectId]
  );

  return rows[0] ? formatChecklistRow(rows[0]) : null;
}

function formatChecklistRow(row: ChecklistRow) {
  return {
    id: row.id,
    ruleId: row.rule_id,
    title: row.title,
    reason: row.reason,
    difficulty: row.difficulty,
    impact: row.impact,
    priorityScore: Number(row.priority_score),
    estimatedRevenueLift: Number(row.estimated_revenue_lift),
    status: row.status,
    completed: row.status === "completed",
    cycleStart: row.cycle_start,
    cycleEnd: row.cycle_end,
    completedAt: row.completed_at,
  };
}