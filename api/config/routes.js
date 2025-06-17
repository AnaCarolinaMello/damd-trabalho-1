export const publicRoutes = [
    '/authentication/login',
    '/authentication/',
    '/authentication/health',
    '/gateway/register',
    '/gateway/unregister',
    '/gateway/services',
    '/gateway/health',
];

export const roleBasedRoutes = {
    driver: ['/tracking', '/order/driver'],
    customer: ['/order/customer'],
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
