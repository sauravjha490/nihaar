import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:screenshot/screenshot.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ItemRegistrationScreen extends StatefulWidget {
  const ItemRegistrationScreen({super.key});

  @override
  _ItemRegistrationScreenState createState() => _ItemRegistrationScreenState();
}

class _ItemRegistrationScreenState extends State<ItemRegistrationScreen> {
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  XFile? _selectedImage;
  bool _isLoading = false; // Flag for loading state

  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: await _showImageSourceDialog(),
    );

    setState(() {
      _selectedImage = image;
    });

    if (_selectedImage != null) {
      print('Selected image path: ${_selectedImage!.path}');
      print('File exists: ${File(_selectedImage!.path).existsSync()}');
    }
  }

  Future<ImageSource> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: const Text('Gallery'),
            ),
          ],
        );
      },
    ) ?? ImageSource.gallery; // Default to gallery if dialog is closed
  }

  Future<void> _registerItem() async {
    String name = _itemController.text;
    double price = double.tryParse(_priceController.text) ?? 0.0;
    double quantity = double.tryParse(_quantityController.text) ?? 0.0;

    if (name.isNotEmpty && price > 0) {
      setState(() {
        _isLoading = true; // Show loader
      });

      try {
        // Upload image to Firebase Storage
        String imageUrl = '';
        if (_selectedImage != null) {
          final file = File(_selectedImage!.path);
          final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
          final storageRef = _storage.ref().child('product_images').child(fileName);

          await storageRef.putFile(file);
          imageUrl = await storageRef.getDownloadURL();
          print('Image URL: $imageUrl'); // Debugging line to check image URL
        }

        // Add item details to Firestore
        DocumentReference docRef = await _firestore.collection('product1').add({
          'name': name,
          'price': price,
          'quantity': quantity,
          'image': imageUrl, // Save the image URL
        });

        String itemId = docRef.id;
        print('Item registered with ID: $itemId');

        // Navigate to QrCodeScreen with itemId and price
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrCodeScreen(itemId: itemId, price: price),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item registered successfully')),
        );

        _itemController.clear();
        _priceController.clear();
        _quantityController.clear();
        setState(() {
          _selectedImage = null;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register item: $error')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loader
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide valid name and price')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Item', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _itemController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Pick Image',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 20),
              _selectedImage != null
                  ? Image.file(
                      File(_selectedImage!.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : const Text('No image selected'),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registerItem,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Register Item',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class QrCodeScreen extends StatelessWidget {
  final String itemId;
  final double price;

  const QrCodeScreen({super.key, required this.itemId, required this.price});

  @override
  Widget build(BuildContext context) {
    final ScreenshotController screenshotController = ScreenshotController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item QR Code', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Screenshot(
              controller: screenshotController,
              child: QrImageView(
                data: itemId,
                version: QrVersions.auto,
                size: 200.0,
                gapless: false,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Capture screenshot
                  final Uint8List? image = await screenshotController.capture();

                  if (image != null) {
                    // Get temporary directory
                    final directory = await getTemporaryDirectory();
                    final path = '${directory.path}/qr_code.png';

                    // Save the image to the temporary directory
                    final file = File(path);
                    await file.writeAsBytes(image);

                    // Save to gallery using gal package
                    await Gal.putImage(path);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR code saved to gallery')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to capture QR code')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving QR code: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Save QR',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Capture screenshot for printing
                  final Uint8List? image = await screenshotController.capture();

                  if (image != null) {
                    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
                      final pdf = pw.Document();
                      pdf.addPage(
                        pw.Page(
                          build: (pw.Context context) => pw.Center(
                            child: pw.Image(pw.MemoryImage(image)),
                          ),
                        ),
                      );
                      return pdf.save();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR code sent to printer')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to capture QR code for printing')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error printing QR code: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Print QR',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Price: \$${price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18.0, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}