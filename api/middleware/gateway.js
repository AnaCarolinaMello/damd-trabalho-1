import axios from 'axios';
import { return200, return404, return500, return503 } from '../util/index.js';
import { serviceRegistry } from '../controllers/registry.controller.js';
import { authenticateToken, requireRole } from './auth.js';
import { isPublicRoute, getRequiredRole } from '../config/routes.js';

// Routes that don't require authentication
const publicRoutes = ['/authentication/login', '/authentication/', '/authentication/health'];

export async function dynamicRouter(req, res, next) {
    const urlParts = req.path.split('/').filter((part) => part);

    if (urlParts.length === 0) return next();

    const serviceName = urlParts[0];
    const fullPath = req.path;

    // Check if route requires authentication
    if (isPublicRoute(fullPath)) {
        // Route to service without authentication
        return await routeToService(req, res, next, serviceName, urlParts);
    }

    // Check if route requires specific role
    const requiredRole = getRequiredRole(fullPath);

    if (requiredRole) {
        // Apply authentication and role-based middleware
        return authenticateToken(req, res, (err) => {
            if (err) return next(err);

            return requireRole(requiredRole)(req, res, async () => {
                await routeToService(req, res, next, serviceName, urlParts);
            });
        });
    }

    return authenticateToken(req, res, async () => {
        await routeToService(req, res, next, serviceName, urlParts);
    });
}

async function routeToService(req, res, next, serviceName, urlParts) {
    try {
        const service = serviceRegistry.getService(serviceName);

        if (!service) return return404(res, `Service ${serviceName} not found`);

        const servicePath = '/' + urlParts.slice(1).join('/');
        const queryString = req.url.includes('?') ? req.url.split('?')[1] : '';
        const fullServiceUrl = `${service.url}${servicePath}${queryString ? '?' + queryString : ''}`;

        const axiosConfig = {
            method: req.method.toLowerCase(),
            url: fullServiceUrl,
            headers: {
                ...req.headers,
                host: undefined,
                'x-user-id': req.user?.id,
                'x-user-email': req.user?.email,
                'x-user-type': req.user?.type,
            },
            timeout: 30000,
            responseType: 'json',
        };

        if (['post', 'put', 'patch'].includes(req.method.toLowerCase())) {
            axiosConfig.data = req;
            axiosConfig.headers['transfer-encoding'] = undefined;
        }

        const response = await axios(axiosConfig);

        return return200(response.data, res);
    } catch (error) {
        if (error.message.includes('not found') || error.message.includes('unhealthy')) return next();

        console.error(`Gateway error for ${serviceName}:`, error.message);
        console.error(`Full error:`, error);

        if (error.code === 'ECONNABORTED') {
            return return503(res, `Timeout error reaching ${serviceName} service`);
        }

        if (error.response) return return500(error.response.data, res);

        return return503(res, `Unable to reach ${serviceName} service`);
    }
}

export function loadBalancer(serviceName) {
    return serviceRegistry.getService(serviceName);
}
