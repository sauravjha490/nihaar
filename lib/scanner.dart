import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool isScannerActive = false;
  final MobileScannerController controller = MobileScannerController();
  List<ScannedProduct> scannedProducts = [];

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerAddressController = TextEditingController();

  void startScanner() {
    setState(() {
      isScannerActive = !isScannerActive;
    });
  }

  Future<void> fetchProductDetails(String productId) async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('product1')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        String name = productSnapshot.get('name');
        double price = productSnapshot.get('price');
        String imageUrl = productSnapshot.get('image');

        // Prompt for quantity if needed
        int enteredQuantity = 1; // Default quantity until user specifies

        if (!scannedProducts.any((product) => product.name == name && product.price == price)) {
          setState(() {
            scannedProducts.add(ScannedProduct(name: name, price: price, imageUrl: imageUrl, quantity: enteredQuantity));
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product already scanned!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product not found!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching product details: $e')),
      );
    }
  }

  double calculateTotalAmount() {
    double total = 0.0;
    for (var product in scannedProducts) {
      total += product.price * product.quantity;
    }
    return total;
  }

  Future<Uint8List> _loadLogo() async {
    return await rootBundle.load('assets/logo1.png').then((data) => data.buffer.asUint8List());
  }

  Future<void> _saveSalesData() async {
  try {
    CollectionReference salesCollection = FirebaseFirestore.instance.collection('sales');
    
    for (var product in scannedProducts) {
      // Log product details for debugging
      print('Saving product: ${product.name}, Quantity: ${product.quantity}, Total: ${product.price * product.quantity}');
      
      // Check if product details are valid
      if (product.name.isNotEmpty && product.quantity > 0) {
        await salesCollection.add({
          'productName': product.name,
          'price': product.price,
          'quantity': product.quantity,
          'total': product.price * product.quantity,
          'customerName': customerNameController.text,
          'customerAddress': customerAddressController.text,
        });
      } else {
        print('Invalid product data: ${product.name}, Quantity: ${product.quantity}');
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sales data saved successfully!')),
    );
  } catch (e) {
    print('Error saving sales data: $e'); // Log the error to console
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving sales data: ${e.toString()}')),
    );
  }
}


  Future<void> _generatePdf() async {
  // First, save sales data to Firestore
  await _saveSalesData(); // Call to save sales data first

  // Proceed with PDF generation only if sales data was saved successfully
  final pdf = pw.Document();
  String customerName = customerNameController.text;
  String customerAddress = customerAddressController.text;
  final logoImage = await _loadLogo();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(pw.MemoryImage(logoImage), width: 100, height: 100),
            pw.Text('Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Customer Name: $customerName', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Customer Address: $customerAddress', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 20),
            pw.Text('Products:', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Product Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Quantity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                for (var product in scannedProducts)
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(product.name)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('\$${product.price.toStringAsFixed(2)}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('${product.quantity}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('\$${(product.price * product.quantity).toStringAsFixed(2)}')),
                    ],
                  ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total Amount Payable: \$${calculateTotalAmount().toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, color: PdfColors.green)),
          ],
        );
      },
    ),
  );

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

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating PDF: $e')),
    );
  }
}


  void generateInvoice() {
    if (scannedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No products scanned!')),
      );
      return;
    }

    _generatePdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Page'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: customerAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
          if (isScannerActive)
            Expanded(
              child: MobileScanner(
                controller: controller,
                onDetect: (barcodeCapture) {
                  final List<Barcode> barcodes = barcodeCapture.barcodes;

                  if (barcodes.isNotEmpty) {
                    final String? productId = barcodes.first.rawValue;
                    if (productId != null) {
                      fetchProductDetails(productId);
                    }
                  }
                },
              ),
            ),
          if (!isScannerActive)
            ElevatedButton(
              onPressed: startScanner,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Start Scanner',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: scannedProducts.length,
              itemBuilder: (context, index) {
                final product = scannedProducts[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${product.price.toStringAsFixed(2)}'),
                      Text('Total: \$${(product.price * product.quantity).toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Qty',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                product.quantity = int.parse(value);
                              } else {
                                product.quantity = 0;
                              }
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              scannedProducts.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: generateInvoice,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text('Generate Invoice'),
          ),
        ],
      ),
    );
  }
}

class ScannedProduct {
  final String name;
  final double price;
  String imageUrl;
  int quantity;

  ScannedProduct({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}
