import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:product_app/models/product.dart';
import 'package:product_app/providers/product_form_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:product_app/services/services.dart';
import 'package:product_app/ui/input_decorations.dart';
import 'package:product_app/widgets/product_image.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductsService>(context);
    final product = productService.selectdProduct;

    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(productService.selectdProduct),
      child: _ProductScreenBody(product: product),
    );
  }
}

class _ProductScreenBody extends StatelessWidget {
  const _ProductScreenBody({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductsService>(context);
    final productForm = Provider.of<ProductFormProvider>(context);
    return Scaffold(
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              Stack(
                children: [
                  ProductImage(url: product.picture),
                  Positioned(
                      top: 60,
                      left: 20,
                      child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 40,
                            color: Colors.white,
                          ))),
                  Positioned(
                      top: 60,
                      right: 30,
                      child: IconButton(
                          onPressed: () async {
                            //Camera or Gallery
                            final _picker = new ImagePicker();
                            final XFile? pickedFile = await _picker.pickImage(
                                source: ImageSource.camera, imageQuality: 100);

                            if (pickedFile == null) {
                              print("No Selecciono imagen");
                              return;
                            }

                            // print('Selected Image ${pickedFile.path}');

                            productService
                                .updateSelectedProductImage(pickedFile.path);
                          },
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: Colors.white,
                          ))),
                ],
              ),
              _ProductForm(),
              const SizedBox(height: 100),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          child: productService.isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.save_outlined),
          onPressed: productService.isSaving
              ? null
              : () async {
                  //Save Product
                  if (!productForm.isValidForm()) return;

                  final String? imageUrl = await productService.uploadImage();

                  if (imageUrl != null) productForm.product.picture = imageUrl;

                  // print(imageUrl);

                  await productService
                      .savedOrCreateProduct(productForm.product);
                },
        ));
  }
}

class _ProductForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: Form(
            key: productForm.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextFormField(
                    initialValue: product.name,
                    onChanged: (value) => product.name = value,
                    validator: (value) {
                      if (value == null || value.length < 1)
                        return 'The name is required';
                    },
                    decoration: InputDecorations.authInputDecoration(
                        hintText: 'Name of Product', labelText: 'Name :')),
                const SizedBox(height: 30),
                TextFormField(
                    initialValue: '${product.price}',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^(\d+)?\.?\d{0,2}'))
                    ],
                    onChanged: (value) {
                      if (double.tryParse(value) == null) {
                        product.price = 0;
                      } else {
                        product.price = double.parse(value);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.length < 1)
                        return 'The name is required';
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecorations.authInputDecoration(
                        hintText: '\$150', labelText: 'Price :')),
                const SizedBox(height: 30),
                SwitchListTile.adaptive(
                    value: product.available,
                    title: Text('Avaliable'),
                    activeColor: Colors.indigo,
                    onChanged:
                        //Button
                        productForm.updateAvialability),
                const SizedBox(height: 30)
              ],
            )),
        decoration: _buildBoxDecoration(),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(25), bottomLeft: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0, 5),
              blurRadius: 5)
        ]);
  }
}
