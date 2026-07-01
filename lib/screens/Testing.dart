import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Testing extends StatefulWidget {
  const Testing({super.key});

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  final TextEditingController _controller = TextEditingController();
  late Box _box;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupHive();
  }

  Future<void> _setupHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('testBox');
    setState(() {
      _isLoading = false;
    });
  }

  void _addItem() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;

    _box.add(value);
    _controller.clear();
    setState(() {});
  }

  void _updateItem(int key, String value) async {
    final controller = TextEditingController(text: value);
    final updated = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Value'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated != null && updated.isNotEmpty) {
      await _box.put(key, updated);
      setState(() {});
    }
  }

  void _deleteItem(int key) {
    _box.delete(key);
    setState(() {});
  }

  void _clearAll() {
    _box.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _box.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Test Page'),
        actions: [
          IconButton(
            tooltip: 'Clear all',
            icon: const Icon(Icons.delete_forever),
            onPressed: _isLoading || _box.isEmpty ? null : _clearAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            labelText: 'Add task',
                            hintText: 'Enter a value to store in Hive',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _addItem,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Open Box: ${_box.isOpen ? 'yes' : 'no'}'),
                      Text('Items: ${_box.length}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: _box.listenable(),
                      builder: (context, Box box, _) {
                        if (box.isEmpty) {
                          return const Center(
                            child: Text('No items stored yet.'),
                          );
                        }

                        final keys = box.keys.cast<int>().toList();

                        return ListView.separated(
                          itemCount: keys.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final key = keys[index];
                            final value = box.get(key);

                            return ListTile(
                              title: Text(value.toString()),
                              subtitle: Text('Key: $key'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _updateItem(key, value.toString()),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteItem(key),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
