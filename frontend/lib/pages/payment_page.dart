import 'package:flutter/material.dart';
import 'package:frontend/models/orders_model.dart';
import 'package:frontend/pages/my_orders_page.dart';
import 'package:frontend/services/order_service.dart';

class PaymentPage extends StatefulWidget {
  final double total;
  final int idOrder;

  const PaymentPage({super.key, required this.total, required this.idOrder});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scan QR Code',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Image.asset('assets/qr_mockup.png', height: 300, width: 300),
            Text(
              'Total: \$${widget.total}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                bool result = await OrderService().paymentOrder(widget.idOrder);
                if (result) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOrdersPage(),
                    ),
                  );
                }
              },
              child: const Text(
                'Pay Now',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
