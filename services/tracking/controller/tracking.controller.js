import { addEntity, updateEntity, query, calculateDistance, findNearbyDeliveries } from '../util/index.js';

// Update driver location
export async function updateDriverLocation(locationData) {
    const { driver_id, order_id, latitude, longitude, speed, heading, accuracy } = locationData;

    if (!driver_id || !latitude || !longitude) {
        throw new Error('Driver ID, latitude and longitude are required');
    }

    // Validate coordinates
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
        throw new Error('Invalid coordinates');
    }

    const location = await addEntity(
        {
            driver_id,
            order_id: order_id || null,
            latitude: parseFloat(latitude),
            longitude: parseFloat(longitude),
            speed: speed ? parseFloat(speed) : 0.0,
            heading: heading ? parseFloat(heading) : 0.0,
            accuracy: accuracy ? parseFloat(accuracy) : 0.0,
        },
        'driver_locations'
    );

    return location;
}

// Get current driver location
export async function getDriverLocation(driverId) {
    const locations = await query(
        `
    SELECT * FROM driver_locations
    WHERE driver_id = $1
    ORDER BY timestamp DESC
    LIMIT 1
  `,
        [driverId]
    );

    if (!locations.length) {
        throw new Error('Driver location not found');
    }

    return locations[0];
}

// Get delivery location for customer
export async function getDeliveryLocation(orderId, customerId) {
    // First verify the customer owns this order
    const orderCheck = await query(
        `
    SELECT customer_id FROM orders WHERE id = $1
  `,
        [orderId]
    );

    if (!orderCheck.length) {
        throw new Error('Order not found');
    }

    if (orderCheck[0].customer_id != customerId) {
        throw new Error('You are not authorized to track this order');
    }

    // Get the latest driver location for this order
    const locations = await query(
        `
    SELECT dl.*, dt.status as delivery_status
    FROM driver_locations dl
    LEFT JOIN delivery_tracking dt ON dt.order_id = dl.order_id AND dt.driver_id = dl.driver_id
    WHERE dl.order_id = $1
    ORDER BY dl.timestamp DESC
    LIMIT 1
  `,
        [orderId]
    );

    if (!locations.length) {
        throw new Error('Delivery location not available');
    }

    return locations[0];
}

// Update delivery status with location
export async function updateDeliveryStatus(statusData) {
    const { order_id, driver_id, status, latitude, longitude, notes } = statusData;

    if (!order_id || !driver_id || !status) {
        throw new Error('Order ID, driver ID and status are required');
    }

    const validStatuses = ['assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
        throw new Error('Invalid status');
    }

    const tracking = await addEntity(
        {
            order_id,
            driver_id,
            status,
            latitude: latitude ? parseFloat(latitude) : null,
            longitude: longitude ? parseFloat(longitude) : null,
            notes: notes || null,
        },
        'delivery_tracking'
    );

    return tracking;
}

// Get delivery tracking history
export async function getDeliveryHistory(orderId, userId) {
    // Verify user has access to this order
    const orderCheck = await query(
        `
    SELECT customer_id, driver_id FROM orders WHERE id = $1
  `,
        [orderId]
    );

    if (!orderCheck.length) {
        throw new Error('Order not found');
    }

    const order = orderCheck[0];
    if (order.customer_id != userId && order.driver_id != userId) {
        throw new Error('You are not authorized to view this order history');
    }

    const history = await query(
        `
    SELECT * FROM delivery_tracking
    WHERE order_id = $1
    ORDER BY timestamp ASC
  `,
        [orderId]
    );

    return history;
}

// Find nearby deliveries (for drivers)
export async function getNearbyDeliveries(latitude, longitude, radiusKm = 5) {
    if (!latitude || !longitude) {
        throw new Error('Latitude and longitude are required');
    }

    // Validate coordinates
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
        throw new Error('Invalid coordinates');
    }

    const deliveries = await findNearbyDeliveries(parseFloat(latitude), parseFloat(longitude), parseFloat(radiusKm));

    return deliveries;
}

// Calculate ETA based on distance and average speed
export async function calculateETA(orderId, driverId) {
    // Get current driver location
    const driverLocation = await query(
        `
    SELECT latitude, longitude FROM driver_locations
    WHERE driver_id = $1
    ORDER BY timestamp DESC
    LIMIT 1
  `,
        [driverId]
    );

    if (!driverLocation.length) {
        throw new Error('Driver location not available');
    }

    // Get delivery address
    const orderAddress = await query(
        `
    SELECT a.street, a.number, a.neighborhood, a.city, a.state
    FROM orders o
    JOIN addresses a ON o.address_id = a.id
    WHERE o.id = $1
  `,
        [orderId]
    );

    if (!orderAddress.length) {
        throw new Error('Order address not found');
    }

    const avgSpeedKmh = 30;
    const distance = calculateDistance(
        driverLocation[0].latitude,
        driverLocation[0].longitude,
        // Conferir a busca por posição
        orderAddress[0].latitude,
        orderAddress[0].longitude
    );

    const etaMinutes = Math.round((distance / avgSpeedKmh) * 60);

    return {
        distance_km: distance,
        eta_minutes: etaMinutes,
        driver_location: driverLocation[0],
        delivery_address: orderAddress[0],
    };
}

export async function getDriverActiveDeliveries(driverId) {
    const deliveries = await query(
        `
    SELECT DISTINCT dt.order_id, dt.status, dt.timestamp,
           o.name as order_name, o.description,
           a.street, a.number, a.neighborhood, a.city, a.state
    FROM delivery_tracking dt
    JOIN orders o ON dt.order_id = o.id
    JOIN addresses a ON o.address_id = a.id
    WHERE dt.driver_id = $1
    AND dt.status IN ('assigned', 'picked_up', 'in_transit')
    ORDER BY dt.timestamp DESC
  `,
        [driverId]
    );

    return deliveries;
}
