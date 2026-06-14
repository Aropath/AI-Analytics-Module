import { queryFile } from "./db";

export async function fetchProductRevenue(
  projectId: string,
  period = "30d",
  startDate?: string | null,
  endDate?: string | null
) {
  return queryFile("dashboard_analytics_revenue.sql", [projectId, period, startDate ?? null, endDate ?? null]);
}
