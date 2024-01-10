import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee/admin/after_add.dart';
import 'package:coffee/admin/accept_order.dart';
import 'package:coffee/admin/order_confirmation.dart';
import 'package:coffee/admin/rejected_order.dart';
import 'package:coffee/pages/add_food.dart';
import 'package:coffee/pages/login.dart';
import 'package:coffee/widget/widget_support.dart';
import 'package:flutter/material.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<HomeAdmin> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff343456),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Home Admin",
                  style: AppWidget.HeadlineTextFeildStyle(),
                ),
              ),
              const SizedBox(height: 50.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddFood(),
                    ),
                  );
                },
                child: Material(
                  elevation: 10.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(
                              "images/brownies.png",
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 30.0),
                          const Text(
                            "Add Food Items",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              GestureDetector(
                onTap: () async {
                  QuerySnapshot orderSnapshot = await FirebaseFirestore.instance.collection('orders').get();
        
                  List<Map<String, dynamic>> orderList = orderSnapshot.docs.map((DocumentSnapshot doc) {
                    return {
                      'quantity': doc['quantity'],
                      'name': doc['name'],
                      'total': doc['total'],
                    };
                  }).toList();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryAdd(),
                    ),
                  );
                },
                child: Material(
                  elevation: 10.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(
                              "images/kuepink.png",
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 30.0),
                          const Text(
                            "Order Confirmation",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              GestureDetector(
                onTap: () async {
                  QuerySnapshot orderSnapshot = await FirebaseFirestore.instance.collection('orders').get();
        
                  List<Map<String, dynamic>> orderList = orderSnapshot.docs.map((DocumentSnapshot doc) {
                    return {
                      'quantity': doc['quantity'],
                      'name': doc['name'],
                      'total': doc['total'],
                    };
                  }).toList();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AfterAdd(),
                    ),
                  );
                },
                child: Material(
                  elevation: 10.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(
                              "images/kuecoklat.png",
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 30.0),
                          const Text(
                            "Edit Menu",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryOrder(),
                    ),
                  );
                },
                child: Material(
                  elevation: 10.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(
                              "images/accept.png",
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 30.0),
                          const Text(
                            "Accepted Order",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 50.0),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RejectedOrder(),
              ),
            );
          },
          child: Material(
            elevation: 10.0,
            borderRadius: BorderRadius.circular(10),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        "images/reject.png",
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    const Text(
                      "Rejected Order",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40.0),
        ElevatedButton(
          onPressed: () {
         Navigator.push(context, MaterialPageRoute(builder: (context)=> const Login()));
          },
          child: Text('Sign Out', style: AppWidget.semibold2TextFeildStyle(),),
          ),
              const SizedBox(height: 40.0,)
            ],
          ),
        ),
      ),
    );
  }
}