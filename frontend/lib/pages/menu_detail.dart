import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:http/http.dart' as http;

class MenuDetailPage extends StatefulWidget {
  final dynamic menu;
  final dynamic restaurant;

  const MenuDetailPage({
    super.key,
    required this.menu,
    required this.restaurant,
  });

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  int amount = 1;
  bool isAddingToCart = false;

  double get unitPrice {
    final rawPrice = widget.menu['price'];
    if (rawPrice is num) return rawPrice.toDouble();
    return double.tryParse(rawPrice?.toString() ?? '0') ?? 0;
  }

  double get sumPrice => unitPrice * amount;

  String formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  Future<void> _handleAddToCart() async {
    final menuIdRaw = widget.menu['id'];
    final menuId = menuIdRaw is int
        ? menuIdRaw
        : int.tryParse(menuIdRaw?.toString() ?? '');

    if (menuId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid menu id')),
      );
      return;
    }

    setState(() {
      isAddingToCart = true;
    });

    try {
      final headers = await ApiService.getAuthHeader();
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/cart/add/$menuId'),
        headers: headers,
        body: jsonEncode({'amount': amount}),
      );

      if (response.statusCode != 201) {
        try {
          final body = jsonDecode(response.body);
          throw Exception(body['message'] ?? 'Failed to add to cart');
        } catch (_) {
          throw Exception('Failed to add to cart');
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $amount item(s) to cart')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menu['name_menu'] ?? 'Menu Detail'),backgroundColor: Colors.orange
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menu image
                    if ((widget.menu['img_url'] ?? '').toString().isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          "http://10.0.2.2:5000/${(widget.menu['img_url'] ?? '').toString().replaceAll("\\", "/")}",
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: double.infinity,
                                height: 300,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 50),
                              ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Menu name
                    Text(
                      widget.menu['name_menu'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Note
                    Text(
                      'Note: ${widget.menu['note'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status
                    Text(
                      widget.menu['status_menu'] == 'on_sale'
                          ? 'On sale'
                          : widget.menu['status_menu'] == 'soldout'
                              ? 'Sold out'
                              : 'N/A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.menu['status_menu'] == 'on_sale'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Quantity row pinned to bottom
            if (widget.menu['status_menu'] == 'on_sale')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (amount > 1) {
                              setState(() {
                                amount--;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          amount.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              amount++;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        const Spacer(),
                        Text(
                          '${formatPrice(sumPrice)} บาท',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: isAddingToCart ? null : _handleAddToCart,
                      child: isAddingToCart
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add to Cart'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
