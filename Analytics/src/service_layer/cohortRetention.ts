import { queryFile } from "./db";

export async function fetchCohortRetention(
  projectId: string,
  period = "90d",
  startDate?: string | null,
  endDate?: string | null
) {
  return queryFile("dashboard_analytics_cohort.sql", [projectId, period, startDate ?? null, endDate ?? null]);
}
