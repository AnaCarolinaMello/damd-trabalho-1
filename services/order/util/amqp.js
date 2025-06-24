import amqp from 'amqplib';
import dotenv from 'dotenv'

dotenv.config();
const amqpUrl = process.env.RABBITMQ_URL;
const queueName = process.env.RABBITMQ_QUEUE_NAME;

async function conectarRabbitMQ() {
    const connection = await amqp.connect(amqpUrl);
    const channel = await connection.createChannel();

    await channel.checkQueue(queueName);

    return { connection, channel };
}

export default conectarRabbitMQ;