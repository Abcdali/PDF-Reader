import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: TourMintApp()));
}

class TourMintApp extends StatefulWidget {
  @override
  _TourMintAppState createState() => _TourMintAppState();
}

class _TourMintAppState extends State<TourMintApp> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _days = TextEditingController();

  final CollectionReference tours = FirebaseFirestore.instance.collection('tours');

  void _createTour() async {
    await tours.add({
      'username': _username.text,
      'date': _date.text,
      'location': _location.text,
      'days': int.tryParse(_days.text) ?? 0,
    });
    _clearFields();
  }

  void _updateTour(String id) async {
    await tours.doc(id).update({
      'username': _username.text,
      'date': _date.text,
      'location': _location.text,
      'days': int.tryParse(_days.text) ?? 0,
    });
    _clearFields();
  }

  void _deleteTour(String id) async {
    await tours.doc(id).delete();
  }

  void _clearFields() {
    _username.clear();
    _date.clear();
    _location.clear();
    _days.clear();
  }

  void _populateFields(DocumentSnapshot doc) {
    _username.text = doc['username'];
    _date.text = doc['date'];
    _location.text = doc['location'];
    _days.text = doc['days'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TourMint (CRUD)')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildTextField(_username, 'Username'),
            _buildTextField(_date, 'Date (YYYY-MM-DD)'),
            _buildTextField(_location, 'Location'),
            _buildTextField(_days, 'Days (e.g., 5)', inputType: TextInputType.number),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _createTour, child: Text('Create')),
                ElevatedButton(onPressed: _clearFields, child: Text('Clear')),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: tours.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var doc = docs[index];
                      return Card(
                        child: ListTile(
                          title: Text('${doc['username']} - ${doc['location']}'),
                          subtitle: Text('Date: ${doc['date']} | Days: ${doc['days']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: Icon(Icons.edit), onPressed: () {
                                _populateFields(doc);
                                _updateDialog(doc.id);
                              }),
                              IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteTour(doc.id)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? inputType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        keyboardType: inputType ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _updateDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Tour'),
        content: Text('Are you sure you want to update this tour?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _updateTour(id);
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}
