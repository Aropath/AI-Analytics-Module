import { Request, Response } from "express";
import { resolveProjectId } from "../service_layer/db";
import { fetchDashboardData, fetchLatestMetrics } from "../service_layer/dashboard";
import { fetchTrafficAnalysis } from "../service_layer/trafficAnalysis";
import { fetchTopCountries } from "../service_layer/topCountries";
import { fetchAcquisitionChannels } from "../service_layer/acquisitionChannels";
import { fetchPagePerformance } from "../service_layer/pagePerformance";
import { fetchProductRevenue } from "../service_layer/productRevenue";
import { fetchCohortRetention } from "../service_layer/cohortRetention";

type AnalyticsQuery = {
  projectId?: string;
  clientId?: string;
  period?: string;
  startDate?: string;
  endDate?: string;
};

async function getProjectId(req: Request): Promise<string> {
  const { projectId, clientId } = req.query as AnalyticsQuery;
  return resolveProjectId({ projectId, clientId });
}

function handleError(res: Response, message: string, err: any): void {
  console.error(message, err);
  const status = /projectId|clientId|No project/.test(err?.message ?? "") ? 400 : 500;
  res.status(status).json({ error: message, detail: err?.message ?? String(err) });
}

export async function getDashboard(req: Request, res: Response): Promise<void> {
  const { period = "30d", startDate, endDate } = req.query as AnalyticsQuery;

  try {
    const projectId = await getProjectId(req);
    const data = await fetchDashboardData(projectId, period, startDate, endDate);
    res.json(data);
  } catch (err: any) {
    handleError(res, "Failed to fetch dashboard data", err);
  }
}

export async function getLatestMetrics(req: Request, res: Response): Promise<void> {
  try {
    const projectId = await getProjectId(req);
    const data = await fetchLatestMetrics(projectId);
    res.json(data);
  } catch (err: any) {
    handleError(res, "Failed to fetch latest metrics", err);
  }
}

export async function getTrafficAnalysis(req: Request, res: Response): Promise<void> {
  const { period = "30d", startDate, endDate } = req.query as AnalyticsQuery;

  try {
    const projectId = await getProjectId(req);
    const data = await fetchTrafficAnalysis(projectId, period, startDate, endDate);
    res.json(data);
  } catch (err: any) {
    handleError(res, "Failed to fetch traffic analysis", err);
  }
}

export async function getTopCountries(req: Request, res: Response): Promise<void> {
  const { period = "30d", startDate, endDate } = req.query as AnalyticsQuery;

  try {
    const projectId = await getProjectId(req);
    const data = await fetchTopCountries(projectId, period, startDate, endDate);
    res.json(data);
  } catch (err: any) {
    handleError(res, "Failed to fetch top countries", err);
  }
}

export async function getAcquisitionChannels(req: Request, res: Response): Promise<void> {
  const { period = "30d", startDate, endDate } = req.query as AnalyticsQuery;

  try {
    const projectId = await getProjectId(req);
    const data = await fetchAcquisitionChannels(projectId, period, startDate, endDate);
    res.json(data);
  } catch (err: any) {
    handleError(res, "Failed to fetch acquisition channels", err);
  }
}

export async function getPagePerformance(req: Request, res: Response): Promise<void> {
  const { period = "30d", startDate, endDate } = req.query as AnalyticsQuery;

  try {
    const projectId = await getProjectId(req);
    const data = await fetchPagePerformance(projectId, period, startDate, endDate);
    res.json(data);
  } catch (err: any) {
    handleError(res, "Failed to fetch page performance", err);
  }
}

export async function getProductRevenue(req: Request, res: Response): Promise<void> {
  const { period = "30d", startDate, endDate } = req.query as AnalyticsQuery;

  try {
    const projectId = await getProjectId(req);
    const data = await fetchProductRevenue(projectId, period, startDate, endDate);
    res.json(data);
  } catch (err: any) {
    handleError(res, "Failed to fetch product revenue", err);
  }
}

export async function getCohortRetention(req: Request, res: Response): Promise<void> {
  const { period = "90d", startDate, endDate } = req.query as AnalyticsQuery;

  try {
    const projectId = await getProjectId(req);
    const data = await fetchCohortRetention(projectId, period, startDate, endDate);
    res.json(data);
  } catch (err: any) {
    handleError(res, "Failed to fetch cohort retention", err);
  }
}
