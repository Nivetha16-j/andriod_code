import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/widgets/cart/custom_cartitem.dart';
import 'package:junubullion/widgets/cart/custom_summary.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   centerTitle: true,
      //   title: const Text(
      //     "Cart",
      //     style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      //   ),
      // ),

      // bottomNavigationBar: SafeArea(
      //   minimum: const EdgeInsets.all(20),
      //   child: SizedBox(
      //     height: 55,
      //     child: ElevatedButton(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: const Color(0xff991B1E),
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(30),
      //         ),
      //       ),
      //       onPressed: () {},
      //       child: const Text(
      //         "Check Out",
      //         style: TextStyle(fontSize: 20, color: Colors.white),
      //       ),
      //     ),
      //   ),
      // ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.cartItems.isEmpty) {
            return const Center(child: Text("No products in cart"));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Your cart",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.cartItems.length,
                itemBuilder: (context, index) {
                  return CartItemCard(item: provider.cartItems[index]);
                },
              ),

              const SizedBox(height: 30),

              const Text(
                "Cart Summary",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              const SummaryWidget(),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}
