import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const orderApiUrl = process.env.ORDER_API_URL;

export async function getOrders() {
  const response = await axios.get(orderApiUrl);
  return response.data;
}

export async function getOrderById(id, userId) {
  const response = await axios.get(`${orderApiUrl}/${id}?userId=${userId}`);
  return response.data;
}

export async function getOrdersByUserId(userId) {
  const response = await axios.get(`${orderApiUrl}/user/${userId}`);
  return response.data;
}

export async function getAvailableOrders() {
  const response = await axios.get(`${orderApiUrl}/available`);
  return response.data;
}

export async function getDriverOrder(driverId) {
  const response = await axios.get(`${orderApiUrl}/driver/${driverId}`);
  return response.data;
}

export async function createOrder(order) {
  const response = await axios.post(`${orderApiUrl}`, order);
  return response.data;
}

export async function acceptOrder(orderId, driverId) {
  const response = await axios.post(`${orderApiUrl}/accept/${orderId}`, { driverId });
  return response.data;
}

export async function deliverOrder(orderId, userId, photo) {
  const response = await axios.post(`${orderApiUrl}/deliver/${orderId}`, { userId, photo });
  return response.data;
}

export async function rateOrder(orderId, userId, rating) {
  const response = await axios.post(`${orderApiUrl}/rate/${orderId}`, { userId, rating });
  return response.data;
}

export async function cancelOrder(id, userId) {
  const response = await axios.post(`${orderApiUrl}/cancel/${id}`, { userId });
  return response.data;
}
