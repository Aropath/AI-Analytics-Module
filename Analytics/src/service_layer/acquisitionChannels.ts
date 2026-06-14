import { queryFile } from "./db";

export async function fetchAcquisitionChannels(
  projectId: string,
  period = "30d",
  startDate?: string | null,
  endDate?: string | null
) {
  return queryFile("dashboard_analytics_channels.sql", [projectId, period, startDate ?? null, endDate ?? null]);
}
