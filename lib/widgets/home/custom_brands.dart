import 'package:flutter/material.dart';

class BrandsWeCarrySection extends StatelessWidget {
  const BrandsWeCarrySection({super.key});

  @override
  Widget build(BuildContext context) {
    const double logoHeight = 45.0;
    return Container(
      width: double.infinity,
      color: const Color.fromRGBO(
        255,
        240,
        197,
        1,
      ), // Light cream yellow background
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section Heading
          const Text(
            'Some Brands We Carry',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 24),

          // Logos Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Brand 1: Royal Canadian Mint
              Expanded(
                child: Image.asset(
                  'assets/brand1.png',
                  height: logoHeight,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(width: 12),

              // Brand 2: Valcambi Suisse
              Expanded(
                child: Image.asset(
                  'assets/brand2.png',
                  height: logoHeight,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(width: 12),

              // Brand 3
              Expanded(
                child: Image.asset(
                  'assets/brand3.png',
                  height: logoHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
