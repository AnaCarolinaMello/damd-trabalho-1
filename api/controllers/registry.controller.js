import axios from "axios";

class ServiceRegistry {
  constructor() {
    this.services = new Map();
    this.healthCheckInterval = 30000;
    this.startHealthCheck();
  }

  register(name, url, healthEndpoint = "/health") {
    console.log(`Registering service: ${name} at ${url}`);

    this.services.set(name, {
      url,
      healthEndpoint,
      lastHealthCheck: Date.now(),
      healthy: true,
      registeredAt: Date.now(),
    });

    return {
      success: true,
      message: `Service ${name} registered successfully`,
    };
  }

  unregister(name) {
    const removed = this.services.delete(name);
    console.log(`Unregistering service: ${name}`);

    return {
      success: removed,
      message: removed
        ? `Service ${name} unregistered successfully`
        : `Service ${name} not found`,
    };
  }

  getService(name) {
    const service = this.services.get(name);

    if (!service) throw new Error(`Service ${name} not found`);

    if (!service.healthy) throw new Error(`Service ${name} is unhealthy`);

    return service;
  }

  getAllServices() {
    return Array.from(this.services.entries()).map(([name, service]) => ({
      name,
      ...service,
    }));
  }

  async healthCheck(name, service) {
    try {
      const response = await axios.get(
        `${service.url}${service.healthEndpoint}`,
        { timeout: 5000 }
      );

      service.healthy = response.status === 200;
      service.lastHealthCheck = Date.now();

      return service.healthy;
    } catch (error) {
      console.warn(`Health check failed for ${name}:`, error.message);
      service.healthy = false;
      service.lastHealthCheck = Date.now();
      return false;
    }
  }

  async startHealthCheck() {
    setInterval(async () => {
      const healthPromises = Array.from(this.services.entries()).map(
        ([name, service]) => this.healthCheck(name, service)
      );

      await Promise.allSettled(healthPromises);

      const now = Date.now();
      for (const [name, service] of this.services.entries()) {
        if (!service.healthy && now - service.lastHealthCheck > 120000)
          this.services.delete(name);
      }
    }, this.healthCheckInterval);
  }
}

export const serviceRegistry = new ServiceRegistry();
export default ServiceRegistry;
