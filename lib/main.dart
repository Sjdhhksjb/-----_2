import 'package:flutter/material.dart';

void main() {
  runApp(const AbuJannahStoreApp());
}

class AbuJannahStoreApp extends StatelessWidget {
  const AbuJannahStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'متجر أبو جنة',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: StoreHomeScreen(),
      ),
    );
  }
}

// نموذج بيانات المنتج
class Product {
  final int id;
  final String name;
  final double price;
  final IconData icon;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
  });
}

// عنصر داخل سلة المشتريات
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class StoreHomeScreen extends StatefulWidget {
  const StoreHomeScreen({super.key});

  @override
  State<StoreHomeScreen> createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends State<StoreHomeScreen> {
  // قائمة المنتجات المعروضة
  final List<Product> catalog = const [
    Product(id: 1, name: 'عسل سدر طبيعي', price: 25000, icon: Icons.hive_rounded),
    Product(id: 2, name: 'زيت زيتون عصرة أولى', price: 18000, icon: Icons.water_drop),
    Product(id: 3, name: 'تمور برحي فاخرة', price: 10000, icon: Icons.eco),
    Product(id: 4, name: 'مكسرات مشكلة محمصة', price: 15000, icon: Icons.shopping_basket),
    Product(id: 5, name: 'هيل حب هندي', price: 12000, icon: Icons.grain),
    Product(id: 6, name: 'زعفران أصلي', price: 30000, icon: Icons.auto_awesome),
  ];

  // سلة المشتريات
  final Map<int, CartItem> _cart = {};

  void _addToCart(Product product) {
    setState(() {
      if (_cart.containsKey(product.id)) {
        _cart[product.id]!.quantity++;
      } else {
        _cart[product.id] = CartItem(product: product);
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة "${product.name}" إلى السلة'),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeFromCart(int productId) {
    setState(() {
      if (_cart.containsKey(productId)) {
        if (_cart[productId]!.quantity > 1) {
          _cart[productId]!.quantity--;
        } else {
          _cart.remove(productId);
        }
      }
    });
  }

  int get _cartCount => _cart.values.fold(0, (sum, item) => sum + item.quantity);

  double get _cartTotal => _cart.values.fold(
      0.0, (sum, item) => sum + (item.product.price * item.quantity));

  void _openCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'سلة المشتريات',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: _cart.isEmpty
                          ? const Center(
                              child: Text(
                                'السلة فارغة حالياً',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView(
                              children: _cart.values.map((item) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: Icon(item.product.icon, color: Colors.teal),
                                    title: Text(item.product.name),
                                    subtitle: Text(
                                      '${(item.product.price * item.quantity).toStringAsFixed(0)} د.ع',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                          onPressed: () {
                                            _removeFromCart(item.product.id);
                                            setSheetState(() {});
                                          },
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                                          onPressed: () {
                                            _addToCart(item.product);
                                            setSheetState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'المجموع الإجمالي:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_cartTotal.toStringAsFixed(0)} د.ع',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _cart.isEmpty
                            ? null
                            : () {
                                Navigator.pop(context);
                                _showConfirmationDialog();
                              },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('تأكيد الطلب'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تم استلام الطلب بنجاح'),
          content: Text(
            'شكراً لطلبك من متجر أبو جنة.\nالقيمة الإجمالية: ${_cartTotal.toStringAsFixed(0)} د.ع',
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _cart.clear());
                Navigator.pop(ctx);
              },
              child: const Text('حسناً'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'متجر أبو جنة',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: _openCartSheet,
              ),
              if (_cartCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$_cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: catalog.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final item = catalog[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.teal.shade50,
                    child: Icon(item.icon, size: 36, color: Colors.teal),
                  ),
                  Column(
                    children: [
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.price.toStringAsFixed(0)} د.ع',
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                      onPressed: () => _addToCart(item),
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: const Text('إضافة', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
