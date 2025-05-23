import 'package:flutter/material.dart';

class GoldCardList extends StatefulWidget {
  @override
  _GoldCardListState createState() => _GoldCardListState();
}

class _GoldCardListState extends State<GoldCardList> {
  List<Map<String, String>> cards = [
    {
      "name": "Ramesh",
      "id": "SCH123456",
      "status": "Overdue",
    },
    {
      "name": "Suresh",
      "id": "SCH654321",
      "status": "Due",
    },
  ];

  void removeCard(int index) {
    String removedName = cards[index]["name"]!;
    setState(() {
      cards.removeAt(index);
    });

    // Show snackbar using parent Scaffold
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Removed $removedName's card"),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(), // if used inside scrollable page
      shrinkWrap: true,
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card["name"]!,
                          style: TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text("Scheme ID: ${card["id"]}",
                          style: TextStyle(fontSize: 11.5)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    card["status"]!,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () => removeCard(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
