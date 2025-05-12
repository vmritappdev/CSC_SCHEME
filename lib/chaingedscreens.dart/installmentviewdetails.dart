
import 'package:flutter/material.dart';
void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home: Dashboard(),
    ),
  );
}

class Dashboard extends StatelessWidget {

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
    );
  }
}

class AssetTile extends StatelessWidget {
  final String gifPath;
  final String title;
  final String amount;
  final String percentage;
  final String balanceDues;
  final Color color;
  final double value;

  AssetTile({
    required this.gifPath,
    required this.title,
    required this.amount,
    required this.percentage,
    required this.balanceDues,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset(
                  gifPath,
                  height: 40.0,
                  width: 40.0,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          amount,
                          style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$percentage",
                          style: TextStyle(color: Colors.grey),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: balanceDues.split(":")[0] + ": ",
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextSpan(
                                text: balanceDues.split(":")[1],
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              

              
           

            ],
          ),
        ),
      ],
    );
  }
}

