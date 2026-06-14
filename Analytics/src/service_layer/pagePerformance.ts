import { queryFile } from "./db";

export async function fetchPagePerformance(
  projectId: string,
  period = "30d",
  startDate?: string | null,
  endDate?: string | null
) {
  return queryFile("dashboard_analytics_page_performance.sql", [projectId, period, startDate ?? null, endDate ?? null]);
}
