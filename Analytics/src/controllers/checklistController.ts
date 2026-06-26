import { Request, Response } from "express";
import { resolveProjectId } from "../service_layer/db";
import {
  fetchGrowthChecklist,
  completeChecklistItem,
} from "../service_layer/checklistService";

type ChecklistQuery = {
  projectId?: string;
  clientId?: string;
  period?: string;
};

async function getProjectId(req: Request): Promise<string> {
  const { projectId, clientId } = req.query as ChecklistQuery;
  return resolveProjectId({ projectId, clientId });
}

export async function getGrowthChecklist(req: Request, res: Response): Promise<void> {
  try {
    console.log("Growth checklist route hit");
    const projectId = await getProjectId(req);
    const { period = "30d" } = req.query as ChecklistQuery;

    const data = await fetchGrowthChecklist(projectId, period);

    res.json({
      total: data.length,
      completed: data.filter((item) => item.completed).length,
      items: data,
    });
  } catch (err: any) {
    console.error("Failed to fetch growth checklist", err);
    res.status(500).json({
      error: "Failed to fetch growth checklist",
      detail: err?.message ?? String(err),
    });
  }
}

export async function markChecklistItemCompleted(req: Request, res: Response): Promise<void> {
  try {
    const projectId = await getProjectId(req);
    const { itemId } = req.params;

    const item = await completeChecklistItem(projectId, itemId);

    if (!item) {
      res.status(404).json({ error: "Checklist item not found" });
      return;
    }

    res.json(item);
  } catch (err: any) {
    console.error("Failed to complete checklist item", err);
    res.status(500).json({
      error: "Failed to complete checklist item",
      detail: err?.message ?? String(err),
    });
  }
}