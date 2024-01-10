import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee/service/database.dart';
import 'package:coffee/service/shared_preference_helper.dart';
import 'package:coffee/widget/widget_support.dart';
import 'package:flutter/material.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  late AsyncSnapshot<dynamic> foodSnapshot;
  Stream? foodStream;
  String? id, wallet;
  int total = 0, amount2 = 0;
  late Timer _timer;

  void startTimer() {
    _timer = Timer(const Duration(seconds: 2), () {
      amount2 = total;
      if (mounted) {
        setState(() {});
      }
    });
  }

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getIdUser();
    wallet = await SharedPreferenceHelper().getWalletUser();
    if (mounted) {
      setState(() {});
    }
  }

  ontheload() async {
    await getthesharedpref();
    foodStream = await DatabaseMethods().getFoodCart(id!);
    if (mounted) {
      setState(() {});
    }
  }



  @override
  void initState() {
    super.initState();
    ontheload();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController tableController = TextEditingController();

  Widget foodCart() {
    return StreamBuilder(
      stream: foodStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return Center(
            child: Text("No items in the cart", style: AppWidget.semiboldTextFeildStyle(),),
          );
        } else {
          foodSnapshot = snapshot;
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              total = total + int.parse(ds["Total"]);
              return Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          height: 85,
                          width: 35,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              ds["Quantity"],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            ds["Image"],
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ds["Name"].length > 10
                                  ? ds["Name"].substring(0, 10) + '...'
                                  : ds["Name"],
                              style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'Poppins'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.justify,
                            ),
                            Text(
                              "Rp. " + ds["Total"],
                              style: AppWidget.semibold2TextFeildStyle(),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
        }
      });
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Checkout Information'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          content: Form(
            key: _formKey,
            child: SizedBox(
              height: 250,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Your Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: tableController,
                    decoration: const InputDecoration(labelText: 'Table Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the table number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {

                if (_formKey.currentState!.validate()) {
                  int walletBalance = int.parse(wallet!);
                  if (walletBalance <= 0) {
                    showDialog(
                      context: context,
                      builder: (_) => const AlertDialog(
                        content: Text("Insufficient funds in the wallet"),
                      ),
                    );
                    return;
                  }

                  String name = nameController.text;
                  String tableNumber = tableController.text;

                  int amount = int.parse(wallet!) - amount2;
                  await DatabaseMethods().UpdateUserwallet(id!, amount.toString());
                  await SharedPreferenceHelper().saveUserWallet(amount.toString());

                  List<Map<String, dynamic>> orderList = [];

                  for (int index = 0; index < foodSnapshot.data.docs.length; index++) {
                    DocumentSnapshot ds = foodSnapshot.data.docs[index];
                    Map<String, dynamic> orderItem = {
                      'quantity': ds["Quantity"],
                      'image': ds["Image"],
                      'name': ds["Name"],
                      'total': ds["Total"],
                      'name user': name,
                      'table number': tableNumber,
                    };
                    orderList.add(orderItem);
                  }
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              Text("Payment Successful"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                  await DatabaseMethods().clearFoodCart(id!);
                  setState(() {
                    total = 0;
                  });

                  await DatabaseMethods().sendOrderDetailsToHistory(id!, orderList);

                  print('Name: $name, Table Number: $tableNumber');
                }
              },
              child: const Text('Checkout'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff343456),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.black,
              elevation: 2.0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 20.0, top: 50.0),
                child: Center(
                  child: Text(
                    "Food Troli",
                    style: AppWidget.HeadlineTextFeildStyle(),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height / 1.7,
                child: foodCart()),
            const Spacer(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Price",
                    style: AppWidget.boldTextFeildStyle(),
                  ),
                  Text(
                    "Rp. $total",
                    style: AppWidget.semiboldTextFeildStyle(),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: _showCheckoutDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: const Center(
                  child: Text(
                    "CheckOut",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
