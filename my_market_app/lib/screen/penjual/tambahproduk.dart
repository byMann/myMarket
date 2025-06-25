import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:my_market_app/helper/user_helper.dart' as user_helper;
import 'package:my_market_app/screen/penjual/produkpenjual.dart';

class TambahProduk extends StatefulWidget {
  const TambahProduk({super.key});

  @override
  _TambahProdukScreenState createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProduk> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCont = TextEditingController();
  final TextEditingController _descCont = TextEditingController();
  final TextEditingController _hargaCont = TextEditingController();
  final TextEditingController _stokCont = TextEditingController();

  List<Map<String, dynamic>> _kategoriList = [];
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    fetchKategoriList();
  }

  void submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160422065/project/addproduct.php"),
        body: {
          'nama': _nameCont.text,
          'deskripsi': _descCont.text,
          'harga': _hargaCont.text,
          'stok': _stokCont.text,
          'id_penjual': (await user_helper.getUserId()).toString(),
        },
      );

      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        if (json['result'] == 'success') {
          int produkID = json['id'];

          if (_imageBytes != null) {
            uploadGambarProduk(produkID);
          }

          await addCategories(produkID);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produk berhasil ditambahkan')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProdukPenjual()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menambahkan produk')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan produk, coba lagi')),
        );
      }
    }
  }

  Future<void> addCategories(int produkID) async {
    for (var kat in _kategoriList) {
      if (kat['selected']) {
        final response = await http.post(
          Uri.parse(
            "https://ubaya.xyz/flutter/160422065/project/addproductcategory.php",
          ),
          body: {
            'product_id': produkID.toString(),
            'kategori_id': kat['id'].toString(),
          },
        );
        if (response.statusCode != 200) {
          print('Failed to add category: ${kat['nama']}');
        }
      }
    }
  }

  void fetchKategoriList() async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422065/project/listcategory.php"),
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      setState(() {
        _kategoriList = List<Map<String, dynamic>>.from(
          json['data'].map(
            (item) => {
              'id': item['id'],
              'nama': item['nama'],
              'selected': false,
            },
          ),
        );
      });
    }
  }

  void uploadGambarProduk(int produkID) async {
    if (_imageBytes == null) return;

    String base64Image = base64Encode(_imageBytes!);
    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422065/project/uploadgambarproduk.php",
      ),
      body: {'produk_id': produkID.toString(), 'gambar': base64Image},
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sukses mengupload Gambar Produk')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengupload Gambar Produk')),
        );
      }
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeri'),
                onTap: () {
                  imgGaleri();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Kamera'),
                onTap: () {
                  imgKamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  imgGaleri() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  imgKamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Produk")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nama'),
                controller: _nameCont,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nama harus diisi'
                            : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Deskripsi'),
                controller: _descCont,
                minLines: 3,
                maxLines: 6,
              ),
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: 'Harga'),
                controller: _hargaCont,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Harga harus diisi'
                            : null,
              ),
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: 'Stok'),
                controller: _stokCont,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Stok harus diisi'
                            : null,
              ),
              const SizedBox(height: 20),
              Text('Kategori:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._kategoriList.map((kat) {
                return CheckboxListTile(
                  title: Text(kat['nama']),
                  value: kat['selected'],
                  onChanged: (value) {
                    setState(() {
                      kat['selected'] = value!;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showPicker(context),
                child: Text('Pick Image'),
              ),
              if (_imageBytes != null) ...[
                Image.memory(_imageBytes!, height: 200),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 16),
              ElevatedButton(onPressed: submit, child: Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
