
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'crud_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

   @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final CrudService service = CrudService();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();
  bool _showFavoritesOnly = false;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Firebase Millevo'),
        centerTitle: true,
        backgroundColor: Colors.teal,
actions: [
    IconButton(
      icon: Icon(
        _showFavoritesOnly
            ? Icons.favorite
            : Icons.favorite_border,
        color: Colors.white,
      ),
      onPressed: () {
        setState(() {
          _showFavoritesOnly = !_showFavoritesOnly;
        });
      },
    ),
  ],
        
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          openAddDialog(context);
        },
      ), // FloatingActionButton
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          final filteredDocs = _showFavoritesOnly
            ? docs.where((item) {
            final data = item.data() as Map<String, dynamic>;
            return data['isFavorite'] == true;}).toList(): docs;

          if (filteredDocs.isEmpty) {
            return Center(child: Text(_showFavoritesOnly ? "No favorite items found" : "No items found", 
            style: TextStyle(fontSize: 18)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              var item = filteredDocs[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(item['name'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text('Quantity: ${item['quantity']}'),
                  trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [

    // ADDED: FAVORITE HEART
    IconButton(
      icon: Icon(
        (item.data() as Map<String, dynamic>)['isFavorite'] == true
            ? Icons.favorite
            : Icons.favorite_border,
        color:
            (item.data() as Map<String, dynamic>)['isFavorite'] == true
                ? Colors.red
                : Colors.grey,
      ),
      onPressed: () {
        final data = item.data() as Map<String, dynamic>;

        service.toggleFavorite(
          item.id,
          data['isFavorite'] == true,
        );
      },
    ),

    // EDIT BUTTON
    IconButton(
      icon: const Icon(Icons.edit, color: Colors.orange),
      onPressed: () => openEditDialog(context, item),
    ),

    // DELETE BUTTON
    IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () => _confirmDelete(context, item.id),
    ),
  ],
),
                  
                ),
              );
            }
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Delete Item"),
      content: const Text("Are you sure you want to delete this item?"),
      actions: [
        TextButton(
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
          onPressed: () {
            service.deleteItem(id);
            Navigator.pop(context);
          },
        ), // TextButton
      ],
    ),
  );
}

void openAddDialog(BuildContext context) {
  nameCtrl.clear();
  qtyCtrl.clear();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Add Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ), // TextField

          const SizedBox(height: 12),

          TextField(
            controller: qtyCtrl,
            decoration: InputDecoration(
              labelText: "Quantity",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
            ),
          ), // TextField
        ],
      ),

      actions: [
        TextButton (
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ), // textButton
        
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
        ),

          child: const Text("Save"),
           onPressed: () {
            if (nameCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty) {
              service.addItem(nameCtrl.text, int.parse(qtyCtrl.text));
              Navigator.pop(context);
             }
            },
         ), // TextButton
      ],
    )// AlertDialog
  );
}

void openEditDialog(BuildContext context, DocumentSnapshot item) {
  nameCtrl.text = item['name'];
  qtyCtrl.text = item['quantity'].toString();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Edit item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),),
            ), // InputDecoration
          ), // TextField
          const SizedBox(height: 12),
          TextField(
            controller: qtyCtrl,
            decoration: InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),),
            ), // InputDecoration
          ), // TextField
        ],
      ), // Column
       actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ), // TextButton
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            
          ),
          child: const Text('Update'),
          onPressed: () {
            if (nameCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty) {
              service.updateItem(item.id, nameCtrl.text, int.parse(qtyCtrl.text));
              Navigator.pop(context);
            }
          },
        ), // ElevatedButton]
       ]
    ),
  );
}
}
            