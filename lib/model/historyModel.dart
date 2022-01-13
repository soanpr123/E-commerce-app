import 'package:flutter/material.dart';

class HistoryProduct {
  final double TotalPrice;
  final String description;
  final code;
  final String status;
  HistoryProduct(
      {@required this.code,
      @required this.description,
      @required this.status,
      @required this.TotalPrice});
}
