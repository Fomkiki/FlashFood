import 'package:flutter/material.dart';
import 'package:frontend/pages/res_order_detail.dart';
import 'package:frontend/services/order_service.dart';

class ResOrdersPage extends StatefulWidget {
  final int id_res;
  const ResOrdersPage({super.key, required this.id_res});

  @override
  State<ResOrdersPage> createState() => _ResOrdersPageState();
}

class _ResOrdersPageState extends State<ResOrdersPage> {
  late Future<List<dynamic>> resOrders;

  void initState() {
    super.initState();
    resOrders = OrderService().getOrdersRes(widget.id_res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Orders'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder(
        future: resOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final orders = snapshot.data!;
          return ListView.separated(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ResOrderDetailPage(idOrder: order['id']),
                      ),
                    );
                  },
                  title: Text('Order ID: ${order['id']}'),
                  subtitle: Text('Status: ${order['status']}'),
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          );
        },
      ),
    );
  }
}
