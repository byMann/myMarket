import 'package:flutter/material.dart';
import 'package:my_market_app/screen/customer/akun.dart';
import 'package:my_market_app/screen/customer/detailproduk.dart';
import 'package:my_market_app/screen/customer/homecustomer.dart';
import 'package:my_market_app/screen/customer/kategori.dart';
import 'package:my_market_app/screen/customer/pembelian.dart';
import 'package:my_market_app/screen/customer/produksaya.dart';
import 'package:my_market_app/screen/customer/tambahproduk.dart';
import 'package:my_market_app/screen/login.dart';

void main() {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myMarket App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'myMarket App'),
      routes: {
        'home': (context) => const HomeCustomer(),
        'produksaya': (context) => const ProdukSaya(),
        'akun': (context) => const Akun(),
        'kategori': (context) => const Kategori(),
        'pembelian': (context) => const Pembelian(),
        'tambahproduk': (context) => const TambahProduk(),
        'login': (context) => const Login(),
        'detailproduk': (context) => const DetailProduk(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [HomeCustomer(), ProdukSaya(), Akun()];
  final List<String> _title = ['Home', 'Produk Saya', 'Akun'];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(_title[_currentIndex]),
      ),
      body: _screens[_currentIndex],
      drawer: myDrawer(),
      bottomNavigationBar: myButtonNavBar(),
    );
  }

  Center myBody(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        //
        // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
        // action in the IDE, or press "p" in the console), to see the
        // wireframe for each widget.
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[const Text('Welcome to myMarket App')],
      ),
    );
  }

  BottomNavigationBar myButtonNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      fixedColor: Colors.purple,
      items: const [
        BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
        BottomNavigationBarItem(
          label: "Produk Saya",
          icon: Icon(Icons.shopping_bag),
        ),
        BottomNavigationBarItem(label: "Akun", icon: Icon(Icons.person)),
      ],
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  Drawer myDrawer() {
    return Drawer(
      elevation: 16.0,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Dummy"),
            accountEmail: Text("dummy@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
            ),
          ),
          ListTile(
            title: const Text("Tambah Produk"),
            leading: const Icon(Icons.add),
            onTap: () {
              Navigator.popAndPushNamed(context, "tambahproduk");
            },
          ),
          ListTile(
            title: const Text("Kategori"),
            leading: const Icon(Icons.list),
            onTap: () {
              Navigator.popAndPushNamed(context, "kategori");
            },
          ),
          ListTile(
            title: const Text("Pembelian"),
            leading: const Icon(Icons.attach_money_sharp),
            onTap: () {
              Navigator.popAndPushNamed(context, "pembelian");
            },
          ),
          ListTile(
            title: const Text("Logout"),
            leading: const Icon(Icons.logout_outlined),
            onTap: () {
              // doLogout();
            },
          ),
        ],
      ),
    );
  }
}
