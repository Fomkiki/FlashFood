import 'package:frontend/models/menu_model.dart';

class OrderItem {
  final int id;
  final int idMenu;
  final int amount;
  final double pricePerItem;
  final double totalPrice;
  final MenuModel menu;

  OrderItem({
    required this.id,
    required this.idMenu,
    required this.amount,
    required this.pricePerItem,
    required this.totalPrice,
    required this.menu,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      idMenu: json['id_menu'],
      amount: json['amount'],
      pricePerItem: double.parse(json['price_per_item'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      menu: MenuModel.fromJson(json['menu']),
    );
  }
}
