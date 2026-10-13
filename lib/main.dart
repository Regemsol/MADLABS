import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MadLabsApp());
}

class MadLabsApp extends StatelessWidget {
  const MadLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _ref = FirebaseDatabase.instance.ref('restaurants');
  final _nameCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _palette = [Colors.orange, Colors.red, Colors.teal, Colors.purple, Colors.blue];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tagCtrl.dispose();
    _ratingCtrl.dispose();
    super.dispose();
  }

  Future<void> _addRestaurant() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    try {
      await _ref.push().set({
        'name': name,
        'tag': _tagCtrl.text.trim(),
        'rating': _ratingCtrl.text.trim().isEmpty ? '4.0' : _ratingCtrl.text.trim(),
        'ts': ServerValue.timestamp,
      });
      _nameCtrl.clear();
      _tagCtrl.clear();
      _ratingCtrl.clear();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Write failed: $e')));
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add restaurant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _tagCtrl, decoration: const InputDecoration(labelText: 'Tag (e.g. Fast • Pizza)')),
            TextField(
              controller: _ratingCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rating (e.g. 4.5)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: _addRestaurant, child: const Text('Submit')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Pizza', 'Burger', 'Sushi', 'Dessert'];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deliver to', style: TextStyle(color: Colors.grey)),
                      Text('Downtown Street',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(Icons.person, color: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Expanded(child: Text('Search for food or restaurants')),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Popular categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final selected = index == 0;
                    return Chip(
                      label: Text(categories[index]),
                      backgroundColor: selected ? Colors.orange : Colors.grey.shade100,
                      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text('Restaurants',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: _ref.onValue,
                  builder: (context, snap) {                    if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final raw = snap.data?.snapshot.value;
                    if (raw == null) {
                      return const Center(child: Text('No restaurants yet. Tap + to add one.'));
                    }
                    final items = Map<String, dynamic>.from(raw as Map)
                        .values
                        .map((v) => Map<String, dynamic>.from(v as Map))
                        .toList();
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _RestaurantCard(
                        name: '${items[i]['name'] ?? ''}',
                        tag: '${items[i]['tag'] ?? ''}',
                        rating: '${items[i]['rating'] ?? ''}',
                        color: _palette[i % _palette.length],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.name,
    required this.tag,
    required this.rating,
    required this.color,
  });

  final String name;
  final String tag;
  final String rating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.restaurant, color: color, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(tag, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(rating),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}