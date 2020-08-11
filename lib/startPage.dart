import 'package:assessment_shop/customerHomePage.dart';
import 'package:assessment_shop/ownerHomePage.dart';
import 'package:flutter/material.dart';

class StartPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Welcome to Assesment Shop!",
              style: TextStyle(
                fontSize: 20
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Choose your login: ",
              style: TextStyle(
                fontSize: 18
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text(
                    "Shop Owner"
                  ),
                  onPressed: (){
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => OwnerHomePage()),
                    );
                  }
                ),
                SizedBox(width: 16),
                RaisedButton(
                  child: Text(
                    "Customer"
                  ),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomerHomePage()),
                    );
                  }
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}