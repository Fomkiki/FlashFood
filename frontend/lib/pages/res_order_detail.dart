import 'package:flutter/material.dart';
import 'package:frontend/services/order_service.dart';

class ResOrderDetailPage extends StatefulWidget {
  final int idOrder;
  const ResOrderDetailPage({super.key, required this.idOrder});

  @override
  State<ResOrderDetailPage> createState() => _ResOrderDetailPageState();
}

class _ResOrderDetailPageState extends State<ResOrderDetailPage> {
  late Future<List<dynamic>> orders;

  @override
  void initState() {
    super.initState();
    orders = OrderService().getDetailOrder(widget.idOrder);
  }

  void reload() {
    setState(() {
      orders = OrderService().getDetailOrder(widget.idOrder);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Detail'),
        backgroundColor: Colors.orange,
      ),

      body: FutureBuilder<List<dynamic>>(
        future: orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final order = snapshot.data!;

          return ListView.separated(
            itemCount: order.length,
            itemBuilder: (context, index) {
              final item = order[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(item['name_menu']),
                  subtitle: Text('Amount: ${item['amount']}'),
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          );
        },
      ),

      bottomNavigationBar: FutureBuilder<List<dynamic>>(
        future: orders,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          final order = snapshot.data!;
          if (order[0]['status'] == 'ready') {
            return const SizedBox();
          }
          return Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                if (order[0]['status'] == 'pending') {
                  bool result = await OrderService().updateOrderStatus(
                    widget.idOrder,
                    'preparing',
                  );
                  if (result) {
                    reload();
                  }
                } else {
                  bool result = await OrderService().updateOrderStatus(
                    widget.idOrder,
                    'ready',
                  );
                  if (result) {
                    reload();
                  }
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: order[0]['status'] == 'pending'
                    ? Colors.orange
                    : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              child: Text(
                order[0]['status'] == 'pending' ? 'Taking Order' : 'Finished',
              ),
            ),
          );
        },
      ),
    );
  }
}
