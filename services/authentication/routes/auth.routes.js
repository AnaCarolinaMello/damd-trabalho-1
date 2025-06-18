import express from "express";
import { registerUser, loginUser, validateToken } from "../controllers/auth.controller.js";
import { return200, return500, return403 } from "../util/index.js";
import { AppError } from "../util/appError.js";
const router = express.Router();

router.post("/register", async (req, res) => {
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
    if (!req.body.email || !req.body.password) {
      return res.status(400).json({
        error: "Email e senha são obrigatórios."
      });
    }

    const response = await loginUser(req.body);

    res.cookie('token', response.token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      maxAge: 24 * 60 * 60 * 1000 // 24 hours
    });

    return return200(response, res);
  } catch (error) {
    if (error.message === "Credenciais inválidas.") {
      return res.status(401).json({
        error: error.message,
        code: "INVALID_CREDENTIALS"
      });
    }

    console.error('Login error:', error);
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