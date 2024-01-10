import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userInfoMap);
  }

  Future addFoodItem(Map<String, dynamic> userInfoMap, String name) async {
    return await FirebaseFirestore.instance.collection(name).add(userInfoMap);
  }

  Future<void> updateFoodItem(String docId, Map<String, dynamic> updatedData, String name) async {
    try {
      await _firestore.collection(name).doc(docId).update(updatedData);
    } catch (e) {
      print("Error updating food item: $e");
      rethrow;
    }
  }


  Future<Stream<QuerySnapshot>> getFoodItem(String name) async {
    return FirebaseFirestore.instance.collection(name).snapshots();
  }

  Future addFoodToCart(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection("Cart")
        .add(userInfoMap);
  }

  Future<void> clearFoodCart(String id) async {
    try {
      CollectionReference cartCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .collection('Cart');
      QuerySnapshot cartSnapshot = await cartCollection.get();

      for (QueryDocumentSnapshot document in cartSnapshot.docs) {
        await document.reference.delete();
      }
    } catch (e) {
      print("Error clearing food cart: $e");
    }
  }


  Future<Stream<QuerySnapshot>> getFoodCart(String id) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Cart")
        .snapshots();
  }

  UpdateUserwallet(String id, String amount) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"Wallet": amount});
  }

  Future<void> sendOrderDetailsToHistory(String id, List<Map<String, dynamic>> orderList) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDocRef = firestore.collection('users').doc(id);

      await userDocRef.update({
        'orderList': orderList,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Order details sent to history successfully");
    } catch (e) {
      print("Error sending order details to history: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getOrderListForAllUsers() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      return usersSnapshot.docs.map((userDoc) {
        return {
          'userId': userDoc.id,
          'orderList': userDoc['orderList'],
        };
      }).toList();
    } catch (e) {
      print("Error fetching order history: $e");
      return [];
    }
  }


  Future<void> removeOrder(String userId, List<Map<String, dynamic>> orderList, List<dynamic> itemsToRemove) async {
    try {
      for (var order in orderList) {
        if (order['orderList'] != null) {
          order['orderList'].removeWhere((item) => itemsToRemove.contains(item));
        }
      }

      List<Map<String, dynamic>> updatedOrderList = orderList.map((order) {
        return {'orderList': order['orderList']};
      }).toList();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'orderList': updatedOrderList.map((order) => order['orderList']).toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Items removed successfully from Firestore');
    } catch (e) {
      print('Error removing items from Firestore: $e');
    }
  }




  Future<void> storeAcceptedOrder(Map<String, dynamic> orderItem) async {
    try {
      await FirebaseFirestore.instance.collection('acceptedOrders').add(orderItem);
    } catch (e) {
      print("Error storing and deleting accepted order: $e");
    }
  }

  Future<void> acceptedOrder(Map<String, dynamic> orderItem) async {
    try {
      orderItem['timestamp'] = FieldValue.serverTimestamp();
      await FirebaseFirestore.instance.collection('accepted').add(orderItem);
    } catch (e) {
      print("Error accepting order: $e");
    }
  }

  Future<void> RejectedOrder(Map<String, dynamic> orderItem) async {
    try {
      orderItem['timestamp'] = FieldValue.serverTimestamp();
      await FirebaseFirestore.instance.collection('rejected').add(orderItem);
    } catch (e) {
      print("Error accepting order: $e");
    }
  }

  Future<void> getDataFromAcceptedOrders() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('accepted').get();

      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> orderData = documentSnapshot.data() as Map<String, dynamic>;

        _acceptedOrdersStreamController.add(orderData);
      }

    } catch (e) {
      print("Error getting data from acceptedOrders: $e");
    }
  }

  final StreamController<Map<String, dynamic>> _acceptedOrdersStreamController = StreamController<Map<String,dynamic>>();

  Stream<Map<String, dynamic>> get acceptedOrdersStream => _acceptedOrdersStreamController.stream;

  Future<void> deleteFoodItem(String itemId) async {

    FirebaseFirestore.instance
        .collection('foodItems')
        .doc(itemId)
        .delete();

  }
}
