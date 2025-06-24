import conectarRabbitMQ from "../util/amqp.js";
import dotenv from "dotenv";

dotenv.config();

const queueName = process.env.RABBITMQ_QUEUE_NAME;

export async function createNotification() {
  let connection, channel;
  try {
    ({ connection, channel } = await conectarRabbitMQ());

    // Publicar mensagem no exchange
    await channel.consume(queueName, (msg) => {
      if (msg === null) return;

      const notification = JSON.parse(msg.content.toString());
      console.log('Processando notificação:', notification);
      console.log('Notificação recebida:', notification);
      
      // Processar a notificação aqui
      // TODO: Implementar lógica de processamento  
      channel.ack(msg);
    });

    return notification;
  } catch (error) {
    console.error("Erro ao publicar mensagem no RabbitMQ:", error);
    throw error;
  } finally {
    if (channel) await channel.close();

    if (connection) await connection.close();
  }
}
