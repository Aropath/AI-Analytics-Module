import { queryFile } from "./db";

export async function getMetrics(projectId: string) {
  return queryFile("metrics.sql", [projectId]);
}

export async function loadMetrics(projectId: string) {
  const rows = await getMetrics(projectId);

  if (!rows.length) {
    return {
      total_users: 0,
      sessions: 0,
      conversion_rate: 0,
      revenue: 0,
      user_growth_yoy: 0,
      revenue_growth_yoy: 0,
    };
  }

  const latest = rows[rows.length - 1] as any;

  return {
    total_users: Number(latest.ttm_users ?? 0),
    sessions: Number(latest.ttm_sessions ?? 0),
    conversion_rate: Number(latest.conversion_rate ?? 0),
    revenue: Number(latest.ttm_revenue ?? 0),
    user_growth_yoy: Number(latest.user_growth_yoy ?? 0),
    revenue_growth_yoy: Number(latest.revenue_growth_yoy ?? 0),
  };
}
