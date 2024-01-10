import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../service/database.dart';
import '../service/shared_preference_helper.dart';
import '../widget/widget_support.dart';

class AfterAdd extends StatefulWidget {
  const AfterAdd({super.key});

  @override
  State<AfterAdd> createState() => _AfterAddState();
}

class _AfterAddState extends State<AfterAdd> {

  late String selectedCategory;

  void onCategoryChanged(String value) {
    setState(() {
      selectedCategory = value;
    });
  }

  final List<String> items = ['Cake', 'Food', 'Drink'];
  String? value;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();
  final ImagePicker _picker= ImagePicker();
  File? selectedImage;

  Future getImage() async {
    try {
      var image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        selectedImage = File(image.path);
        setState(() {
        });
      } else {
        print('Image selection canceled.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }


  updateItem(String docId) async {
    if (selectedImage != null && namecontroller.text.isNotEmpty && pricecontroller.text.isNotEmpty && detailcontroller.text.isNotEmpty) {
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child("blogImages").child(docId);

      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

      var downloadUrl = await (await task).ref.getDownloadURL();
      Map<String, dynamic> updatedItem = {
        "Image": downloadUrl,
        "Name": namecontroller.text,
        "Price": pricecontroller.text,
        "Detail": detailcontroller.text,
      };

      try {
        await DatabaseMethods().updateFoodItem(docId, updatedItem, value!);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Food Item has been updated Successfully",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Failed to update Food Item",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ));
        print("Error updating food item: $e");
      }
    }
  }

  String? name;

  Future<void> getthesharedpref() async {
    name = await SharedPreferenceHelper().getNameUser();
    if (mounted) {
      setState(() {});
    }
  }
  void deleteFoodItem(String docId) {
    FirebaseFirestore.instance.collection('Food').doc(docId).delete();
    FirebaseFirestore.instance.collection('Drink').doc(docId).delete();
    FirebaseFirestore.instance.collection('Cake').doc(docId).delete();
  }


  bool cake = false,
      food = false,
      drink = false;

  Stream? fooditemStream;

  ontheload() async {
    await getthesharedpref();
    fooditemStream = await DatabaseMethods().getFoodItem("Cake");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  Widget allItemsVertically() {
    return StreamBuilder(
      stream: fooditemStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data.docs.isNotEmpty) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: List.generate(snapshot.data.docs.length, (index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                return Container(
                  margin: const EdgeInsets.only(right: 10.0, bottom: 30.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              ds["Image"],
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: Text(
                                  ds["Name"],
                                  style: AppWidget.semibold2TextFeildStyle(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: Text(
                                  ds["Detail"],
                                  style: AppWidget.Light2TextFeildStyle(),
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: Text(
                                  "Rp." + ds["Price"],
                                  style: AppWidget.semibold2TextFeildStyle(),
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red,),
                                    onPressed: () {
                                      deleteFoodItem(ds.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showEditPopup(ds);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }


  void _showEditPopup(DocumentSnapshot ds) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown,
          title: Text(
            "Edit Item",
            style: AppWidget.HeadlineTextFeildStyle(),
          ),
          content: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 20.0, bottom: 70.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Update the Item Picture",
                    style: AppWidget.semiboldTextFeildStyle(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  selectedImage == null
                      ? GestureDetector(
                    onTap: () {
                      getImage();
                    },
                    child: Center(
                      child: Material(
                        color: Colors.white,
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  )
                      : Center(
                    child: Material(
                      color: Colors.white,
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    "Update Item Name",
                    style: AppWidget.semiboldTextFeildStyle(),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: const Color(0xFFececf8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: namecontroller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Item Name",
                        hintStyle: AppWidget.Light2TextFeildStyle(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    "Update Item Price",
                    style: AppWidget.semiboldTextFeildStyle(),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: const Color(0xFFececf8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: pricecontroller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Item Price",
                        hintStyle: AppWidget.Light2TextFeildStyle(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    "Update Item Detail",
                    style: AppWidget.semiboldTextFeildStyle(),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: const Color(0xFFececf8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      maxLines: 6,
                      controller: detailcontroller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Item Detail",
                        hintStyle: AppWidget.Light2TextFeildStyle(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    "Select Category",
                    style: AppWidget.semiboldTextFeildStyle(),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: const Color(0xFFececf8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      items: items
                          .map(
                            (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (newValue) {
                        print("Previous value: $value");
                        print("New value: $newValue");
                        setState(() {
                          value = newValue;
                        });
                      },
                      dropdownColor: Colors.white,
                      hint: const Text(
                        "Select Category",
                        style: TextStyle(color: Colors.black),
                      ),
                      iconSize: 36,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                      ),
                      value: value,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                if (namecontroller.text.isEmpty ||
                    pricecontroller.text.isEmpty ||
                    detailcontroller.text.isEmpty ||
                    selectedImage == null ||
                    value == null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Incomplete Information"),
                        content: const Text("Please fill in all fields before updating."),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AlertDialog(
                        backgroundColor: Colors.transparent,
                        content: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Updating Item...",
                              style: TextStyle(color: Colors.white, fontSize: 18.0),
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  await updateItem(ds.id);

                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  namecontroller.clear();
                  pricecontroller.clear();
                  detailcontroller.clear();
                  selectedImage = null;
                  setState(() {
                    value = null;
                  });
                }
              },
              child: Text(
                "Update",
                style: AppWidget.semibold2TextFeildStyle(),
              ),
            ),
            TextButton(
              onPressed: () {
                namecontroller.clear();
                pricecontroller.clear();
                detailcontroller.clear();
                selectedImage = null;
                setState(() {
                  value = null;
                });

                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: AppWidget.semiboldTextFeildStyle(),
              ),
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Edit Menu",
          style: AppWidget.HeadlineTextFeildStyle(),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30.0),

              showItem(),
              const SizedBox(height: 70.0),

              allItemsVertically(),
            ],
          ),
        ),
      ),
    );
  }
  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            cake = true;
            food = false;
            drink = false;
            fooditemStream = await DatabaseMethods().getFoodItem("Cake");
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                  color: cake ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "images/cake.png",
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                color: cake ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            cake = false;
            food = true;
            drink = false;
            fooditemStream = await DatabaseMethods().getFoodItem("Food");
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                  color: food ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "images/food.png",
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                color: food ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            cake = false;
            food = false;
            drink = true;
            fooditemStream = await DatabaseMethods().getFoodItem("Drink");
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                  color: drink ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "images/drink.png",
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                color: drink ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

