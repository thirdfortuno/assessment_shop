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

  var price;

  @override
  Widget build(BuildContext context){
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: <Widget>[
            FutureBuilder(
              future: Firestore.instance.collection('stores').document(widget.storeID).collection('products').document(widget.product.documentID).get(),
              builder: (context, document){
                if (!document.hasData) return Text("Loading . . .");
                price ??= document.data['price'];
                return Column(
                  children: <Widget>[
                    Text(document.data['name'].toString()),
                    Text(document.data['price'].toString()),
                    Text(widget.product['quantity'].toString()),
                    Text((widget.product['quantity']*document.data['price']).toString()),
                  ]
                );
              }
            ),
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
                              await Firestore.instance.collection('total').document('total')
                              .updateData({
                                'price': FieldValue.increment(difference * price),
                                'quantity': FieldValue.increment(difference)
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
                              await Firestore.instance.collection('total').document('total')
                              .updateData({
                                'price': FieldValue.increment(-widget.product['quantity'] * widget.product['price']),
                                'quantity': FieldValue.increment(-widget.product['quantity'])
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

  Widget _buildProductList(context, snapshot, storeID){
    List<Widget> list = [
      FutureBuilder(
        future: Firestore.instance.collection('stores').document(storeID).get(),
        builder: (context, document){
          if (!document.hasData) return Text("Loading . . .");
          return Text(document.data['name']);
        }
      )
    ];
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
            return _buildProductList(context, snapshot, document.documentID);
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
              child: FutureBuilder(
                future: Firestore.instance.collection('total').document('total').get(),
                builder: (context, document){
                  if (!document.hasData) return Text("Loading . . .");
                  return Column(
                    children: <Widget>[
                      Text(document.data['price'].toString()),
                      Text(document.data['quantity'].toString()),
                      RaisedButton(
                        child: Text("Checkout"),
                        onPressed: () async {
                          await Firestore.instance.collection('cart').getDocuments().then((snapshot){
                            for (DocumentSnapshot doc in snapshot.documents){
                              doc.reference.delete();
                            }
                          });
                          await Firestore.instance.collection('total').document('total').updateData({
                            'price': 0.0,
                            'quantity': 0
                          });
                          setState(() {
                            
                          });
                        }
                      )
                    ],
                  );
                }
              ),
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