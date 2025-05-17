import 'package:flutter/material.dart';

class USDepositPopup extends StatelessWidget {
  const USDepositPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        elevation: 4,
        margin: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            color: Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

               // SizedBox(height: 60,),
              // Green check icon
              const Icon(Icons.check_circle, color: Colors.green, size: 28),

              const SizedBox(width: 12),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [

                   // SizedBox(height: 60,),
                    Text(
                      "US Deposit credited to your US a/c",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "\$5.25 for US deposits credited on 14 May 2025, 06:40 PM",
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Close icon
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Or any close action
                },
                child: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
