import { queryFile } from "./db";

export type AnalyticsPeriod = "today" | "7d" | "30d" | "90d" | "custom" | string;

export async function fetchDashboardData(
  projectId: string,
  period: AnalyticsPeriod = "30d",
  startDate?: string | null,
  endDate?: string | null
) {
  const rows = await queryFile("dashboard.sql", [
    projectId,
    period,
    startDate ?? null,
    endDate ?? null,
  ]);

  return rows[0] ?? {
    users: 0,
    visitors: 0,
    sessions: 0,
    pageviews: 0,
    transactions: 0,
    revenue: 0,
    conversion_rate: 0,
    engaged_sessions: 0,
    engagement_rate: 0,
    bounce_rate: 0,
    mobile_sessions: 0,
    desktop_sessions: 0,
    tablet_sessions: 0,
    organic_sessions: 0,
    paid_sessions: 0,
    social_sessions: 0,
    direct_sessions: 0,
    product_view_sessions: 0,
    add_to_cart_sessions: 0,
    checkout_sessions: 0,
    purchase_sessions: 0,
  };
}

export async function fetchLatestMetrics(projectId: string) {
  return fetchDashboardData(projectId, "today");
}
