import "dotenv/config";
import express from "express";
import cors from "cors";
import analyticsRoutes from "../routes/analyticsRoutes";

const app = express();

const allowedOrigins = ["http://localhost:3000"];

if (process.env.FRONTEND_URL) {
  allowedOrigins.push(process.env.FRONTEND_URL);
}

app.use(cors({
  origin: allowedOrigins,
  credentials: true,
}));

app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({ status: "ok", service: "analytics", timestamp: new Date().toISOString() });
});

app.use("/api", analyticsRoutes);

app.use((_req, res) => res.status(404).json({ error: "Route not found" }));

app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error("Analytics service error:", err);
  res.status(500).json({ error: "Internal server error" });
});

const PORT = parseInt(process.env.PORT || "5001", 10);

app.listen(PORT, () => {
  console.log(`\n📊 Analytics service running on http://localhost:${PORT}`);
});

export default app;
