import 'package:flutter/material.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // قائمة المخزون بالباركود والتكلفة وسعر البيع والعدد
  final List<Map<String, dynamic>> _inventory = [];

  // متحكمات الحقول
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  // إضافة أو تعديل منتج
  void _saveItem({String? id}) {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) return;

    setState(() {
      if (id == null) {
        // إضافة منتج جديد
        _inventory.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'barcode': _barcodeController.text.isEmpty
              ? 'بدون باركود'
              : _barcodeController.text,
          'name': _nameController.text,
          'cost': _costController.text.isEmpty ? '0' : _costController.text,
          'price': _priceController.text,
          'quantity': _quantityController.text.isEmpty
              ? '0'
              : _quantityController.text,
        });
      } else {
        // تعديل منتج موجود
        final index = _inventory.indexWhere((item) => item['id'] == id);
        if (index != -1) {
          _inventory[index] = {
            'id': id,
            'barcode': _barcodeController.text,
            'name': _nameController.text,
            'cost': _costController.text,
            'price': _priceController.text,
            'quantity': _quantityController.text,
          };
        }
      }
    });

    _clearControllers();
    Navigator.pop(context);
  }

  void _clearControllers() {
    _barcodeController.clear();
    _nameController.clear();
    _costController.clear();
    _priceController.clear();
    _quantityController.clear();
  }

  void _deleteItem(String id) {
    setState(() {
      _inventory.removeWhere((item) => item['id'] == id);
    });
  }

  // نافذة منبثقة للإضافة أو التعديل
  void _showFormDialog({Map<String, dynamic>? itemToEdit}) {
    if (itemToEdit != null) {
      _barcodeController.text = itemToEdit['barcode'];
      _nameController.text = itemToEdit['name'];
      _costController.text = itemToEdit['cost'];
      _priceController.text = itemToEdit['price'];
      _quantityController.text = itemToEdit['quantity'];
    } else {
      _clearControllers();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            itemToEdit == null
                ? 'إضافة منتج جديد للمخزون'
                : 'تعديل بيانات المنتج',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: 'رقم الباركود (Barcode)',
                  ),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'اسم المنتج'),
                ),
                TextField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'سعر التكلفة (د.ع)'),
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'سعر البيع (د.ع)'),
                ),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'العدد (الكمية المتاحة)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearControllers();
                Navigator.pop(context);
              },
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => _saveItem(id: itemToEdit?['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة مخزون البضائع والباركود'),
        backgroundColor: Colors.purple[800],
        foregroundColor: Colors.white,
      ),
      body: _inventory.isEmpty
          ? Center(
              child: Text(
                'لا توجد بضائع في المخزون حالياً.\nاضغط على زر (+) لإضافة أول منتج.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            )
          : ListView.builder(
              itemCount: _inventory.length,
              itemBuilder: (context, index) {
                final item = _inventory[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple[100],
                      child: Icon(Icons.qr_code, color: Colors.purple[800]),
                    ),
                    title: Text(
                      item['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'الباركود: ${item['barcode']}\nالتكلفة: ${item['cost']} | البيع: ${item['price']} | العدد: ${item['quantity']}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر التعديل
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showFormDialog(itemToEdit: item),
                        ),
                        // زر الحذف
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.purple[800],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
