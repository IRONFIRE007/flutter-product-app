import 'package:flutter/material.dart';
import 'package:product_app/models/models.dart';
import 'package:product_app/screens/loading_screen.dart';
import 'package:product_app/services/services.dart';
import 'package:product_app/widgets/product_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductsService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    if (productService.isLoading) return const LoadingScreen();

    final producs = productService.producs;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                authService.logout();
                Navigator.pushReplacementNamed(context, 'login');
              },
              icon: const Icon(Icons.login_outlined))
        ],
        title: const Center(
          child: Text('Products'),
        ),
      ),
      body: ListView.builder(
        itemCount: producs.length,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
            child: ProductCard(
              product: producs[index],
            ),
            onTap: () {
              productService.selectdProduct = producs[index].copy();
              Navigator.pushNamed(context, 'product');
            }),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          productService.selectdProduct =
              Product(available: false, price: 0, name: '');
          Navigator.pushNamed(context, 'product');
        },
      ),
    );
  }
}
