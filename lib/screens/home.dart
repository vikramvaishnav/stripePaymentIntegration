import 'package:flutter/material.dart';
import 'package:mastering_payments/provider/products_provider.dart';
import 'package:mastering_payments/provider/user_provider.dart';
import 'package:mastering_payments/screens/login1.dart';
import 'package:mastering_payments/screens/manage_cards.dart';
import 'package:mastering_payments/services/functions.dart';
import 'package:mastering_payments/services/stripe.dart';
import 'package:mastering_payments/services/styles.dart';
import 'package:mastering_payments/widgets/custom_text.dart';
import 'package:provider/provider.dart';

import 'credit_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StripeServices stripe = StripeServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final products = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.green),
        title: Text(
          "Languages Market",
          style: TextStyle(color: Colors.green),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountEmail: CustomText(
                msg: "vikramvaishnav@gmail.com",
                color: white,
              ),
              accountName: CustomText(
                msg: "Vikram Vaishnav",
                color: white,
              ),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: CustomText(
                msg: "Add Credit Card",
              ),
              onTap: () {
                changeScreen(
                    context,
                    CreditCard(
                      title: "Add card",
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.credit_card),
              title: CustomText(
                msg: "Manage Cards",
              ),
              onTap: () {
                changeScreen(context, ManagaCardsScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: CustomText(
                msg: "Log out",
              ),
              onTap: () {
                user.signOut();
                changeScreenReplacement(context, LoginOne());
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
              color: white,
              child: ListView(
                children: <Widget>[
                  Visibility(
                    visible: !user.hasStripeId,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          changeScreen(
                              context,
                              CreditCard(
                                title: "Add card",
                              ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: red[400],
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.warning,
                                  color: white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                CustomText(
                                  msg: "Please add your card details",
                                  size: 14,
                                  color: white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
