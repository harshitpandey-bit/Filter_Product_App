import 'package:flutter/material.dart';
import 'package:apilocaldata/database.dart';
import 'package:apilocaldata/productmodel.dart';

class FilteredProductsScreen extends StatefulWidget {
  @override
  _FilteredProductsScreenState createState() => _FilteredProductsScreenState();
}

class _FilteredProductsScreenState extends State<FilteredProductsScreen> {
  List<String> selectedCategories = [];
  List<Product> products = [];
  List<String> categories = [];
  RangeValues _selectedPriceRange = RangeValues(0, 500);

  @override
  void initState() {
    super.initState();
    fetchProductsFromDatabase();
  }

  Future<void> fetchProductsFromDatabase() async {
    try {
      List<Product> allProducts = await DatabaseHelper().getProducts();
      setState(() {
        products = allProducts;
        categories = allProducts.map((product) => product.category).toSet().toList();
      });
    } catch (e) {
      print('Error fetching products: $e');
      // Handle error: show a snackbar, retry mechanism, etc.
    }
  }

  List<Product> getFilteredProducts() {
    return products.where((product) {
      final matchesCategory = selectedCategories.isEmpty || selectedCategories.contains(product.category);
      final matchesPrice = product.price >= _selectedPriceRange.start && product.price <= _selectedPriceRange.end;
      return matchesCategory && matchesPrice;
    }).toList();
  }

  void _showFilterOptions() {
    List<String> tempSelectedCategories = List.from(selectedCategories);
    RangeValues tempSelectedPriceRange = _selectedPriceRange;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: Text('Filter Options'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Select Categories'),
                    ...categories.map((category) {
                      return CheckboxListTile(
                        title: Text(category),
                        value: tempSelectedCategories.contains(category),
                        onChanged: (bool? value) {
                          setModalState(() {
                            if (value == true) {
                              tempSelectedCategories.add(category);
                            } else {
                              tempSelectedCategories.remove(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                    Divider(),
                    Text('Select Price Range'),
                    RangeSlider(
                      values: tempSelectedPriceRange,
                      min: 0,
                      max: 500,
                      divisions: 100,
                      labels: RangeLabels(
                        tempSelectedPriceRange.start.round().toString(),
                        tempSelectedPriceRange.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setModalState(() {
                          tempSelectedPriceRange = values;
                        });
                      },
                    ),
                    Text('Price: \$${tempSelectedPriceRange.start.round()} - \$${tempSelectedPriceRange.end.round()}'),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategories = tempSelectedCategories;
                      _selectedPriceRange = tempSelectedPriceRange;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Apply Filters'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = getFilteredProducts();

    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Image.network(
                      filteredProducts[index].image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(filteredProducts[index].title),
                    subtitle: Text('\$${filteredProducts[index].price.toStringAsFixed(2)}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductScreen(product: filteredProducts[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductScreen extends StatelessWidget {
  final Product product;

  ProductScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(product.image),
              SizedBox(height: 20),
              Text('Category: ${product.category}'),
              SizedBox(height: 10),
              Text('Description: ${product.description}'),
              SizedBox(height: 10),
              Text('Price: \$${product.price.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }
}
