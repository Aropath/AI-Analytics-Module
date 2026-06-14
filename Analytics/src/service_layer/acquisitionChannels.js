"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchAcquisitionChannels = fetchAcquisitionChannels;
const db_1 = require("./db");
async function fetchAcquisitionChannels(projectId, period = "30d", startDate, endDate) {
    return (0, db_1.queryFile)("dashboard_analytics_channels.sql", [projectId, period, startDate ?? null, endDate ?? null]);
}
