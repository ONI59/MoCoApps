import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee/pages/details.dart';
import 'package:coffee/service/database.dart';
import 'package:coffee/service/shared_preference_helper.dart';
import 'package:coffee/widget/button.dart';
import 'package:coffee/widget/widget_support.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? name;

  Future<void> getthesharedpref() async {
    name = await SharedPreferenceHelper().getNameUser();
    if (mounted) {
      setState(() {});
    }
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
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Details(
                          detail: ds["Detail"],
                          name: ds["Name"],
                          price: ds["Price"],
                          image: ds["Image"],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ClipPath(
                        clipper: ShapeBezierRightToLeft(),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    ds["Image"],
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 20.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ds["Name"],
                                        style: AppWidget.semibold2TextFeildStyle(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5.0),
                                      Text(
                                        ds["Detail"],
                                        style: AppWidget.Light2TextFeildStyle(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5.0),
                                      Text(
                                        "Rp." + ds["Price"],
                                        style: AppWidget.semibold2TextFeildStyle(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ClipPath(
                        clipper: ShapeBezierLeftToRight(),
                        child: Container(
                          color: Colors.transparent,
                          height: 20,
                        ),
                      ),
                    ],
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

  Widget allItems() {
    return StreamBuilder(
        stream: fooditemStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Details(detail: ds["Detail"],
                                  name: ds["Name"],
                                  price: ds["Price"],
                                  image: ds["Image"],)));
                  },
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  ds["Image"],
                                  height: 150,
                                  width: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                ds["Name"].length > 10
                                    ? ds["Name"].substring(0, 10) + '...'
                                    : ds["Name"],
                                style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'Poppins'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                ds["Detail"],
                                style: AppWidget.Light2TextFeildStyle(),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                "Rp. " + ds["Price"],
                                style: AppWidget.semibold2TextFeildStyle(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
          } else {
            return const Center(
            child: CircularProgressIndicator(),
          );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff343456),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Hello, ${name ?? "Guest"}", style: AppWidget.boldTextFeildStyle()),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Text("Makanan Lezat dan Enak",
                    style: AppWidget.HeadlineTextFeildStyle()),
                Text("Ayo pilih sekarang!",
                    style: AppWidget.LightTextFeildStyle()),
                const SizedBox(
                  height: 20.0,
                ),
                showItem(),
                const SizedBox(
                  height: 30.0,
                ),
                SizedBox(
                    height: 280,
                    child: allItems()),
                const SizedBox(
                  height: 20.0,
                ),
                const SizedBox(height: 30.0,),
                allItemsVertically(),
              ],
            ),
          ),
        )
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
