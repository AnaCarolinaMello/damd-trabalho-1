import express from "express";
import {
  getOrders,
  getOrderById,
  getOrdersByUserId,
  getAvailableOrders,
  getDriverOrder,
  createOrder,
  acceptOrder,
  deliverOrder,
  rateOrder,
  cancelOrder,
} from "../controllers/order.controller.js";
import { return200, return500 } from "../util/index.js";

const router = express.Router();

router.get("/", async (req, res) => {
  try {
    const orders = await getOrders();
    return200(orders, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.get("/available", async (req, res) => {
  try {
    const orders = await getAvailableOrders();
    return200(orders, res);
  } catch (error) {
    console.log(error);
    return500(error, req, res);
  }
});

router.get("/:id", async (req, res) => {
  try {
    const order = await getOrderById(req.params.id, req.query.userId);
    return200(order, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.get("/driver/:driverId", async (req, res) => {
  try {
    const orders = await getDriverOrder(req.params.driverId);
    return200(orders, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.get("/user/:userId", async (req, res) => {
  try {
    const orders = await getOrdersByUserId(req.params.userId);
    return200(orders, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.post("/", async (req, res) => {
  try {
    const order = await createOrder(req.body);
    return200(order, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.post("/accept/:id", async (req, res) => {
  try {
    const order = await acceptOrder(req.params.id, req.body.driverId);
    return200(order, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.post("/deliver/:id", async (req, res) => {
  try {
    const order = await deliverOrder(req.params.id, req.body.userId, req.body.photo);
    return200(order, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.post("/cancel/:id", async (req, res) => {
  try {
    const order = await cancelOrder(req.params.id, req.body.userId);
    return200(order, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.post("/rate/:id", async (req, res) => {
  try {
    console.log('POST /rate/:id - Headers:', req.headers);
    console.log('POST /rate/:id - Content-Type:', req.get('Content-Type'));
    console.log('POST /rate/:id - Params:', req.params);
    console.log('POST /rate/:id - Body:', req.body);
    
    const order = await rateOrder(req.params.id, req.body.userId, req.body.rating);
    return200(order, res);
  } catch (error) {
    console.error('POST /rate/:id - Error:', error.message);
    console.error('POST /rate/:id - Stack:', error.stack);
    return500(error, req, res);
  }
});

export default router;
