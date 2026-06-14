"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchProductRevenue = fetchProductRevenue;
const db_1 = require("./db");
async function fetchProductRevenue(projectId, period = "30d", startDate, endDate) {
    return (0, db_1.queryFile)("dashboard_analytics_revenue.sql", [projectId, period, startDate ?? null, endDate ?? null]);
}
