import fs from "fs";
import path from "path";
import { Pool, QueryResultRow } from "pg";

const connectionString = process.env.DATABASE_URL || process.env.SUPABASE_DB_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL or SUPABASE_DB_URL is required for analytics queries");
}

export const pool = new Pool({
  connectionString,
  ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : undefined,
});

export async function query<T extends QueryResultRow = QueryResultRow>(
  text: string,
  params: unknown[] = []
): Promise<T[]> {
  const result = await pool.query<T>(text, params);
  return result.rows;
}

export async function queryFile<T extends QueryResultRow = QueryResultRow>(
  relativeSqlPath: string,
  params: unknown[] = []
): Promise<T[]> {
  const sqlPath = path.resolve(__dirname, "../query_layer", relativeSqlPath);
  const sql = fs.readFileSync(sqlPath, "utf8");
  return query<T>(sql, params);
}

export async function resolveProjectId(input: {
  projectId?: string;
  clientId?: string;
}): Promise<string> {
  if (input.projectId) return input.projectId;

  if (!input.clientId) {
    throw new Error("projectId or clientId query parameter is required");
  }

  const rows = await query<{ id: string }>(
    `SELECT id FROM app.projects WHERE clientid = $1 LIMIT 1`,
    [input.clientId]
  );

  if (!rows[0]?.id) {
    throw new Error("No project found for the given clientId");
  }

  return rows[0].id;
}
