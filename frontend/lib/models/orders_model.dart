import 'package:frontend/models/oreder_items_model.dart';

class Order {
  final int id;
  final int idUsers;
  final int idRes;
  final String status;
  final double totalPrice;
  final String paymentStatus;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.idUsers,
    required this.idRes,
    required this.status,
    required this.totalPrice,
    required this.paymentStatus,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      idUsers: json['id_users'],
      idRes: json['id_res'],
      status: json['status'],
      totalPrice: double.parse(json['total_price'].toString()),
      paymentStatus: json['payment_status'],
      createdAt: json['created_at'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}
