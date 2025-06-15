import express from "express";
import { serviceRegistry } from "../controllers/registry.controller.js";
import { return200, return400, return500 } from "../util/index.js";

const router = express.Router();

router.post("/register", (req, res) => {
  try {
    const { name, url, healthEndpoint } = req.body;

    if (!name || !url)
      return return400(res, "Service name and URL are required");

    const result = serviceRegistry.register(name, url, healthEndpoint);
    return200(result, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.delete("/unregister/:name", (req, res) => {
  try {
    const { name } = req.params;
    const result = serviceRegistry.unregister(name);
    return200(result, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.get("/services", (req, res) => {
  try {
    const services = serviceRegistry.getAllServices();
    return200(services, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.get("/services/:name", (req, res) => {
  try {
    const { name } = req.params;
    const service = serviceRegistry.getService(name);
    return200({ name, ...service }, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.get("/health", (req, res) => {
  return200(
    {
      status: "healthy",
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      services: serviceRegistry.getAllServices().length,
    },
    res
  );
});

export default router;
