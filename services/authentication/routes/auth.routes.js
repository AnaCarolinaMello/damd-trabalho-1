import express from "express";
import { registerUser } from "../controllers/auth.controller.js";
import { return200, return500 } from "../util/index.js";
const router = express.Router();

router.post("/", async (req, res) => {
    try {
        const response = await registerUser(req.body);
        return return200(response, res);
    } catch (error) {
        return return500(error, req, res);
    }
});

export default router;