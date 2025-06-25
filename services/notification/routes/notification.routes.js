import express from "express";
import {
  createNotification,
  getNotifications,
  updateNotification,
} from "../controllers/notification.controller.js";
import { return200, return500 } from "../util/index.js";

const router = express.Router();

router.get("/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const notifications = await getNotifications(userId);
    console.log("Notificações:", notifications);
    return200(notifications, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.post("/", async (req, res) => {
  try {
    await createNotification();
    return200({ message: "Notification created" }, res);
  } catch (error) {
    return500(error, req, res);
  }
});

router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    console.log("ID:", id);
    await updateNotification(id);
    return200({ message: "Notification updated" }, res);
  } catch (error) {
    return500(error, req, res);
  }
});

export default router;
