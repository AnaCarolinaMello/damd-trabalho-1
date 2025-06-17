import pool from './db.js';

export async function query(query, params) {
    const result = await pool.query(query, params);
    return result.rows;
}

export async function getEntity(id, entity, fields = '*', where = {}) {
    const whereClause = Object.entries(where)
        .map(([key, value]) => `${key} = ${value}`)
        .join(' AND ');
    const result = await pool.query(
        `SELECT ${fields} FROM ${entity} WHERE id = $1 ${whereClause ? `AND ${whereClause}` : ''}`,
        [id]
    );
    return result.rows[0];
}

export async function addEntity(obj, entity) {
    const fields = Object.keys(obj)
        .map((field) => `"${field}"`)
        .join(', ');
    const placeholders = Object.keys(obj)
        .map((_, i) => `$${i + 1}`)
        .join(', ');
    const values = Object.values(obj);
    console.log(fields, placeholders, values, entity);

    const result = await pool.query(`INSERT INTO ${entity} (${fields}) VALUES (${placeholders}) RETURNING *`, values);
    return result.rows[0];
}

export async function updateEntity(id, obj, entity) {
    delete obj.id;

    // Filter out null/undefined values to only update fields that have actual values
    const filteredObj = Object.fromEntries(
        Object.entries(obj).filter(([key, value]) => value !== null && value !== undefined)
    );

    if (Object.keys(filteredObj).length === 0) {
        throw new Error('No fields to update');
    }

    const fields = Object.keys(filteredObj)
        .map((field, index) => `"${field}" = $${index + 2}`)
        .join(', ');
    const values = Object.values(filteredObj);

    const query = `UPDATE ${entity} SET ${fields} WHERE id = $1 RETURNING *`;
    const result = await pool.query(query, [id, ...values]);
    return result.rows[0];
}

export async function calculateDistance(lat1, lon1, lat2, lon2) {
    const result = await pool.query(
        `SELECT ST_Distance(
            ST_GeogFromText('POINT(' || $2 || ' ' || $1 || ')'),
            ST_GeogFromText('POINT(' || $4 || ' ' || $3 || ')')
        ) / 1000 as distance_km`,
        [lat1, lon1, lat2, lon2]
    );
    return result.rows[0].distance_km;
}

export async function findNearbyDeliveries(latitude, longitude, radiusKm = 5) {
    const result = await pool.query(
        `
    SELECT dt.*,
           ST_Distance(ST_GeogFromText('POINT(' || $2 || ' ' || $1 || ')'),
           ST_GeogFromText('POINT(' || dt.longitude || ' ' || dt.latitude || ')')) / 1000 as distance_km
    FROM delivery_tracking dt
    WHERE ST_DWithin(
      ST_GeogFromText('POINT(' || $2 || ' ' || $1 || ')'),
      ST_GeogFromText('POINT(' || dt.longitude || ' ' || dt.latitude || ')'),
      $3 * 1000
    )
    AND status IN ('preparing', 'pending')
    ORDER BY distance_km
  `,
        [latitude, longitude, radiusKm]
    );

    return result.rows;
}

export function return200(response, res) {
    if (response && response.code == 400 && response.errors) res.status(400).send(response);
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
    res.status(403).send('Unauthorized');
}
