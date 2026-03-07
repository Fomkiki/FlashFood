import db from "../config/db.js";


export const getOrders = async (id_users) => {
    const sql = "SELECT * FROM orders WHERE id_users = ? ORDER BY id DESC";
    const [rows] = await db.query(sql, [id_users]);
    return rows;
};


export const getOrderById = async (id) => {
    const sql = "SELECT orders.id as id_orders,status,name_menu, amount FROM orders JOIN order_items ON orders.id = order_items.id_order JOIN menu ON order_items.id_menu = menu.id WHERE orders.id = ?";
    const [rows] = await db.query(sql, [id]);
    return rows;
}


export const getOrdersByRes = async (id_res) => {
    const sql = "SELECT * FROM orders WHERE id_res = ? AND payment_status = 'mock_paid' ORDER BY id DESC";
    const [rows] = await db.query(sql, [id_res]);
    return rows;
}


export const paymentOrder = async (id , id_users) => {
    const sql = "UPDATE orders SET payment_status = 'mock_paid'  WHERE id = ? AND id_users = ?";
    const [rows] = await db.query(sql, [id , id_users] );
    return rows;
}

export const updateOrderStatus = async (id, status) => {
    const sql = "UPDATE orders SET status = ? WHERE id = ?";
    const [rows] = await db.query(sql, [status, id]);
    return rows;
}