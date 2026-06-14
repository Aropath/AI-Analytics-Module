"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.pool = void 0;
exports.query = query;
exports.queryFile = queryFile;
exports.resolveProjectId = resolveProjectId;
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const pg_1 = require("pg");
const connectionString = process.env.DATABASE_URL || process.env.SUPABASE_DB_URL;
if (!connectionString) {
    throw new Error("DATABASE_URL or SUPABASE_DB_URL is required for analytics queries");
}
exports.pool = new pg_1.Pool({
    connectionString,
    ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : undefined,
});
async function query(text, params = []) {
    const result = await exports.pool.query(text, params);
    return result.rows;
}
async function queryFile(relativeSqlPath, params = []) {
    const sqlPath = path_1.default.resolve(__dirname, "../query_layer", relativeSqlPath);
    const sql = fs_1.default.readFileSync(sqlPath, "utf8");
    return query(sql, params);
}
async function resolveProjectId(input) {
    if (input.projectId)
        return input.projectId;
    if (!input.clientId) {
        throw new Error("projectId or clientId query parameter is required");
    }
    const rows = await query(`SELECT id FROM app.projects WHERE clientid = $1 LIMIT 1`, [input.clientId]);
    if (!rows[0]?.id) {
        throw new Error("No project found for the given clientId");
    }
    return rows[0].id;
}
