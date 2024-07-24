import 'package:flutter/material.dart';
import 'package:apilocaldata/database.dart';
import 'package:apilocaldata/apiservice.dart';
import 'package:apilocaldata/filteredscreen.dart';
import 'package:apilocaldata/productmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initializeDatabase(); // Initialize the database
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<List<Product>>(
        future: ApiService().fetchProductsAndStoreInDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return FilteredProductsScreen();
          }
        },
      ),
    );
  }
}
