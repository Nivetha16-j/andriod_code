import 'package:flutter/material.dart';

class CouponWidget extends StatelessWidget {
  const CouponWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "ENTER COUPON CODE",
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          SizedBox(
            width: 90,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff991B1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () {},
              child: Text("Apply", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
