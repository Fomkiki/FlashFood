import db from "../config/db.js";

async function createCart(id_users) {
  const sql = "INSERT INTO cart (id_users, status)VALUES (?, ?)";
  const [result] = await db.query(sql, [id_users, "active"]);
  return result;
}

export const addCartItem = async (data) => {
  const { id_menu, id_users, amount } = data;
  if (!amount || amount <= 0) {
    throw new Error("Invalid amount");
  }
  const [menuRows] = await db.query("SELECT * FROM menu WHERE id = ?",[id_menu]);
  if (menuRows.length === 0) {
    throw new Error("Menu item not found");
  }

  const { id_res, price } = menuRows[0];
  let [cart] = await db.query("SELECT * FROM cart WHERE id_users = ? AND status = ? LIMIT 1",[id_users, "active"]);
  let cart_id;
  if (cart.length === 0) {
    const newCart = await createCart(id_users);
    cart_id = newCart.insertId;
  } else {
    cart_id = cart[0].id;
  }
  const [cartItems] = await db.query("SELECT id_res FROM cart_items WHERE id_cart = ? LIMIT 1",[cart_id]);
  if (cartItems.length > 0 && cartItems[0].id_res !== id_res) {
    throw new Error("Cannot add items from different restaurant");
  }
  const [existItem] = await db.query("SELECT * FROM cart_items WHERE id_cart = ? AND id_menu = ?",[cart_id, id_menu]);
  if (existItem.length > 0) {
    const newAmount = existItem[0].amount + amount;
    const newTotal = newAmount * price;
    await db.query("UPDATE cart_items SET amount = ?, total_price = ? WHERE id = ?",[newAmount, newTotal, existItem[0].id]);
    return existItem[0].id;
  }

  const sql = "INSERT INTO cart_items(id_res, id_cart, id_menu, amount, price_per_item, total_price)VALUES (?, ?, ?, ?, ?, ?)";
  const [result] = await db.query(sql, [id_res,cart_id,id_menu,amount,price,amount * price,]);
  return result.insertId;
};


export const getCartItems = async (id_users) => {
  const [cart] = await db.query("SELECT * FROM cart WHERE id_users = ? AND status = ? LIMIT 1",[id_users, "active"]);
  if(cart.length === 0) throw new Error("Cart not found");
  const [cartItems] = await db.query("SELECT id_menu, name_menu , price , amount , total_price FROM cart_items JOIN menu ON cart_items.id_menu = menu.id WHERE id_cart = ?",[cart[0].id]);
  return cartItems;
  
}