"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchPagePerformance = fetchPagePerformance;
const db_1 = require("./db");
async function fetchPagePerformance(projectId, period = "30d", startDate, endDate) {
    return (0, db_1.queryFile)("dashboard_analytics_page_performance.sql", [projectId, period, startDate ?? null, endDate ?? null]);
}
