import pool from "./db.js";

export async function query(query, params) {
  const result = await pool.query(query, params);
  return result.rows;
}

export async function listEntity(entity, fields = "*", where = {}) {
  const whereClause = Object.entries(where)
    .map(([key, value]) => `${key} = ${typeof value === 'string' ? `'${value}'` : value}`)
    .join(" AND ");
  const result = await pool.query(
    `SELECT ${fields} FROM ${entity} ${
      whereClause ? `WHERE ${whereClause}` : ""
    } ORDER BY name`
  );
  return result.rows;
}

export async function listEntityWithJoin(entity, join, fields = "*") {
  const result = await pool.query(
    `SELECT ${fields} FROM ${entity} JOIN ${join} ON ${join}.id = ${entity}.${join}_id`
  );
  return result.rows;
}

export async function getEntity(id, entity, fields = "*", where = {}) {
  const whereClause = Object.entries(where)
    .map(([key, value]) => `${key} = ${value}`)
    .join(" AND ");
  const result = await pool.query(
    `SELECT ${fields} FROM ${entity} WHERE id = $1 ${whereClause ? `AND ${whereClause}` : ""}`,
    [id]
  );
  return result.rows[0];
}

export async function addEntity(obj, entity) {
  const fields = Object.keys(obj)
    .map((field) => `"${field}"`)
    .join(", ");
  const indexs = Object.keys(obj)
    .map((_, index) => `$${index + 1}`)
    .join(", ");
  const values = Object.values(obj);

  const query = `INSERT INTO ${entity} (${fields}) VALUES (${indexs}) RETURNING *`;
  const result = await pool.query(query, values);
  return result.rows[0];
}

export async function addEntities(array, keys, entity) {
  const fields = keys.map((field) => `"${field}"`).join(", ");
  const indexs = array
    .map(
      (_, index) =>
        `(${keys
          .map((_, fIndex) => `$${index * keys.length + fIndex + 1}`)
          .join(", ")})`
    )
    .join(", ");
  const values = array.flatMap((obj) => Object.values(obj));

  const query = `INSERT INTO ${entity} (${fields}) VALUES ${indexs} RETURNING *`;
  const result = await pool.query(query, values);
  return result.rows;
}

export async function updateEntity(id, obj, entity) {
  delete obj.id;

  const fields = Object.keys(obj)
    .map((field, index) => `"${field}" = $${index + 2}`)
    .join(", ");
  const values = Object.values(obj);

  const query = `UPDATE ${entity} SET ${fields} WHERE id = $1 RETURNING *`;
  const result = await pool.query(query, [id, ...values]);
  return result.rows[0];
}

export async function deleteEntity(id, entity) {
  const result = await pool.query(
    `DELETE FROM ${entity} WHERE id = $1 RETURNING *`,
    [id]
  );
  return result.rows[0];
}

export function return200(response, res) {
  if (response && response.code == 400 && response.errors) {
    res.status(400).send(response);
  } else {
    res.status(200).send(response);
  }
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
