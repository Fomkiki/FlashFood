class CartItem {
  final int idMenu;
  final String nameMenu;
  final double price;
  final int amount;
  final double totalPrice;

  CartItem({
    required this.idMenu,
    required this.nameMenu,
    required this.price,
    required this.amount,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      idMenu: json['id_menu'],
      nameMenu: json['name_menu'],
      price: double.parse(json['price'].toString()),
      amount: json['amount'],
      totalPrice: double.parse(json['total_price'].toString()),
    );
  }
}
