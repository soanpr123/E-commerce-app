import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  // const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text("Lịch sử mua hàng",style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),

      body: Container(),
    );
  }
}
