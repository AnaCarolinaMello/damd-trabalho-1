export const publicRoutes = [
    '/auth/login',
    '/auth/',
    '/auth/health',
    '/order/health',
    '/tracking/health',
    '/gateway/register',
    '/gateway/unregister',
    '/gateway/services',
    '/gateway/health',
];

export const roleBasedRoutes = {
    driver: [
        '/order/driver',
        '/order/accept',
        '/order/deliver',
        '/order/available'
    ],
    customer: [
        '/order/customer',
        '/order/user',
        '/order/rate',
        '/order/cancel'
    ],
};

export function isPublicRoute(path) {
    return publicRoutes.some((route) => path.startsWith(route));
}

export function getRequiredRole(path) {
    for (const [role, routes] of Object.entries(roleBasedRoutes)) {
        if (routes.some((route) => path.startsWith(route))) {
            return role;
        }
    }
    return null;
}
