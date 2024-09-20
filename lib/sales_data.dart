import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart'; // Import the csv package
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

class SalesDataPage extends StatefulWidget {
  @override
  _SalesDataPageState createState() => _SalesDataPageState();
}

class _SalesDataPageState extends State<SalesDataPage> {
  Future<void> _generateCSV() async {
    try {
      // Fetch sales data from Firestore collection 'sales'
      QuerySnapshot salesSnapshot = await FirebaseFirestore.instance.collection('sales').get();
      List salesData = salesSnapshot.docs.map((doc) => doc.data()).toList();

      // Prepare the CSV data
      List<List<dynamic>> csvData = [];
      csvData.add(["Product Name", "Price", "Quantity Sold", "Total", "Remaining Quantity"]); // Header

      for (var sale in salesData) {
        final String productName = sale['productName'];
        final double price = (sale['price'] is double) ? sale['price'] : (sale['price'] as num).toDouble();
        final int quantitySold = sale['quantity'] as int;

        // Fetch the product data to get the original quantity
        DocumentSnapshot productSnapshot = await FirebaseFirestore.instance.collection('product1').doc(productName).get();
        print(productSnapshot);
        double availableQuantity = 100; // Use double to accommodate the stored type

        if (!productSnapshot.exists) {
          print('Product not found: $productName');
          availableQuantity = 100;
        } else {
          availableQuantity = productSnapshot.get('quantity') is double
              ? productSnapshot.get('quantity') as double
              : (productSnapshot.get('quantity') as num).toDouble();
        }

        // Calculate remaining quantity
        int remainingQuantity = (availableQuantity - quantitySold).toInt();
        double total = price * quantitySold;

        // Add the data to the CSV
        csvData.add([productName, price, quantitySold, total, remainingQuantity]);
      }

      // Convert the list to CSV
      String csv = const ListToCsvConverter().convert(csvData);

      // Prepare the path for saving the CSV file
      String path;
      if (kIsWeb) {
        // For web, show a message (implement download functionality if needed)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File generated. Use browser download functionality.')),
        );
        return; // Exit the method
      } else {
        // Get the directory to store the file for mobile
        final directory = await getExternalStorageDirectory();
        path = '${directory!.path}/sales_data.csv';
        final file = File(path);
        await file.writeAsString(csv);
      }

      // Share the CSV file
      await Share.shareXFiles([XFile(path)], text: 'Here is the sales data in CSV format');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV file created and shared successfully at $path')),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating CSV file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Data'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _generateCSV,
          child: Text('Generate and Share Sales Data as CSV'),
        ),
      ),
    );
  }
}
