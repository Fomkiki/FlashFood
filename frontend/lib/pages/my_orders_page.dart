import 'package:flutter/material.dart';
import 'package:frontend/models/orders_model.dart';
import 'package:frontend/pages/payment_page.dart';
import 'package:frontend/services/order_service.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  late Future<List<Map<String, dynamic>>> myorders;

  @override
  void initState() {
    super.initState();
    myorders = OrderService().getOrders();
  }

  void reloadOrders() {
    setState(() {
      myorders = OrderService().getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: myorders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Order ID + Payment Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Order #${order['id']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            order['payment_status'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: order['payment_status'] == 'unpaid'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// Order Status
                      Text('Status: ${order['status']}'),

                      const SizedBox(height: 4),

                      /// Total Price
                      Text('Total Price: ฿${order['total_price']}'),

                      const SizedBox(height: 10),

                      /// Payment Text
                      Text('Payment: ${order['payment_status']}'),

                      const SizedBox(height: 10),

                      /// ปุ่มไปจ่ายเงิน
                      if (order['payment_status'] == 'unpaid')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentPage(
                                    total: double.parse(order['total_price']),
                                    idOrder: order['id'],
                                  ),
                                ),
                              );
                            },
                            child: const Text('Go to Payment'),
                          ),
                        ),

                      /// ปุ่มรับสินค้า
                      if (order['status'] == 'ready')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              bool result = await OrderService()
                                  .updateOrderStatus(order['id'], 'completed');

                              if (result) {
                                reloadOrders();
                              }
                            },
                            child: const Text('Receive Order'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
