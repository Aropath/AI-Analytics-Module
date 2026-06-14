import { queryFile } from "./db";

export async function fetchTopCountries(
  projectId: string,
  period = "30d",
  startDate?: string | null,
  endDate?: string | null
) {
  return queryFile("dashboard_top_countries.sql", [projectId, period, startDate ?? null, endDate ?? null]);
}
