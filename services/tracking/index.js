import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import trackingRoutes from './routes/tracking.routes.js';
import { return200 } from './util/index.js';
import { registerWithGateway, unregisterFromGateway } from './controller/registry.controller.js';

const app = express();

dotenv.config();

const gatewayUrl = process.env.GATEWAY_URL;

app.use(
    cors({
        origin: gatewayUrl,
    })
);

app.use(express.json());

app.get('/health', (_, res) => {
    return return200('healthy', res);
});

app.use('/', trackingRoutes);

const PORT = process.env.PORT;

app.listen(PORT, async () => {
    console.log(`Tracking service running on port ${PORT}`);
    await registerWithGateway();
});

process.on('SIGTERM', async () => {
    await unregisterFromGateway();
    process.exit(0);
});

process.on('SIGINT', async () => {
    await unregisterFromGateway();
    process.exit(0);
});
