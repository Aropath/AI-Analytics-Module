import { queryFile } from "./db";

export async function fetchTrafficAnalysis(
  projectId: string,
  period = "30d",
  startDate?: string | null,
  endDate?: string | null
) {
  return queryFile("dashboard_traffic_analysis.sql", [projectId, period, startDate ?? null, endDate ?? null]);
}
