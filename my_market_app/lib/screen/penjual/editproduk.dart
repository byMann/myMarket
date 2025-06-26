import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:my_market_app/class/kategori.dart';
import 'package:my_market_app/class/produk.dart';
import 'package:my_market_app/screen/penjual/produkpenjual.dart';

class EditProduk extends StatefulWidget {
  int produkID;

  EditProduk({super.key, required this.produkID});

  @override
  EditProdukState createState() => EditProdukState();
}

class EditProdukState extends State<EditProduk> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCont = TextEditingController();
  final TextEditingController _descCont = TextEditingController();
  TextEditingController _hargaCont = TextEditingController();
  TextEditingController _stokCont = TextEditingController();
  Widget comboKategori = Text('tambah kategori');

  Produk? _p;

  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    bacaData();
  }

  @override
  void dispose() {
    _nameCont.dispose();
    super.dispose();
  }

  void bacaData() async {
    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422065/project/detailproduct.php",
      ),
      body: {'id': widget.produkID.toString()},
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      _p = Produk.fromJson(json['data']);
      setState(() {
        _nameCont.text = _p!.nama;
        _descCont.text = _p!.deskripsi;
        _hargaCont.text = _p!.harga.toString();
        _stokCont.text = _p!.stok.toString();
      });
      generateComboKategori();
    }
  }

  void generateComboKategori() async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422065/project/listcategory.php"),
      body: {'produk_id': widget.produkID.toString()},
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      List<Kategori> kategoris = List<Kategori>.from(
        json['data'].map((i) => Kategori.fromJson(i)),
      );

      setState(() {
        comboKategori = DropdownButton(
          dropdownColor: Colors.grey[100],
          hint: const Text("tambah kategori"),
          items:
              kategoris.map((kat) {
                return DropdownMenuItem(value: kat.id, child: Text(kat.nama));
              }).toList(),
          onChanged: (value) => addKategori(value),
        );
      });
    }
  }

  void addKategori(kategoriId) async {
    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422065/project/addproductcategory.php",
      ),
      body: {
        'kategori_id': kategoriId.toString(),
        'product_id': widget.produkID.toString(),
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sukses menambah kategori')));
      bacaData();
    }
  }

  Future<void> deleteKategori(String kategoriNama) async {
    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422065/project/deleteprodcat.php",
      ),
      body: {
        'product_id': widget.produkID.toString(),
        'kategori_nama': kategoriNama,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sukses Menghapus Kategori')));
      setState(() {
        bacaData();
      });
    }
  }

  void submit() async {
    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422065/project/updateproduct.php",
      ),
      body: {
        'id': widget.produkID.toString(),
        'nama': _nameCont.text,
        'deskripsi': _descCont.text,
        'harga': _hargaCont.text,
        'stok': _stokCont.text,
      },
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {

        if (_imageBytes != null) {
          uploadGambarProduk(widget.produkID);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sukses mengubah Data')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProdukPenjual()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${json['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server Error: ${response.statusCode}')),
      );
    }
  }

  void delete() async {
    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422065/project/deleteproduct.php",
      ),
      body: {'id': widget.produkID.toString()},
    );
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sukses Menghapus Data')));

        Navigator.pushNamed(context, 'homepenjual');
        setState(() {
          bacaData();
        });
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error')));
      throw Exception('Failed to read API');
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
          SnackBar(content: Text('Sukses mengubah Gambar Produk')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengubah Gambar Produk')));
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

  Widget generateKategoris() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _p?.kategori?.length ?? 0,
      itemBuilder: (context, index) {
        final namaKategori = _p!.kategori![index]['nama'];
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(namaKategori)),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () => deleteKategori(namaKategori),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Produk")),
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
                            ? 'nama harus diisi'
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
                            ? 'harga harus diisi'
                            : null,
              ),
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: 'Stok'),
                controller: _stokCont,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'stok harus diisi'
                            : null,
              ),
              const SizedBox(height: 16),
              comboKategori,
              const SizedBox(height: 10),
              if (_p != null) generateKategoris(),
              const SizedBox(height: 20),
              Image.network(
                'http://ubaya.xyz/flutter/160422065/project/images/produk/${_p?.id}.jpg',
                height: 200,
              ),
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
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    submit();
                    Navigator.pushReplacementNamed(context, 'produk_penjual');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Harap perbaiki isian')),
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
