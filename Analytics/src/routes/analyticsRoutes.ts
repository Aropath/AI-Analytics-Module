import { Router } from "express";
import {
  getDashboard,
  getLatestMetrics,
  getTrafficAnalysis,
  getTopCountries,
  getAcquisitionChannels,
  getPagePerformance,
  getProductRevenue,
  getCohortRetention,
} from "../controllers/analyticsController";
import {
  getGrowthChecklist,
  markChecklistItemCompleted,
} from "../controllers/checklistController";

const router = Router();

router.get("/metrics/latest", getLatestMetrics);

router.get("/dashboard", getDashboard);
router.get("/dashboard/trafficAnalysis", getTrafficAnalysis);
router.get("/dashboard/topCountries", getTopCountries);
router.get("/dashboard/acquisitionChannels", getAcquisitionChannels);
router.get("/dashboard/pagePerformance", getPagePerformance);
router.get("/dashboard/productRevenue", getProductRevenue);
router.get("/dashboard/cohortRetention", getCohortRetention);
router.get("/dashboard/growthChecklist", getGrowthChecklist);
router.post("/dashboard/growthChecklist/:itemId/complete", markChecklistItemCompleted);

export default router;