"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const analyticsRoutes_1 = __importDefault(require("../routes/analyticsRoutes"));
const app = (0, express_1.default)();
app.use((0, cors_1.default)({
    origin: process.env.FRONTEND_URL || "http://localhost:3000",
    credentials: true,
}));
app.use(express_1.default.json());
app.get("/health", (_req, res) => {
    res.json({ status: "ok", service: "analytics", timestamp: new Date().toISOString() });
});
app.use("/api", analyticsRoutes_1.default);
app.use((_req, res) => res.status(404).json({ error: "Route not found" }));
app.use((err, _req, res, _next) => {
    console.error("Analytics service error:", err);
    res.status(500).json({ error: "Internal server error" });
});
const PORT = parseInt(process.env.PORT || "5001", 10);
app.listen(PORT, () => {
    console.log(`\n📊 Analytics service running on http://localhost:${PORT}`);
    console.log(`   Auth service: ${process.env.AUTH_SERVICE_URL || "http://localhost:5000"}\n`);
});
exports.default = app;
