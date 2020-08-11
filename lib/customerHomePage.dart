import 'package:assessment_shop/customerCartPage.dart';
import 'package:assessment_shop/widgets/customerScaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartObject{
  String name;
  double price;
  int quantity;

  CartObject(name, price, quantity){
    this.name = name;
    this.price = price;
    this.quantity = quantity;
  }

  Map<String, dynamic> toJson() =>
  {
    'name': name,
    'price': price,
    'quantity': quantity
  };
}

class CustomerProductCard extends StatefulWidget{
  const CustomerProductCard({
    Key key,
    this.product,
    this.store
  });

  final DocumentSnapshot product;
  final DocumentSnapshot store;

  @override
  _CustomerProductCardState createState() => _CustomerProductCardState();
}

class _CustomerProductCardState extends State<CustomerProductCard>{

  final purchaseController = new TextEditingController();

  @override
  Widget build(BuildContext context){
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(widget.product['name']),
                  Text(widget.product['desc']),
                  Text(widget.product['photo']),
                  Text(widget.product['price'].toString()),
                  Text(widget.product['quantity'].toString()),
                ],
              ),
            ),
            Spacer(),
            RaisedButton(
              child: Text("View"),
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text("Buying ${widget.product['name']}"),
                      content: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: ListView(
                          children: <Widget>[
                            Text(widget.product['desc']),
                            Text(widget.product['photo']),
                            Text(widget.product['price'].toString()),
                            Text(widget.product['quantity'].toString()),
                            SizedBox(height: 16),
                            Text("How many to buy?"),
                            TextField(
                              controller: purchaseController,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                            child: Text("Add to Cart"),
                            onPressed: () async {
                              int quantity = int.parse(purchaseController.text);
                              DocumentSnapshot storeSnap = await Firestore.instance.collection('cart').document(widget.store.documentID).collection('products').document(widget.product.documentID).get();
                              DocumentSnapshot cartSnap = await Firestore.instance.collection('cart').document(widget.store.documentID).collection('products').document(widget.product.documentID)
                              .collection('products').document(widget.product.documentID).get();
                              await Firestore.instance.collection('stores').document(widget.store.documentID).collection('products').document(widget.product.documentID)
                              .updateData({
                                'quantity': FieldValue.increment(-quantity)
                              });
                              if (!storeSnap.exists){
                                await Firestore.instance.collection('cart').document(widget.store.documentID).setData({
                                  'name': widget.store['name']
                                });
                              }
                              if (cartSnap.exists){
                                await Firestore.instance.collection('cart').document(widget.store.documentID).collection('products').document(widget.product.documentID)
                              .updateData({
                                'quantity': FieldValue.increment(quantity)
                              });
                              } else {
                                CartObject cart = new CartObject(widget.product['name'], widget.product['price'], quantity);
                                Map<String, dynamic> cartData = cart.toJson();
                                await Firestore.instance.collection('cart').document(widget.store.documentID).collection('products').document(widget.product.documentID).setData(cartData);
                              }
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
            )
          ],
        ),
      ),
    );
  }
}

class CustomerHomePage extends StatefulWidget{

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>{

  Widget _productInventory(context, snapshot, store){
    List<Widget> list = [];
    for(var i = 0;i < snapshot.data.documents.length;i++){
      list.add(CustomerProductCard(product: snapshot.data.documents[i], store: store));
    }
    return Column(
      children: list.length > 0 ? list : [Text("No Products Available")],
    );
  }

  Widget _buildStore(context, document){
    return Column(
      children: <Widget>[
        Text(document['name']),
        Text(document['desc']),
        Text(document['photo']),
        Text(document['hours']),
        Text("Products"),
        StreamBuilder(
          stream: Firestore.instance.collection('stores').document(document.documentID).collection('products').snapshots(),
          builder: (context, snapshot){
            if (!snapshot.hasData) return Text("Loading . . .");
            return _productInventory(context, snapshot, document);
          }
        ),
        Divider()
      ],
    );
  }

  @override
  Widget build(BuildContext context){
    return CustomerScaffold(
      title: "Customer Home Page",
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 200,
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CustomerCartPage())
                      );
                    },
                    child: Text("View Cart"),
                  )
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance.collection('stores').snapshots(),
                builder: (context, snapshot){
                  if (!snapshot.hasData) return Text("Loading . . .");
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) => _buildStore(context, snapshot.data.documents[index])
                  );
                }
              )
            ),
          ],
        ),
      ),
    );
  }
}