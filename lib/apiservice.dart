import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apilocaldata/database.dart';
import 'package:apilocaldata/productmodel.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com/products';

  Future<List<Product>> fetchProductsAndStoreInDatabase() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<Product> products = (jsonDecode(response.body) as List)
          .map((data) => Product.fromMap(data))
          .toList();
      await DatabaseHelper().insertProducts(products);
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }
}
