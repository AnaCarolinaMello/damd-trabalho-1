import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const serviceName = process.env.SERVICE_NAME;
const gatewayUrl = process.env.GATEWAY_URL;

export async function registerWithGateway() {
    try {
        await axios.post(`${gatewayUrl}/gateway/register`, {
            name: serviceName,
            url: process.env.SERVICE_URL,
            healthEndpoint: '/health',
        });
    } catch (error) {
        setTimeout(registerWithGateway, 5000);
    }
}

export async function unregisterFromGateway() {
    try {
        await axios.delete(`${gatewayUrl}/gateway/unregister/${serviceName}`);
    } catch (error) {
        setTimeout(unregisterFromGateway, 5000);
    }
}
