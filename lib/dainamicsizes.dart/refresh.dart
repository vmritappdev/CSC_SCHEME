import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PremiumRefreshScreen extends StatefulWidget {
  @override
  _PremiumRefreshScreenState createState() => _PremiumRefreshScreenState();
}

class _PremiumRefreshScreenState extends State<PremiumRefreshScreen> {
  List<String> items = ["Item 1", "Item 2", "Item 3"];
  final RefreshController _refreshController = RefreshController();

  void _onRefresh() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
     // items = ["New 1", "New 2", "New 3", "New 4"];
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Premium Pull to Refresh")),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: WaterDropHeader(
          complete: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 8),
              Text("Refresh Completed", style: TextStyle(color: Colors.green)),
            ],
          ),
          waterDropColor: Colors.teal,
        ),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, index) {
            return ListTile(
              title: Text(items[index]),
            );
          },
        ),
      ),
    );
  }
}








