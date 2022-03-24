import 'package:flutter/material.dart';
import 'package:product_app/models/models.dart';

class ProductFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  Product product;

  ProductFormProvider(this.product);

  updateAvialability(bool value) {
    print(value);
    product.available = value;
    notifyListeners();
  }

  bool isValidForm() {
    print(product.name);
    print(product.available);
    print(product.price);
    return formKey.currentState?.validate() ?? false;
  }
}
