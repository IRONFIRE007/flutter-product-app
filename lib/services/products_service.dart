import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:product_app/models/models.dart';
import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier {
  final String _baseUrl = 'flutter-varios-c606a-default-rtdb.firebaseio.com';

  final List<Product> producs = [];
  late Product selectdProduct;
  bool isLoading = true;
  bool isSaving = false;
  File? newPictureFile;
  //Fecht Product

  final _storage = new FlutterSecureStorage();

  ProductsService() {
    loadProducts();
  }

  //  Future<List<Product>>

  Future loadProducts() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json',
        {'auth': await _storage.read(key: 'token') ?? ''});
    final token = await _storage.read(key: 'token') ?? '';
    final resp = await http.get(url);

    final Map<String, dynamic> productMap = json.decode(resp.body);
    if (productMap == null) return [];

    if (productMap['error'] != null) return [];

    productMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      producs.add(tempProduct);
    });

    isLoading = false;
    notifyListeners();

    return producs;
  }

  Future savedOrCreateProduct(Product product) async {
    isSaving = false;
    notifyListeners();

    if (product.id == null) {
      //Create
      await createProduct(product);
    } else {
      //Update
      await this.updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json',
        {'auth': await _storage.read(key: 'token') ?? ''});
    final resp = await http.put(
      url,
      body: product.toJson(),
    );
    final decodeData = resp.body;

    //update the values of the Product
    final index = producs.indexWhere((element) => element.id == product.id);

    producs[index] = product;

    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json',
        {'auth': await _storage.read(key: 'token') ?? ''});
    final resp = await http.post(url, body: product.toJson());
    final decodeData = json.decode(resp.body);

    product.id = decodeData['name'];

    //Saved Product
    producs.add(product);

    return product.id!;
  }

  void updateSelectedProductImage(String path) {
    selectdProduct.picture = path;
    newPictureFile = File.fromUri(Uri(path: path));
    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (newPictureFile == null) return null;
    this.isSaving = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dwtpcwlje/image/upload?upload_preset=icvrlvv2');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file =
        await http.MultipartFile.fromPath('file', newPictureFile!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      // print('Algo salio mal');
      // print(resp.body);
      return null;
    }

    this.newPictureFile = null;

    final decodeData = json.decode(resp.body);

    return decodeData['secure_url'];
  }
}
