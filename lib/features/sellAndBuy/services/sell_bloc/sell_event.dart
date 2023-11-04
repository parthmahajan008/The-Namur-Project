import 'dart:typed_data';
import 'package:active_ecommerce_flutter/utils/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

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
  final String quantityUnit;
  // final String priceType;
  final String category;
  final String subCategory;
  final String subSubCategory;
  final List<XFile> imageList;
  final bool isSecondHand;
  final ProductType productType;

  const AddProductRequested({
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.productQuantity,
    required this.quantityUnit,
    // required this.priceType,
    required this.category,
    required this.subCategory,
    required this.subSubCategory,
    required this.imageList,
    required this.isSecondHand,
    required this.productType,
  });

  @override
  List<Object> get props => [
        productName,
        productDescription,
        productPrice,
        productQuantity,
        quantityUnit,
        category,
        subCategory,
        subSubCategory,
        imageList,
      ];
}

class EditProductRequested extends SellEvent {
  final String productId;
  final String productName;
  final String productDescription;
  final double productPrice;
  final int productQuantity;
  final String quantityUnit;
  // final String priceType;
  final String category;
  final String subCategory;
  final String subSubCategory;
  // final Uint8List image;

  const EditProductRequested({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.productQuantity,
    required this.quantityUnit,
    required this.category,
    required this.subCategory,
    required this.subSubCategory,
    // required this.image,
  });

  @override
  List<Object> get props => [
        productId,
        productName,
        productDescription,
        productPrice,
        productQuantity,
        quantityUnit,
        category,
        subCategory,
        subSubCategory,
        // image,
      ];
}

class ProductsForSubCategoryRequested extends SellEvent {
  final String subCategory;
  final bool isSecondHand;

  const ProductsForSubCategoryRequested({
    required this.subCategory,
    required this.isSecondHand,
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