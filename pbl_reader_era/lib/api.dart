import 'package:flutter/material.dart';
import 'package:pbl_reader_era/Login.dart';
import 'package:pbl_reader_era/readera.dart';

class Api extends StatefulWidget {
  const Api({super.key});

  @override
  State<Api> createState() => _ApiState();
}

class _ApiState extends State<Api> {
  @override
  Widget build(BuildContext context) {
    List<String> folders = [];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Format"),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.account_circle), text: "Account"),
                Tab(icon: Icon(Icons.account_circle), text: "Account"),
                Tab(icon: Icon(Icons.account_circle), text: "Account"),
              ],
            ),
          ),
          drawer: App(), // Drawer Widget
          body: TabBarView(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => readera()),
                    );
                  },
                  child: Container(
                    color: Colors.green,
                    width: 100,
                    height: 50,
                    alignment: Alignment.center,
                    child: Text("Click me"),
                  ),
                ),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      ListView.builder(
                        itemCount: folders.length,
                        itemBuilder:(context,index){
                          return Card(
                           margin: EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              leading: Icon(Icons.folder,color: Colors.blue,),
                              title: Text(folders[index]),

                            ),
                          );
                        }


                      ),
                    ],
                  ),
                ],
              ),
              Center(child: Text("Data")),
            ],
          ),
        ),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Builder(
        builder: (context) => ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("assets/images/user.jpeg"),
              ),
              accountName: Text("data"),
              accountEmail: Text("Email"),
            ),
            ListTile(
              leading: Icon(Icons.account_circle, size: 30),
              title: Text("Account"),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => readera()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
