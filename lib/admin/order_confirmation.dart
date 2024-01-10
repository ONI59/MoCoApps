import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../service/database.dart';
import '../service/shared_preference_helper.dart';
import '../widget/widget_support.dart';

class HistoryAdd extends StatefulWidget {
  const HistoryAdd({super.key});

  @override
  State<HistoryAdd> createState() => _HistoryAddState();
}

class _HistoryAddState extends State<HistoryAdd> {
  Future<List<Map<String, dynamic>>>? orderListFuture;
  List<Map<String, dynamic>> orderList = [];
  List<dynamic> itemsToRemove = [];
  String? id;
  String? userId;


  @override
  void initState() {
    super.initState();
    initializeData();
  }


  Future<void> initializeData() async {
    id = await SharedPreferenceHelper().getIdUser();

    if (id != null) {
      orderListFuture = DatabaseMethods().getOrderListForAllUsers();
      print(await orderListFuture);
    } else {
      print("ID is null");
    }

    if (mounted) {
      setState(() {});
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff343456),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Order Confirmation', style: AppWidget.HeadlineTextFeildStyle()),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: orderListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                ""
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> orderData = snapshot.data![index];
                List<Map<String, dynamic>> currentOrderList = List<Map<String, dynamic>>.from(orderData['orderList']);
                return OrderItemWidget(
                  orderList: currentOrderList,
                  removeItemCallback: () => removeOrder(id!, orderData['orderId'], currentOrderList),
                  orderAcceptedCallback: () => orderAccepted(orderData),
                  orderRejectedCallback: () => orderRejected(orderData),
                );


              },
            );
          }
        },
      ),
    );
  }



  void removeOrder(String userId, List<Map<String, dynamic>> orderList, List<dynamic> itemsToRemove) async {
    try {
      if (userId.isNotEmpty ) {
        print('Before removal: $orderList');
        print('After removal: $orderList');

        await DatabaseMethods().removeOrder(userId, orderList, itemsToRemove);
      } else {
        print("Invalid userId or itemsToRemove: userId=$userId, itemsToRemove=$itemsToRemove");
      }
    } catch (e) {
      print('Error removing items from Firestore: $e');
    }
  }


  void orderAccepted(Map<String, dynamic> orderData) async {
    String? userId = orderData['userId'];
    List<Map<String, dynamic>> itemsToRemove = List<Map<String, dynamic>>.from(orderData['orderList'] ?? []);

    if (userId != null && userId.isNotEmpty) {
      orderData['timestamp'] = FieldValue.serverTimestamp();
      await DatabaseMethods().acceptedOrder(orderData);

      setState(() {
        removeOrder(userId, orderList, itemsToRemove);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: CupertinoColors.activeGreen,
          content: Text('Order has been received', style: TextStyle(fontSize: 16.0, fontFamily: 'Poppins', color: Colors.white)),
        ),
      );
    } else {
      print("Invalid userId or itemsToRemove: userId=$userId, itemsToRemove=$itemsToRemove");
    }
  }



  void orderRejected(Map<String, dynamic> orderData) async {
    String? userId = orderData['userId'];
    List<Map<String, dynamic>> itemsToRemove = List<Map<String, dynamic>>.from(orderData['orderList'] ?? []);
    if (userId != null && userId.isNotEmpty) {
      await DatabaseMethods().RejectedOrder(orderData);

      setState(() {
        removeOrder(userId, orderList, itemsToRemove);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: CupertinoColors.systemRed,
          content: Text('Order Canceled', style: TextStyle(fontSize: 16.0, fontFamily: 'Poppins', color: Colors.white)),
        ),
      );
    } else {
      print("Invalid userId: userId=$userId");
    }
  }

}

class OrderItemWidget extends StatefulWidget {
  final List<dynamic> orderList;
  final Function() removeItemCallback;
  final Function() orderAcceptedCallback;
  final Function() orderRejectedCallback;

  const OrderItemWidget({super.key, 
    required this.orderList,
    required this.removeItemCallback,
    required this.orderAcceptedCallback,
    required this.orderRejectedCallback,
  });

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
        child: Visibility(
          visible: widget.orderList.isNotEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              if (widget.orderList.isEmpty)
                Text(
                  "Oops, tidak ada item",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int itemIndex = 0;
                    itemIndex < widget.orderList.length;
                    itemIndex++)
                      OrderListItem(
                        orderItem: widget.orderList[itemIndex],
                        removeItemCallback: widget.removeItemCallback,
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => handleOrderAccepted(context),
                          child: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                        const SizedBox(width: 60.0),
                        GestureDetector(
                          onTap: () => handleOrderRejected(context),
                          child: const Icon(Icons.cancel, color: Colors.red),
                        ),
                        const SizedBox(width: 10.0),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
            ],
          ),
        )
    );
  }


  void handleOrderAccepted(BuildContext context) {
    setState(() {
      isLoading = true;
    });

    showLoadingAlert(context);

    Future.delayed(const Duration(seconds: 4), () {
      widget.orderAcceptedCallback();

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isLoading = false;
          widget.orderList.clear();
          Navigator.pop(context);
        });
      });
    });
  }

  void handleOrderRejected(BuildContext context) {
    setState(() {
      isLoading = true;
    });

    showLoadingAlert(context);

    Future.delayed(const Duration(seconds: 4), () {
      widget.orderRejectedCallback();

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isLoading = false;
          widget.orderList.clear();
          Navigator.pop(context);
        });
      });
    });
  }

  void showLoadingAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10.0),
              Text("Wait..."),
            ],
          ),
        );
      },
    );
  }
}





class OrderListItem extends StatelessWidget {
  final dynamic orderItem;
  final Function() removeItemCallback;

  const OrderListItem({super.key,
    required this.orderItem,
    required this.removeItemCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10.0),
          Container(
            margin: const EdgeInsets.all(10),
            height: 120,
            width: 120,
            child: orderItem['image'] != null
                ? Image.network(
              orderItem['image'],
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            )
                : Container(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20.0),
                Text(
                  '${orderItem['quantity'] ?? 'No Quantity'}x | ${orderItem['name'] ?? 'No Name'}',
                  style: AppWidget.Headline2TextFeildStyle(),
                ),
                const SizedBox(height: 20.0,),
                Text('Name User:${orderItem['name user']},\nTable Number:${orderItem['table number']}'),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}