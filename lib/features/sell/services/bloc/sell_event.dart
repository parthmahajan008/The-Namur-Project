import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class SellEvent extends Equatable {
  const SellEvent();

  @override
  List<Object> get props => [];
}

class AddProductRequested extends SellEvent {
  final String productName;
  final String productDescription;
  final double productPrice;
  final int productQuantity;
  final String priceType;
  final String category;
  final String subCategory;
  final String subSubCategory;
  final Uint8List image;

  const AddProductRequested({
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.productQuantity,
    required this.priceType,
    required this.category,
    required this.subCategory,
    required this.subSubCategory,
    required this.image,
  });

  @override
  List<Object> get props => [
        productName,
        productDescription,
        productPrice,
        productQuantity,
        priceType,
        category,
        subCategory,
        subSubCategory,
        image,
      ];
}

class ProductsForSubCategoryRequested extends SellEvent {
  final String subCategory;

  const ProductsForSubCategoryRequested({
    required this.subCategory,
  });

  @override
  List<Object> get props => [subCategory];
}

class DeleteProductRequested extends SellEvent {
  final String productId;

  const DeleteProductRequested({
    required this.productId,
  });

  @override
  List<Object> get props => [productId];
}
