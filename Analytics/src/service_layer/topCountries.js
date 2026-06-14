"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchTopCountries = fetchTopCountries;
const db_1 = require("./db");
async function fetchTopCountries(projectId, period = "30d", startDate, endDate) {
    return (0, db_1.queryFile)("dashboard_top_countries.sql", [projectId, period, startDate ?? null, endDate ?? null]);
}
