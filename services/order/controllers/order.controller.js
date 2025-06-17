import {
  getEntity,
  addEntity,
  updateEntity,
  query,
} from "../util/index.js";

const defaultQuery = `
  SELECT o.*, json_build_object('street', a.street, 'number', a.number, 'complement', a.complement, 'neighborhood', a.neighborhood, 'city', a.city, 'state', a.state, 'zipCode', a.zip_code) as address, json_agg(json_build_object('id', i.id, 'name', i.name, 'description', i.description, 'price', i.price, 'quantity', i.quantity)) as items FROM orders o JOIN addresses a ON o.address_id = a.id LEFT JOIN order_items i ON o.id = i.order_id GROUP BY o.id, a.street, a.number, a.complement, a.neighborhood, a.city, a.state, a.zip_code
`;

export async function getOrders() {
  const orders = await query(defaultQuery);
  return orders;
}

export async function getOrderById(id, userId) {
  console.log(`Getting order by ID: ${id}, userId: ${userId}`);
  const orders = await query(
    defaultQuery.replace("GROUP BY", "WHERE o.id = $1 GROUP BY"),
    [id]
  );
  const order = orders[0];
  if (!order) throw new Error("Order not found");
  if (userId && order.customer_id != userId && order.driver_id != userId)
    throw new Error("You are not allowed to access this order");
  return order;
}

export async function getOrdersByUserId(userId) {
  const orders = await query(
    defaultQuery.replace("GROUP BY", "WHERE o.customer_id = $1 GROUP BY"),
    [userId]
  );
  return orders;
}

export async function getAvailableOrders() {
  const orders = await query(
    defaultQuery.replace("GROUP BY", "WHERE o.status = $1 GROUP BY"),
    ["pending"]
  );
  return orders;
}

export async function getDriverOrder(driverId) {
  const orders = await query(
    defaultQuery.replace("GROUP BY", "WHERE o.driver_id = $1 AND o.status = $2 GROUP BY"),
    [driverId, "accepted"]
  );

  const order = orders[0];
  if (!order) throw new Error("No order found");

  return order;
}

export async function createOrder(order) {
  if (order.address) {
    const address = await addEntity(order.address, "addresses");
    order.address_id = address.id;
    delete order.address;
  }
  const items = order.items;
  delete order.items;

  order.date = new Date();
  order.time = new Date().toTimeString().split(" ")[0]; // Extract HH:MM:SS
  const newOrder = await addEntity(order, "orders");

  if (items) {
    for (const item of items) {
      item.order_id = newOrder.id;
      await addEntity(item, "order_items");
    }
    delete newOrder.items;
  }

  return newOrder;
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

export async function deliverOrder(orderId, userId, photo) {
  const order = await getEntity(orderId, "orders");
  if (!order) throw new Error("Order not found");
  if (order.status !== "accepted") throw new Error("Order is not in delivery");
  if (order.driver_id != userId) throw new Error("You are not the driver of this order");

  return await updateEntity(
    orderId,
    {
      status: "delivered",
      image: photo,
    },
    "orders"
  );
}

export async function rateOrder(orderId, userId, rating) {
  const order = await getEntity(orderId, "orders");
  if (!order) throw new Error("Order not found");
  if (order.customer_id != userId)
    throw new Error("You are not allowed to rate this order");
  if (order.status !== "delivered")
    throw new Error("Order must be delivered to be rated");

  return await updateEntity(orderId, { rating }, "orders");
}

export async function cancelOrder(id, userId) {
  const order = await getEntity(id, "orders");
  if (!order) throw new Error("Order not found");
  if (order.customer_id != userId)
    throw new Error("You are not allowed to cancel this order");
  if (order.status != "pending")
    throw new Error("Cannot cancel order in current status");

  return await updateEntity(id, { status: "cancelled" }, "orders");
}
