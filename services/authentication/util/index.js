import pool from "./db.js";

export async function query(query, params) {
  const result = await pool.query(query, params);
  return result.rows;
}

export async function getEntity(id, entity, fields = "*", where = {}) {
  const whereClause = Object.entries(where)
    .map(
      ([key, value]) =>
        `${key} = ${typeof value === "string" ? `'${value}'` : value}`
    )
    .join(" AND ");

  const result = await pool.query(
    `SELECT ${fields} FROM ${entity} WHERE ${whereClause || "1=1"} ${
      id ? "AND id = $1" : ""
    }`,
    id ? [id] : []
  );
  return result.rows[0];
}

export async function addEntity(obj, entity) {
  const fields = Object.keys(obj)
    .map((field) => `"${field}"`)
    .join(", ");
  const placeholders = Object.keys(obj)
    .map((_, i) => `$${i + 1}`)
    .join(", ");
  const values = Object.values(obj);

  const result = await pool.query(
    `INSERT INTO ${entity} (${fields}) VALUES (${placeholders}) RETURNING *`,
    values
  );
  return result.rows[0];
}

export function return200(response, res) {
  if (response && response.code == 400 && response.errors)
    res.status(400).send(response);
  else res.status(200).send(response);
}

export function return500(response, req, res) {
  const error = {
    message: response.message,
    stack: response.stack,
    date: new Date(),
    body: req.body,
    url: req.url,
    params: req.params,
    headers: req.headers,
  };
  res.status(500).send({ message: error.message });
}

export function return403(res) {
  res.status(403).send("Unauthorized");
}
