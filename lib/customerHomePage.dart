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
                            FadeInImage.assetNetwork(
                              height: 100,
                              placeholder: 'assets/no_img.png',
                              image: widget.product['photo']
                            ),
                            Row( //This should be a RichText, but I'm having some issues on my phone with this
                              children: <Widget>[
                                Text("Cost: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(widget.product['price'].toString()),
                              ]
                            ),
                            Row( //This should be a RichText, but I'm having some issues on my phone with this
                              children: <Widget>[
                                Text("Stock: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(widget.product['quantity'].toString()),
                              ]
                            ),
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
                              DocumentSnapshot cartSnap = await Firestore.instance.collection('cart').document(widget.store.documentID).collection('products')
                              .document(widget.product.documentID).get();
                              await Firestore.instance.collection('stores').document(widget.store.documentID).collection('products').document(widget.product.documentID)
                              .updateData({
                                'quantity': FieldValue.increment(-quantity)
                              });
                              await Firestore.instance.collection('cart').document(widget.store.documentID).setData({
                                'name': widget.store['name']
                              });
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
                              await Firestore.instance.collection('total').document('total')
                              .updateData({
                                'price': FieldValue.increment(quantity * widget.product['price']),
                                'quantity': FieldValue.increment(quantity)
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

  FutureBuilder cartInfo;

  void initState(){
    super.initState();
    cartInfo = _cartInfo();
  }

  FutureBuilder _cartInfo(){
    return FutureBuilder(
      future: Firestore.instance.collection('total').document('total').get(),
      builder: (context, document){
        if (!document.hasData) return Text("Loading . . .");
        return Column(
          children: <Widget>[
            Row( //This should be a RichText, but I'm having some issues on my phone with this
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Total Cost: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(document.data['price'].toString()),
              ]
            ),
            Row( //This should be a RichText, but I'm having some issues on my phone with this
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Total Item Count: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(document.data['quantity'].toString()),
              ]
            ),
          ]
        );
      }
    );
  }

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
        Text(document['name'],style: TextStyle(fontWeight: FontWeight.bold)),
        Text(document['desc']),
        FadeInImage.assetNetwork(
          height: 100,
          placeholder: 'assets/no_img.png',
          image: document['photo']
        ),
        Row( //This should be a RichText, but I'm having some issues on my phone with this
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Open Hours: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(document['hours']),
          ]
        ),
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
            SizedBox(height: 20),
            Container(
              height: 100,
              child: Column(
                children: <Widget>[
                  cartInfo,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: (){
                          setState(() {
                            cartInfo = _cartInfo();
                          });
                        },
                        child: Text("Refresh Cart"),
                      ),
                      SizedBox(width: 8),
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
                ],
              ),
            ),
            Divider(),
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