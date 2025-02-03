// ignore_for_file: library_private_types_in_public_api

import 'package:floating_logger/floating_logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WarehouseScreen(),
    );
  }
}

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  _WarehouseScreenState createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  final Dio dio = DioLogger.instance;
  List<Map<String, dynamic>> items = [];

  void fetchItems() async {
    final response = await dio.get('https://warehouse-api.com/api/warehouses');
    setState(() {
      items = List<Map<String, dynamic>>.from(response.data);
    });
  }

  void addItem(String name, int stock) async {
    await dio.post('https://warehouse-api.com/api/warehouses', data: {
      'name': name,
      'stock': stock,
    });
    fetchItems();
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingLoggerControl(
      child: Scaffold(
        appBar: AppBar(title: const Text('Warehouse Management')),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(items[index]['name']),
              subtitle: Text('Stock: ${items[index]['stock']}'),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddItemPage(addItem: addItem)),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class AddItemPage extends StatefulWidget {
  final Function(String, int) addItem;
  const AddItemPage({super.key, required this.addItem});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: stockController,
              decoration: const InputDecoration(labelText: 'Stock Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.addItem(
                  nameController.text,
                  int.parse(stockController.text),
                );
                Navigator.pop(context);
              },
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
