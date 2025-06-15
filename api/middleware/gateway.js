import axios from "axios";
import { return200, return404, return503 } from "../util/index.js";
import { serviceRegistry } from "../controllers/registry.controller.js";

export async function dynamicRouter(req, res, next) {
  const urlParts = req.path.split("/").filter((part) => part);

  if (urlParts.length === 0) return next();

  const serviceName = urlParts[0];

  try {
    console.log(serviceName);
    const service = serviceRegistry.getService(serviceName);

    console.log(service);
    if (!service) return return404(res, `Service ${serviceName} not found`);

    const servicePath = "/" + urlParts.slice(1).join("/");
    console.log(servicePath);
    const queryString = req.url.includes("?") ? req.url.split("?")[1] : "";
    console.log(queryString);
    const fullServiceUrl = `${service.url}${servicePath}${
      queryString ? "?" + queryString : ""
    }`;
    console.log(fullServiceUrl);
    console.log(`Routing ${req.method} ${req.path} -> ${fullServiceUrl}`);

    const axiosConfig = {
      method: req.method.toLowerCase(),
      url: fullServiceUrl,
      headers: {
        ...req.headers,
        host: undefined,
      },
      timeout: 30000,
    };

    if (["post", "put", "patch"].includes(req.method.toLowerCase()))
      axiosConfig.data = req.body;

    const response = await axios(axiosConfig);

    return return200(response.data, res);
  } catch (error) {
    if (
      error.message.includes("not found") ||
      error.message.includes("unhealthy")
    )
      return next();

    console.error(`Gateway error for ${serviceName}:`, error.message);

    if (error.response) return return503(res, error.response.data);

    return return503(res, `Unable to reach ${serviceName} service`);
  }
}

export function loadBalancer(serviceName) {
  return serviceRegistry.getService(serviceName);
}
