import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ProductPage extends StatefulWidget {
  final String customerName;
  final String customerAddress;
  final List<ScannedProduct> scannedProducts;
  final double totalAmount;

  ProductPage({
    required this.customerName,
    required this.customerAddress,
    required this.scannedProducts,
    required this.totalAmount,
  });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _quantityController = TextEditingController();
  final Map<String, double> productQuantities = {};

  @override
  void initState() {
    super.initState();
    for (var product in widget.scannedProducts) {
      productQuantities[product.name] = 0.0; // Initialize quantities
    }
  }

  double _calculateTotal() {
    double total = 0.0;
    productQuantities.forEach((productName, quantity) {
      final product = widget.scannedProducts.firstWhere((p) => p.name == productName);
      total += product.price * quantity;
    });
    return total;
  }

  Future<Uint8List?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to load image');
        return null;
      }
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    for (var product in widget.scannedProducts) {
      // Download the image for each product (if applicable)
      final imageData = await _downloadImage(product.imageUrl); // Assuming you have an imageUrl field

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                if (imageData != null)
                  pw.Image(pw.MemoryImage(imageData), width: 100, height: 100), // Display image
                pw.SizedBox(height: 20),
                pw.Text('Customer Name: ${widget.customerName}', style: pw.TextStyle(fontSize: 18)),
                pw.Text('Customer Address: ${widget.customerAddress}', style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 10),
                pw.Text('Products:', style: pw.TextStyle(fontSize: 18)),
                for (var product in widget.scannedProducts) 
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Product Name: ${product.name}', style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Price: \$${product.price.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Quantity: ${productQuantities[product.name]}', style: pw.TextStyle(fontSize: 18)),
                      pw.SizedBox(height: 10),
                    ],
                  ),
                pw.SizedBox(height: 20),
                pw.Text('Total Amount Payable: \$${widget.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, color: PdfColors.green)),
              ],
            );
          },
        ),
      );
    }

    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot access the storage directory!')),
        );
        return;
      }
      final path = '${directory.path}/invoice.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(path)],
        text: 'Here is your invoice',
      );

      // Here you can also update Firestore quantity if needed
      for (var product in widget.scannedProducts) {
        final docRef = FirebaseFirestore.instance.collection('product1').doc(product.id); // Assuming there's an id field

        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          final currentQuantity = docSnapshot.get('quantity') as double;
          final enteredQuantity = productQuantities[product.name] ?? 0.0;
          final newQuantity = currentQuantity - enteredQuantity;

          if (newQuantity < 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: Quantity cannot be negative!')),
            );
            return;
          }

          await docRef.update({'quantity': newQuantity});
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved, shared, and quantities updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF or updating quantity: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Page'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Name: ${widget.customerName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            Text(
              'Customer Address: ${widget.customerAddress}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            Text(
              'Products:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: widget.scannedProducts.length,
                itemBuilder: (context, index) {
                  final product = widget.scannedProducts[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('Price: \$${product.price.toStringAsFixed(2)}'),
                    trailing: SizedBox(
                      width: 100,
                      child: TextField(
                        controller: TextEditingController(text: productQuantities[product.name]?.toString()),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            productQuantities[product.name] = double.tryParse(value) ?? 0.0;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Qty',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Total Amount Payable: \$${widget.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _generatePdf,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Generate PDF'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannedProduct {
  final String name;
  final double price;
  final String imageUrl; // Assuming each product has an image URL
  final String id; // Assuming each product has an ID

  ScannedProduct({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.id,
  });
}
