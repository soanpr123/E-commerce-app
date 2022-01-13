import 'package:flutter/material.dart';

class Product {
  final String name;
  final String image;
  final double price;
  final String description;
  Product(
      {@required this.image,
      @required this.name,
      @required this.price,
      @required this.description});
}
