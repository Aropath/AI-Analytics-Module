"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchTrafficAnalysis = fetchTrafficAnalysis;
const db_1 = require("./db");
async function fetchTrafficAnalysis(projectId, period = "30d", startDate, endDate) {
    return (0, db_1.queryFile)("dashboard_traffic_analysis.sql", [projectId, period, startDate ?? null, endDate ?? null]);
}
