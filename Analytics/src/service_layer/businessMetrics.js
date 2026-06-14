"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getMetrics = getMetrics;
exports.loadMetrics = loadMetrics;
const db_1 = require("./db");
async function getMetrics(projectId) {
    return (0, db_1.queryFile)("metrics.sql", [projectId]);
}
async function loadMetrics(projectId) {
    const rows = await getMetrics(projectId);
    if (!rows.length) {
        return {
            total_users: 0,
            sessions: 0,
            conversion_rate: 0,
            revenue: 0,
            user_growth_yoy: 0,
            revenue_growth_yoy: 0,
        };
    }
    const latest = rows[rows.length - 1];
    return {
        total_users: Number(latest.ttm_users ?? 0),
        sessions: Number(latest.ttm_sessions ?? 0),
        conversion_rate: Number(latest.conversion_rate ?? 0),
        revenue: Number(latest.ttm_revenue ?? 0),
        user_growth_yoy: Number(latest.user_growth_yoy ?? 0),
        revenue_growth_yoy: Number(latest.revenue_growth_yoy ?? 0),
    };
}
