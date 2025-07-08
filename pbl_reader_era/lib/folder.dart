import 'package:flutter/material.dart';

class Folder extends StatefulWidget {
  Folder({super.key});

  @override
  State<Folder> createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  TextEditingController inputtext = TextEditingController();
  List<String> folders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Folders"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
              ],
            ),
          ),
        ),
      ),
      body: folders.isEmpty
          ? const Center(
        child: Text("No folders yet", style: TextStyle(fontSize: 20)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: folders.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.blue.shade50,
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.folder, color: Colors.blue),
              title: Text(folders[index],
                  style: const TextStyle(fontSize: 18)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      _showUpdateDialog(context, index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        folders.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFolderDialog(context);
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    inputtext.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              "Add Folder",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          content: TextField(
            controller: inputtext,
            decoration: InputDecoration(
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              hintText: "Enter Your Folder Name",
            ),
            keyboardType: TextInputType.text,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String name = inputtext.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    folders.add(name);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, int index) {
    TextEditingController updateController =
    TextEditingController(text: folders[index]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Folder Name"),
        content: TextField(
          controller: updateController,
          decoration: const InputDecoration(hintText: "Enter new folder name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              String updated = updateController.text.trim();
              if (updated.isNotEmpty) {
                setState(() {
                  folders[index] = updated;
                });
                Navigator.pop(context);
              }
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }
}
