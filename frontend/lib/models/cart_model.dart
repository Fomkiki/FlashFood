import 'cart_item_model.dart';

class CartResponse {
  final List<CartItem> result;

  CartResponse({required this.result});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      result: List<CartItem>.from(
        json['result'].map((x) => CartItem.fromJson(x)),
      ),
    );
  }
}
