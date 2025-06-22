import express from "express";
import {
  createNotification,
} from "../controllers/notification.controller.js";
import { return200, return500 } from "../util/index.js";

const router = express.Router();

router.post("/", async (req, res) => {
  try {
    await createNotification();
    return200({ message: "Notification created" }, res);
  } catch (error) {
    return500(error, req, res);
  }
});

export default router;
