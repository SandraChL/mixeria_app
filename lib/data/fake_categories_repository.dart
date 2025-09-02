import 'dart:async';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import 'categories_repository.dart';

class FakeCategoriesRepository implements CategoriesRepository {
  @override
  Future<List<CategoryModel>> fetchCategories() async {
    // Simula retardo de red
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      CategoryModel(
        id: 'hotcakes',
        title: 'Hot Cakes',
        background: const Color(0xFFE9BDA1),
        imageUrl: 'assets/images/pancakes.png',
      ),
      CategoryModel(
        id: 'waffles',
        title: 'Waffles',
        background: const Color(0xFFF7B7B7),
        imageUrl: 'assets/images/waffles.png',
      ),
      CategoryModel(
        id: 'bebidas',
        title: 'Bebidas',
        background: const Color(0xFF84ACCC),
        imageUrl: 'assets/images/bebida.png',
      ),
      CategoryModel(
        id: 'esquites',
        title: 'Esquites',
        
        background: const Color(0xFFF8C471),
        imageUrl: 'assets/images/esquited.png',
      ),
      CategoryModel(
        id: 'frituras',
        title: 'Frituras',
        background: const Color(0xFF76D7C4 ),
        imageUrl: 'assets/images/bocadillo.png',
      ),
      CategoryModel(
        id: 'helados',
        title: 'Helados',
        background: const Color(0xFFC39BD3),
        imageUrl: 'assets/images/helado.png',
      ),
            CategoryModel(
        id: 'frutas',
        title: 'Frutas',
        background: const Color(0xFF73C6B6 ),
        imageUrl: 'assets/images/fruta.png',
      ),
    ];
  }
}


//Nota

//cuando tengas API, creas api_categories_repository.dart que implemente el mismo contrato y cambias una sola línea en la Home.