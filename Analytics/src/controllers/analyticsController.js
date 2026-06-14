"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getDashboard = getDashboard;
exports.getLatestMetrics = getLatestMetrics;
exports.getTrafficAnalysis = getTrafficAnalysis;
exports.getTopCountries = getTopCountries;
exports.getAcquisitionChannels = getAcquisitionChannels;
exports.getPagePerformance = getPagePerformance;
exports.getProductRevenue = getProductRevenue;
exports.getCohortRetention = getCohortRetention;
const db_1 = require("../service_layer/db");
const dashboard_1 = require("../service_layer/dashboard");
const trafficAnalysis_1 = require("../service_layer/trafficAnalysis");
const topCountries_1 = require("../service_layer/topCountries");
const acquisitionChannels_1 = require("../service_layer/acquisitionChannels");
const pagePerformance_1 = require("../service_layer/pagePerformance");
const productRevenue_1 = require("../service_layer/productRevenue");
const cohortRetention_1 = require("../service_layer/cohortRetention");
async function getProjectId(req) {
    const { projectId, clientId } = req.query;
    return (0, db_1.resolveProjectId)({ projectId, clientId });
}
function handleError(res, message, err) {
    console.error(message, err);
    const status = /projectId|clientId|No project/.test(err?.message ?? "") ? 400 : 500;
    res.status(status).json({ error: message, detail: err?.message ?? String(err) });
}
async function getDashboard(req, res) {
    const { period = "30d", startDate, endDate } = req.query;
    try {
        const projectId = await getProjectId(req);
        const data = await (0, dashboard_1.fetchDashboardData)(projectId, period, startDate, endDate);
        res.json(data);
    }
    catch (err) {
        handleError(res, "Failed to fetch dashboard data", err);
    }
}
async function getLatestMetrics(req, res) {
    try {
        const projectId = await getProjectId(req);
        const data = await (0, dashboard_1.fetchLatestMetrics)(projectId);
        res.json(data);
    }
    catch (err) {
        handleError(res, "Failed to fetch latest metrics", err);
    }
}
async function getTrafficAnalysis(req, res) {
    const { period = "30d", startDate, endDate } = req.query;
    try {
        const projectId = await getProjectId(req);
        const data = await (0, trafficAnalysis_1.fetchTrafficAnalysis)(projectId, period, startDate, endDate);
        res.json(data);
    }
    catch (err) {
        handleError(res, "Failed to fetch traffic analysis", err);
    }
}
async function getTopCountries(req, res) {
    const { period = "30d", startDate, endDate } = req.query;
    try {
        const projectId = await getProjectId(req);
        const data = await (0, topCountries_1.fetchTopCountries)(projectId, period, startDate, endDate);
        res.json(data);
    }
    catch (err) {
        handleError(res, "Failed to fetch top countries", err);
    }
}
async function getAcquisitionChannels(req, res) {
    const { period = "30d", startDate, endDate } = req.query;
    try {
        const projectId = await getProjectId(req);
        const data = await (0, acquisitionChannels_1.fetchAcquisitionChannels)(projectId, period, startDate, endDate);
        res.json(data);
    }
    catch (err) {
        handleError(res, "Failed to fetch acquisition channels", err);
    }
}
async function getPagePerformance(req, res) {
    const { period = "30d", startDate, endDate } = req.query;
    try {
        const projectId = await getProjectId(req);
        const data = await (0, pagePerformance_1.fetchPagePerformance)(projectId, period, startDate, endDate);
        res.json(data);
    }
    catch (err) {
        handleError(res, "Failed to fetch page performance", err);
    }
}
async function getProductRevenue(req, res) {
    const { period = "30d", startDate, endDate } = req.query;
    try {
        const projectId = await getProjectId(req);
        const data = await (0, productRevenue_1.fetchProductRevenue)(projectId, period, startDate, endDate);
        res.json(data);
    }
    catch (err) {
        handleError(res, "Failed to fetch product revenue", err);
    }
}
async function getCohortRetention(req, res) {
    const { period = "90d", startDate, endDate } = req.query;
    try {
        const projectId = await getProjectId(req);
        const data = await (0, cohortRetention_1.fetchCohortRetention)(projectId, period, startDate, endDate);
        res.json(data);
    }
    catch (err) {
        handleError(res, "Failed to fetch cohort retention", err);
    }
}
