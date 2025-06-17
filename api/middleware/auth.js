import axios from "axios";
import { return401, return500 } from "../util/index.js";
import { serviceRegistry } from "../controllers/registry.controller.js";

export async function authenticateToken(req, res, next) {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1]; // Bearer TOKEN

    if (!token) return return401(res, "Token de acesso requerido");

    const authService = serviceRegistry.getService("auth");

    if (!authService)
      return return500(
        { message: "Authentication service not available" },
        req,
        res
      );

    const response = await axios.post(
      `${authService.url}/validate/${token}`,
      {},
      {
        timeout: 5000,
        headers: {
          "Content-Type": "application/json",
        },
      }
    );

    req.user = response.data;
    next();
  } catch (error) {
    console.error("Authentication error:", error.message);

    if (error.response && error.response.status === 500)
      return return401(res, "Token inválido ou expirado");

    return return500({ message: "Erro na validação do token" }, req, res);
  }
}

export function requireRole(role) {
  return (req, res, next) => {
    if (!req.user) return return401(res, "Usuário não autenticado");

    if (req.user.type !== role)
      return return401(res, `Acesso negado. Role ${role} requerida`);

    next();
  };
}
