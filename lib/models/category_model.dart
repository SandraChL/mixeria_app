import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final Color background;
  final String imageUrl; // URL o ruta local (assets)
  final bool isNetwork;

  CategoryModel({
    required this.id,
    required this.title,
    required this.background,
    required this.imageUrl,
    this.isNetwork = false,
  });
}
