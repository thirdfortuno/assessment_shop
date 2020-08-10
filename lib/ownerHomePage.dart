import 'package:assessment_shop/widgets/ownerScaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Store{
  String name;
  String desc;
  String photo;
  String hours;

  Store(name, desc, photo, hours){
    this.name = name;
    this.desc = desc;
    this.photo = photo;
    this.hours = hours;
  }

  Map<String, dynamic> toJson() =>
  {
    'name': name,
    'desc': desc,
    'photo': photo,
    'hours': hours,
  };
}

class StoreCard extends StatefulWidget{
  const StoreCard({
    Key key,
    this.store
  }): super(key: key);

  final DocumentSnapshot store;

  @override
  _StoreCardState createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard>{

  final storeNameController = new TextEditingController();
  final storeDescController = new TextEditingController();
  final storePhotoController = new TextEditingController();
  final storeHoursController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Card(
        child: InkWell(
          child: Column(
            children: <Widget>[
              Text(widget.store['name']),
              Text(widget.store['desc']),
              Text(widget.store['photo']),
              Text(widget.store['hours'])
            ],
          ),
          onTap:() async {
            String origName = widget.store['name'];
            storeNameController.text = widget.store['name'];
            storeDescController.text = widget.store['desc'];
            storePhotoController.text = widget.store['photo'];
            storeHoursController.text = widget.store['hours'];
            showDialog(
              context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: Text("Editing $origName"),
                  content: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      children: <Widget>[
                        Text("Edit Store Name"),
                        TextField(
                          controller: storeNameController,
                        ),
                        SizedBox(height: 16),
                        Text("Edit Store Desc"),
                        TextField(
                          controller: storeDescController,
                        ),
                        SizedBox(height: 16),
                        Text("Edit Store Photo"),
                        TextField(
                          controller: storePhotoController,
                        ),
                        SizedBox(height: 16),
                        Text("Edit Store Hours"),
                        TextField(
                          controller: storeHoursController,
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Update"),
                      onPressed: () async {
                        String name = storeNameController.text;
                        String desc = storeDescController.text;
                        String photo = storePhotoController.text;
                        String hours = storeHoursController.text;
                        await Firestore.instance.collection('stores').document(widget.store.documentID)
                        .updateData({
                          'name': name,
                          'desc': desc,
                          'photo': photo,
                          'hours': hours,
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.red
                        ),
                      ),
                      onPressed: () async {
                        await Firestore.instance.collection('stores').document(widget.store.documentID).delete();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              }
            );
          }
        ),
      );
  }
}

class OwnerHomePage extends StatefulWidget{
  @override
  _OwnerHomePageState createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage>{

  final storeNameController = new TextEditingController();
  final storeDescController = new TextEditingController();
  final storePhotoController = new TextEditingController();
  final storeHoursController = new TextEditingController();

  List<Store> stores = [];

  void initState(){
    super.initState();
  }

  void addStore(){
    storeNameController.text = "";
    storeDescController.text = "";
    storePhotoController.text = "";
    storeHoursController.text = "";
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("New Store"),
          content: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              children: <Widget>[
                Text("Enter Store Name"),
                TextField(
                  controller: storeNameController,
                ),
                SizedBox(height: 16),
                Text("Enter Store Desc"),
                TextField(
                  controller: storeDescController,
                ),
                SizedBox(height: 16),
                Text("Enter Store Photo"),
                TextField(
                  controller: storePhotoController,
                ),
                SizedBox(height: 16),
                Text("Enter Store Hours"),
                TextField(
                  controller: storeHoursController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Enter"),
              onPressed: () async {
                String name = storeNameController.text;
                String desc = storeDescController.text;
                String photo = storePhotoController.text;
                String hours = storeHoursController.text;
                
                CollectionReference storesRef = Firestore.instance.collection('/stores');
                Store store = new Store(name, desc, photo, hours);
                Map<String, dynamic> storeData = store.toJson();
                await storesRef.add(storeData);

                Navigator.of(context).pop(); 
              },
            ),
            FlatButton(
              child: Text("Cancel"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  Widget _buildStoreItem(context, document){
    return StoreCard(
      store: document,
    );
  }

  @override
  Widget build(BuildContext context){
    return OwnerScaffold(
      title: "Owner Home Page",
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 100,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 40),
                  RaisedButton(
                    onPressed: (){
                      addStore();
                    },
                    child: Text(
                      "Add New Store"
                    ),
                  ),
                ]
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance.collection('stores').snapshots(),
                builder: (context, snapshot){
                  if (!snapshot.hasData) return Text("Loading . . .");
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) => _buildStoreItem(context, snapshot.data.documents[index]),
                  );
                }
              )
            ),
          ]
        )
      )
    );
  }
}