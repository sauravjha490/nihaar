import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  // Method to delete a product from Firestore
  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance.collection('product1').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      // Optionally, show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('product1').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id; // Get the document ID
              final name = product['name'] ?? 'No Name';
              final price = product['price']?.toString() ?? 'No Price';
              final quantity = product['quantity']?.toString() ?? '0'; // Fetch quantity
              final imageUrl = product['image'] ?? ''; // Fetch image URL

              return ListTile(
                leading: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 50, // Adjust as needed
                        height: 50, // Adjust as needed
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.image, size: 50), // Placeholder if no image
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Price: \$${price}\nQuantity: $quantity'), // Display quantity
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Confirm before deleting
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text('Are you sure you want to delete this product?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                                _deleteProduct(productId); // Delete the product
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
