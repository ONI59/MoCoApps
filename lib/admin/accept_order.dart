import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class HistoryOrder extends StatefulWidget {
  const HistoryOrder({Key? key}) : super(key: key);

  @override
  State<HistoryOrder> createState() => _HistoryOrderState();
}

class _HistoryOrderState extends State<HistoryOrder> {
  bool isLoading = true;
  List<Map<String, dynamic>> acceptedOrders = [];

  @override
  void initState() {
    super.initState();
    getData();
  }



  Future<void> getData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('accepted')
          .orderBy('timestamp', descending: true)
          .get();

      acceptedOrders.clear();

      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> order = doc.data() as Map<String, dynamic>;
        print("Order: $order");
        acceptedOrders.add(order);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff343456),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Accept Order',
          style: TextStyle(
            fontSize: 18.0,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    } else if (acceptedOrders.isEmpty) {
      return const Center(
        child: Text(
          'No orders have been accepted yet',
          style: TextStyle(
            fontSize: 16.0,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: acceptedOrders.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> orderData = acceptedOrders[index];
          List<dynamic> orderList = orderData['orderList'];

          orderList = List.from(orderList.reversed);

          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: orderList.isNotEmpty
                        ? Image.asset(
                      "images/accept.png",
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                        : Container(),
                  ),
                ),
                const SizedBox(height: 10),
                orderList.isNotEmpty
                    ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderList.length,
                  itemBuilder: (context, listIndex) {
                    return ListTile(
                      title: Text('${orderList[listIndex]['name'] ?? 'No Name'} | x${orderList[listIndex]['quantity'] ?? 'No Quantity'}',style: const TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'Poppins',
                        color: Colors.black)),
                      subtitle: Text('Name User: ${orderList[listIndex]['name user']}\nTable Number: ${orderList[listIndex]['table number']}'),
                    );
                  },
                )
                    : Container(),
              ],
            ),
          );
        },
      );
    }
  }
}