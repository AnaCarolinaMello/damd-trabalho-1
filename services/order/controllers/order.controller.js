import {
  listEntity,
  getEntity,
  addEntity,
  updateEntity,
} from "../util/index.js";

export async function getOrders() {
  const orders = await listEntity("orders");
  return orders;
}

export async function getOrderById(id) {
  const order = await getEntity(id, "orders");
  if (!order) throw new Error("Order not found");
  if (order.user_id != userId && order.driver_id != userId)
    throw new Error("You are not allowed to access this order");
  return order;
}

export async function getOrdersByUserId(userId) {
  const orders = await listEntity("orders", "*", {
    user_id: userId,
  });
  return orders;
}

export async function getAvailableOrders() {
  const orders = await listEntity("orders", "*", {
    status: "pending",
  });
  return orders;
}

export async function getDriverOrder(driverId) {
  const orders = await listEntity("orders", "*", {
    driver_id: driverId,
    status: "accepted",
  });
  const order = orders[0];
  if (!order) throw new Error("No order found");

  return order;
}

export async function createOrder(order) {
  return await addEntity(order, "orders");
}

export async function acceptOrder(orderId, driverId) {
  const order = await getEntity(orderId, "orders");
  if (!order) throw new Error("Order not found");
  if (order.status !== "pending") throw new Error("Order is not available");

  return await updateEntity(
    orderId,
    {
      status: "accepted",
      driver_id: driverId,
    },
    "orders"
  );
}

export async function deliverOrder(orderId, photo) {
  const order = await getEntity(orderId, "orders");
  if (!order) throw new Error("Order not found");
  if (order.status !== "accepted") throw new Error("Order is not in delivery");

  return await updateEntity(
    orderId,
    {
      status: "delivered",
      photo: photo,
    },
    "orders"
  );
}

export async function rateOrder(orderId, userId, rating) {
  const order = await getEntity(orderId, "orders");
  if (!order) throw new Error("Order not found");
  if (order.user_id != userId)
    throw new Error("You are not allowed to rate this order");
  if (order.status !== "delivered")
    throw new Error("Order must be delivered to be rated");

  return await updateEntity(orderId, { rating }, "orders");
}

export async function cancelOrder(id, userId) {
  const order = await getEntity(id, "orders");
  if (!order) throw new Error("Order not found");
  if (order.user_id != userId)
    throw new Error("You are not allowed to cancel this order");
  if (order.status != "pending")
    throw new Error("Cannot cancel order in current status");

  return await updateEntity(id, { status: "cancelled" }, "orders");
}
