import conectarRabbitMQ from "../util/amqp.js";
import axios from "axios";
import dotenv from "dotenv";

dotenv.config();

const queueName = process.env.RABBITMQ_QUEUE_NAME;
const serverlessUrl = process.env.SERVERLESS_URL;

export async function getNotifications(userId) {
  try {
    // Filtrar notificações por usuário
    const response = await axios.get(
      `${serverlessUrl}/api/notifications/${userId}`
    );
    const userNotifications = response.data?.notifications;
    return userNotifications;
  } catch (error) {
    console.error("Erro ao buscar notificações:", error);
    throw error;
  }
}

export async function createNotification() {
  let connection, channel;
  let notification;
  try {
    ({ connection, channel } = await conectarRabbitMQ());

    // Publicar mensagem no exchange
    await channel.consume(queueName, async (msg) => {
      if (msg === null) return;

      notification = JSON.parse(msg.content.toString());
      console.log("Notificação recebida:", notification);

      channel.ack(msg);

      // Fazer POST para a API de notificações
      try {
        await axios.post(
          `${serverlessUrl}/api/create-notification`,
          {
            customer_id: notification.customer_id,
            message: 'Pedido entregue',
            order_id: notification.order_id,
            title: 'Seu pedido foi entregue',
          },
          {
            headers: {
              "Content-Type": "application/json",
            },
          }
        );
      } catch (fetchError) {
        console.error("Erro ao enviar notificação para API:", fetchError);
      }
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

export async function updateNotification(id) {
  try {
    await axios.put(`${serverlessUrl}/api/update-notification/${id}`);
    return { message: "Notification updated" };
  } catch (error) {
    console.error("Erro ao atualizar notificação:", error);
    throw error;
  }
}
