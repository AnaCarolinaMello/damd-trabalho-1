import express from "express";
import { registerUser, loginUser, validateToken } from "../controllers/auth.controller.js";
import { return200, return500, return403 } from "../util/index.js";
const router = express.Router();

router.post("/", async (req, res) => {
    try {
        const response = await registerUser(req.body);
        return return200(response, res);
    } catch (error) {
        console.log(error);
        return return500(error, req, res);
    }
});

router.post("/login", async (req, res) => {
    try {
        const response = await loginUser(req.body);
        return return200(response, res);
    } catch (error) {
        return return500(error, req, res);
    }
});

router.post("/validate/:token", async (req, res) => {
    try {
        const { token } = req.params;
        if (!token) return return403(res);

        const response = await validateToken(token);
        return return200(response, res);
    } catch (error) {
        return return500(error, req, res);
    }
});

export default router;