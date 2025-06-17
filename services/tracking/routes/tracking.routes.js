import express from 'express';
import {
    updateDriverLocation,
    getDriverLocation,
    getDeliveryLocation,
    updateDeliveryStatus,
    getDeliveryHistory,
    getNearbyDeliveries,
    calculateETA,
    getDriverActiveDeliveries,
} from '../controller/tracking.controller.js';
import { return200, return500 } from '../util/index.js';

const router = express.Router();

// Driver location endpoints
router.post('/location', async (req, res) => {
    try {
        console.log('updateDriverLocation', req.body);
        const location = await updateDriverLocation(req.body);
        return200(location, res);
    } catch (error) {
        console.log(error);
        return500(error, req, res);
    }
});

router.get('/location/driver/:driverId', async (req, res) => {
    try {
        const location = await getDriverLocation(req.params.driverId);
        return200(location, res);
    } catch (error) {
        console.log(error);
        return500(error, req, res);
    }
});

// Customer tracking endpoints
router.get('/delivery/:orderId/customer/:customerId', async (req, res) => {
    try {
        const location = await getDeliveryLocation(req.params.orderId, req.params.customerId);
        return200(location, res);
    } catch (error) {
        return500(error, req, res);
    }
});

router.get('/history/:orderId/user/:userId', async (req, res) => {
    try {
        const history = await getDeliveryHistory(req.params.orderId, req.params.userId);
        return200(history, res);
    } catch (error) {
        return500(error, req, res);
    }
});

// Delivery status endpoints
router.post('/status', async (req, res) => {
    try {
        console.log(req.body);
        const status = await updateDeliveryStatus(req.body);
        return200(status, res);
    } catch (error) {
        console.log(error);
        return500(error, req, res);
    }
});

// Geospatial endpoints
router.get('/nearby', async (req, res) => {
    try {
        const { latitude, longitude, radius } = req.query;
        const deliveries = await getNearbyDeliveries(latitude, longitude, radius);
        return200(deliveries, res);
    } catch (error) {
        return500(error, req, res);
    }
});

// ETA calculation
router.get('/eta/:orderId/driver/:driverId', async (req, res) => {
    try {
        const eta = await calculateETA(req.params.orderId, req.params.driverId);
        return200(eta, res);
    } catch (error) {
        console.log(error);
        return500(error, req, res);
    }
});

// Driver active deliveries
router.get('/driver/:driverId/active', async (req, res) => {
    try {
        const deliveries = await getDriverActiveDeliveries(req.params.driverId);
        return200(deliveries, res);
    } catch (error) {
        return500(error, req, res);
    }
});

export default router;
