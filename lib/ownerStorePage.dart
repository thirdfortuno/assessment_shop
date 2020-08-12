import 'package:assessment_shop/widgets/ownerScaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Product{
  String name;
  String desc;
  String photo;
  double price;
  int quantity;

  Product(name, desc, photo, price, quantity){
    this.name = name;
    this.desc = desc;
    this.photo = photo;
    this.price = price;
    this.quantity = quantity;
  }

  Map<String, dynamic> toJson() => 
  {
    'name': name,
    'desc': desc,
    'photo': photo,
    'price': price,
    'quantity': quantity,
  };
}

class ProductCard extends StatefulWidget{
  const ProductCard({
    Key key,
    this.product,
    this.storeID
  });

  final DocumentSnapshot product;
  final String storeID;

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>{
  final productNameController = TextEditingController();
  final productDescController = TextEditingController();
  final productPhotoController = TextEditingController();
  final productPriceController = TextEditingController();
  final productQuantController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Card(
      child: Container(
        child: Column(
          children: <Widget>[
            Text(widget.product['name'],style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.product['desc']),
            FadeInImage.assetNetwork(
              height: 100,
              placeholder: 'assets/no_img.png',
              image: widget.product['photo']
            ),
            Row( //This should be a RichText, but I'm having some issues on my phone with this
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Price: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.product['price'].toString()),
              ]
            ),
            Row( //This should be a RichText, but I'm having some issues on my phone with this
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Stock: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.product['quantity'].toString()),
              ]
            ),
            RaisedButton(
              onPressed: () async {
                String origName = widget.product['name'];
                productNameController.text = widget.product['name'];
                productDescController.text = widget.product['desc'];
                productPhotoController.text = widget.product['photo'];
                productPriceController.text = widget.product['price'].toString();
                productQuantController.text = widget.product['quantity'].toString();
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
                            Text("Edit Product Name"),
                            TextField(
                              controller: productNameController,
                            ),
                            SizedBox(height: 16),
                            Text("Edit Product Description"),
                            TextField(
                              controller: productDescController,
                            ),
                            SizedBox(height: 16),
                            Text("Edit Product Photo URL"),
                            TextField(
                              controller: productPhotoController,
                            ),
                            SizedBox(height: 16),
                            Text("Edit Product Price"),
                            TextField(
                              controller: productPriceController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 16),
                            Text("Edit Product Quantity"),
                            TextField(
                              controller: productQuantController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                            child: Text("Update"),
                            onPressed: () async {
                              String name = productNameController.text;
                              String desc = productDescController.text;
                              String photo = productPhotoController.text;
                              double price = double.parse(productPriceController.text);
                              int quantity = int.parse(productQuantController.text);

                              await Firestore.instance.collection('stores').document(widget.storeID).collection('products').document(widget.product.documentID)
                              .updateData({
                                'name': name,
                                'desc': desc,
                                'photo': photo,
                                'price': price,
                                'quantity': quantity
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
                              await Firestore.instance.collection('stores').document(widget.storeID).collection('products').document(widget.product.documentID).delete();
                              Navigator.of(context).pop();
                            },
                          ),
                      ],
                    );
                  }
                );
              },
              child: Text("Edit/Delete"),
            )
          ],
        ),
      ),
    );
  }
}

class OwnerStorePage extends StatefulWidget{
  OwnerStorePage({Key key, this.store}) : super(key: key);

  final DocumentSnapshot store;

  @override
  _OwnerStorePageState createState() => _OwnerStorePageState();
}

class _OwnerStorePageState extends State<OwnerStorePage>{

  final productNameController = TextEditingController();
  final productDescController = TextEditingController();
  final productPhotoController = TextEditingController();
  final productPriceController = TextEditingController();
  final productQuantController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void addProduct(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("New Product for ${widget.store['name']}"),
          content: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              children: <Widget>[
                Text("Enter Product Name"),
                TextField(
                  controller: productNameController,
                ),
                SizedBox(height: 16),
                Text("Enter Product Description"),
                TextField(
                  controller: productDescController,
                ),
                SizedBox(height: 16),
                Text("Enter Product Photo URL"),
                TextField(
                  controller: productPhotoController,
                ),
                SizedBox(height: 16),
                Text("Enter Product Price"),
                TextField(
                  controller: productPriceController,
                  keyboardType: TextInputType.number
                ),
                SizedBox(height: 16),
                Text("Enter Product Quantity"),
                TextField(
                  controller: productQuantController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Enter"),
              onPressed: () async {
                String name = productNameController.text;
                String desc = productDescController.text;
                String photo = productPhotoController.text;
                double price = double.parse(productPriceController.text);
                int quantity = int.parse(productQuantController.text);
                Product product = new Product(name, desc, photo, price, quantity);
                CollectionReference productRef = Firestore.instance.collection('/stores').document(widget.store.documentID).collection('products');
                Map<String,dynamic> productData = product.toJson();
                await productRef.add(productData);
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

  Widget _buildProductItem(context, document, storeID){
    return(ProductCard(product: document, storeID: storeID));
  }

  @override
  Widget build(BuildContext context){
    return OwnerScaffold(
      title: widget.store['name'],
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 250,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 28),
                  Text(widget.store['desc']),
                  FadeInImage.assetNetwork(
                    height: 100,
                    placeholder: 'assets/no_img.png',
                    image: widget.store['photo']
                  ),
                  Row( //This should be a RichText, but I'm having some issues on my phone with this
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Open Hours: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(widget.store['hours']),
                    ]
                  ),
                  RaisedButton(
                    onPressed: (){
                      addProduct();
                    },
                    child: Text(
                      "Add New Product"
                    ),
                  ),
                  Text("Products"),
                ]
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance.collection('stores').document(widget.store.documentID).collection('products').snapshots(),
                builder: (context, snapshot){
                  if (!snapshot.hasData) return Text("Loading . . .");
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) => _buildProductItem(context, snapshot.data.documents[index], widget.store.documentID),
                  );
                }
              ),
            ),
          ]
        )
      )
    );
  }
}