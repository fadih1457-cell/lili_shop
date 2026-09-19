import 'package:flutter/material.dart';

import 'database_helper.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<Map<String, dynamic>> products = [];
  final List<Map<String, dynamic>> cart = [];
  double totalAmount = 0.0;
  final TextEditingController barcodeSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await DatabaseHelper.instance.getProducts();
    setState(() {
      products = data;
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    if (product['stock'] <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عذراً، هذا العطر غير متوفر في المخزن (الكمية صفر)!'),
        ),
      );
      return;
    }
    setState(() {
      cart.add(product);
      totalAmount += product['sell_price'];
    });
  }

  Future<void> _searchAndAddByBarcode(String barcode) async {
    if (barcode.isEmpty) return;
    final product = await DatabaseHelper.instance.getProductByBarcode(barcode);
    if (product != null) {
      _addToCart(product);
      barcodeSearchController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على عطر بهذا الباركود!')),
      );
    }
  }

  Future<void> _completeCheckout() async {
    // خصم الكميات من المخزن
    for (var item in cart) {
      int newStock = item['stock'] - 1;
      await DatabaseHelper.instance.update({
        ...item,
        'stock': newStock < 0 ? 0 : newStock,
      });
    }

    setState(() {
      cart.clear();
      totalAmount = 0.0;
    });
    _loadProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إتمام البيع بنجاح وتحديث المخزن!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نقطة البيع الكاشير - Lili Shop')),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: barcodeSearchController,
                    onSubmitted: _searchAndAddByBarcode,
                    decoration: const InputDecoration(
                      labelText: 'امسح أو اكتب الباركود لإضافة العطر...',
                      prefixIcon: Icon(Icons.qr_code_scanner),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isOut = product['stock'] <= 0;
                      return InkWell(
                        onTap: () => _addToCart(product),
                        child: Card(
                          color: isOut ? Colors.grey[300] : Colors.pink[50],
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${product['sell_price']} د.ع',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'المخزن: ${product['stock']}',
                                  style: TextStyle(
                                    color: isOut
                                        ? Colors.red
                                        : Colors.grey[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'سلة المبيعات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(cart[index]['name']),
                          trailing: Text('${cart[index]['sell_price']} د.ع'),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'المجموع: $totalAmount د.ع',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size.fromHeight(45),
                          ),
                          onPressed: cart.isEmpty ? null : _completeCheckout,
                          child: const Text(
                            'إتمام الدفع',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
