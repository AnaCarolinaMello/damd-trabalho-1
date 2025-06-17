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

// Get delivery location for customer (using only tracking data)
export async function getDeliveryLocation(orderId, customerId) {
    // Get the latest tracking info and driver location for this order
    const tracking = await query(
        `
    SELECT dt.*, dl.latitude as driver_latitude, dl.longitude as driver_longitude,
           dl.speed, dl.heading, dl.accuracy, dl.timestamp as location_timestamp
    FROM delivery_tracking dt
    LEFT JOIN driver_locations dl ON dt.driver_id = dl.driver_id 
        AND dl.order_id = dt.order_id
        AND dl.timestamp = (
            SELECT MAX(timestamp) FROM driver_locations 
            WHERE driver_id = dt.driver_id AND order_id = dt.order_id
        )
    WHERE dt.order_id = $1
    AND (dt.customer_id = $2 OR dt.customer_id IS NULL)
    ORDER BY dt.timestamp DESC
    LIMIT 1
  `,
        [orderId, customerId]
    );

    if (!tracking.length) {
        throw new Error('Delivery tracking not available or unauthorized');
    }

    return tracking[0];
}

// Update delivery status with location
export async function updateDeliveryStatus(statusData) {
    const { order_id, driver_id, status, latitude, longitude, notes, destination_address, customer_id } = statusData;

    if (!order_id || !driver_id || !status) {
        throw new Error('Order ID, driver ID and status are required');
    }

    const validStatuses = ['pending', 'preparing', 'accepted', 'delivered', 'cancelled'];
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
            destination_address: destination_address || null,
            customer_id: customer_id || null,
        },
        'delivery_tracking'
    );

    return tracking;
}

// Get delivery tracking history
export async function getDeliveryHistory(orderId, userId) {
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

// Calculate ETA based on driver and delivery locations from tracking
export async function calculateETA(orderId, driverId) {
    // Get current driver location
    const driverLocation = await query(
        `
    SELECT latitude, longitude, timestamp FROM driver_locations
    WHERE driver_id = $1
    ORDER BY timestamp DESC
    LIMIT 1
  `,
        [driverId]
    );

    if (!driverLocation.length) {
        throw new Error('Driver location not available');
    }

    // Get delivery destination from last tracking update
    const deliveryLocation = await query(
        `
    SELECT latitude, longitude, status FROM delivery_tracking
    WHERE order_id = $1 AND driver_id = $2
    AND latitude IS NOT NULL AND longitude IS NOT NULL
    ORDER BY timestamp DESC
    LIMIT 1
  `,
        [orderId, driverId]
    );

    if (!deliveryLocation.length) {
        throw new Error('Delivery destination not available in tracking data');
    }

    const avgSpeedKmh = 30;
    const distance = calculateDistance(
        driverLocation[0].latitude,
        driverLocation[0].longitude,
        deliveryLocation[0].latitude,
        deliveryLocation[0].longitude
    );

    const etaMinutes = Math.round((distance / avgSpeedKmh) * 60);

    return {
        distance_km: distance,
        eta_minutes: etaMinutes,
        driver_location: driverLocation[0],
        delivery_location: deliveryLocation[0],
        status: deliveryLocation[0].status
    };
}

export async function getDriverActiveDeliveries(driverId) {
    // Only return tracking information available in this microservice
    const deliveries = await query(
        `
    SELECT dt.order_id, dt.status, dt.timestamp, dt.latitude, dt.longitude, dt.notes
    FROM delivery_tracking dt
    WHERE dt.driver_id = $1
    AND dt.status IN ('pending', 'preparing', 'accepted')
    AND dt.timestamp = (
        SELECT MAX(timestamp) FROM delivery_tracking dt2 
        WHERE dt2.order_id = dt.order_id AND dt2.driver_id = dt.driver_id
    )
    ORDER BY dt.timestamp DESC
  `,
        [driverId]
    );

    return deliveries;
}
