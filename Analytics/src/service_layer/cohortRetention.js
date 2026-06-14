"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchCohortRetention = fetchCohortRetention;
const db_1 = require("./db");
async function fetchCohortRetention(projectId, period = "90d", startDate, endDate) {
    return (0, db_1.queryFile)("dashboard_analytics_cohort.sql", [projectId, period, startDate ?? null, endDate ?? null]);
}
