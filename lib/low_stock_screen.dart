import 'package:flutter/material.dart';

import 'database_helper.dart';

class LowStockScreen extends StatefulWidget {
  const LowStockScreen({super.key});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  List<Map<String, dynamic>> lowStockProducts = [];

  @override
  void initState() {
    super.initState();
    _loadLowStock();
  }

  Future<void> _loadLowStock() async {
    final data = await DatabaseHelper.instance.getOutOfStockProducts();
    setState(() {
      lowStockProducts = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة نقص المخزون (نفدت الكمية)'),
        backgroundColor: Colors.red,
      ),
      body: lowStockProducts.isEmpty
          ? const Center(
              child: Text(
                'ممتاز! لا توجد منتجات نفدت من المخزن.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: lowStockProducts.length,
              itemBuilder: (context, index) {
                final p = lowStockProducts[index];
                return Card(
                  color: Colors.red[100],
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text(
                      p['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'الباركود: ${p['barcode']} | الكمية المتبقية: ${p['stock']}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
