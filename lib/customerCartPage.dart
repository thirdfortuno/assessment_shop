import 'package:assessment_shop/widgets/customerScaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  final productQuantController = new TextEditingController();



  @override
  Widget build(BuildContext context){
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: <Widget>[
            Text(widget.product['name']),
            Text(widget.product['price'].toString()),
            Text(widget.product['quantity'].toString()),
            Text((widget.product['quantity']*widget.product['price']).toString()),
            RaisedButton(
              child: Text("Edit/Delete"),
              onPressed: () async {
                productQuantController.text = widget.product['quantity'].toString();
                showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text("${widget.product['name']} in cart"),
                      content: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: ListView(
                          children: <Widget>[
                            Text("Edit Amount"),
                            TextField(
                              controller: productQuantController,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                            child: Text("Update"),
                            onPressed: () async {
                              int difference = int.parse(productQuantController.text) - widget.product['quantity'];
                              await Firestore.instance.collection('stores').document(widget.storeID).collection('products').document(widget.product.documentID)
                              .updateData({
                                'quantity': FieldValue.increment(-difference)
                              });
                              await Firestore.instance.collection('cart').document(widget.storeID).collection('products').document(widget.product.documentID)
                              .updateData({
                                'quantity': int.parse(productQuantController.text)
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
                              "Remove",
                              style: TextStyle(
                                color: Colors.red
                              ),
                            ),
                            onPressed: () async {
                              await Firestore.instance.collection('stores').document(widget.storeID).collection('products').document(widget.product.documentID)
                              .updateData({
                                'quantity': FieldValue.increment(widget.product['quantity'])
                              });
                              await Firestore.instance.collection('cart').document(widget.storeID).collection('products').document(widget.product.documentID).delete();
                              Navigator.of(context).pop();
                            },
                          ),
                      ],
                    );
                  }
                );
              }
            )
          ],
        ),
      ),
    );
  }
}

class CustomerCartPage extends StatefulWidget{

  @override
  _CustomerCartPageState createState() => _CustomerCartPageState();
}

class _CustomerCartPageState extends State<CustomerCartPage>{

  Widget _buildProductList(context, snapshot, storeID, storeName){
    List<Widget> list = [Text(storeName)];
    for(var i = 0;i < snapshot.data.documents.length;i++){
      list.add(ProductCard(product: snapshot.data.documents[i], storeID: storeID));
    }
    return Column(
      children: list.length > 1 ? list : [],
    );
  }

  Widget _buildStoreList(context, document){
    return Column(
      children: <Widget>[
        StreamBuilder(
          stream: Firestore.instance.collection('cart').document(document.documentID).collection('products').snapshots(),
          builder: (context, snapshot){
            if (!snapshot.hasData) return Text("Loading . . .");
            return _buildProductList(context, snapshot, document.documentID, document['name']);
          }
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context){
    return CustomerScaffold(
      title: "Customer Cart",
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 200,
            ),
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance.collection('cart').snapshots(),
                builder: (context, snapshot){
                  if (!snapshot.hasData) return Text("Loading . . .");
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) => _buildStoreList(context, snapshot.data.documents[index])
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}