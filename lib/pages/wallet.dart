import 'dart:async';
import 'dart:convert';

import 'package:coffee/service/database.dart';
import 'package:coffee/service/shared_preference_helper.dart';
import 'package:coffee/widget/app_constant.dart';
import 'package:coffee/widget/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String? wallet, id;
  int? add;


  getthesharedpref()async{
    wallet= await SharedPreferenceHelper().getWalletUser();
    id= await SharedPreferenceHelper().getIdUser();
    setState(() {

    });
  }

  ontheload()async{
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState(){
    ontheload();
    super.initState();
  }

  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff343456),
      body: wallet==null? const CircularProgressIndicator(): Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.black,
              elevation: 2.0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 20.0, top: 30.0),
                child: Center(
                  child: Text(
                    "Wallet",
                    style: AppWidget.HeadlineTextFeildStyle(),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Image.asset(
                    "images/wallet.png",
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    width: 40.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Wallet",
                        style: AppWidget.Light2TextFeildStyle(),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "Rp. ${wallet!}",
                        style: AppWidget.bold2TextFeildStyle(),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "Add money",
                style: AppWidget.semiboldTextFeildStyle(),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    makePayment('10000');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE9E2E2)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "Rp. " "10000",
                      style: AppWidget.semiboldTextFeildStyle(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    makePayment('50000');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE9E2E2)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "Rp. " "50000",
                      style: AppWidget.semiboldTextFeildStyle(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    makePayment('100000');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE9E2E2)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "Rp. " "100000",
                      style: AppWidget.semiboldTextFeildStyle(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30.0,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: const Color(0xFF067559),borderRadius: BorderRadius.circular(8)),
              child: const Center(
                child: Text(
                  "Add Money",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontFamily: 'Poppins,',
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment(String amount) async{
    try {
      paymentIntent = await createPaymentIntent(amount, 'IDR');
      await Stripe.instance
          .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent!['client_secret'],
        style: ThemeMode.dark,
        merchantDisplayName: 'Helmi'))
          .then((value) {});
      displayPaymentSheet(amount);
    }catch(e, s) {
      print('exception: $e$s');
    }
  }
  displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        int newAmount = int.parse(amount);
        int currentWallet = int.parse(wallet!);

        if (currentWallet + newAmount < 0) {
          showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              content: Text("Insufficient funds"),
            ),
          );
        } else {
          int updatedWallet = currentWallet + newAmount;
          await SharedPreferenceHelper().saveUserWallet(updatedWallet.toString());
          await DatabaseMethods().UpdateUserwallet(id!, updatedWallet.toString());

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
                  )
                ],
              ),
            ),
          );

          await getthesharedpref();
        }
        // ignore: use_build_context_synchronously

        paymentIntent= null;
      }).onError((error, stackTrace) {
        print('Error is:---> $error $stackTrace');
      });
    }on StripeException catch(e){
      print('Error is---> $e');
      showDialog(context: context, builder: (_)=> const AlertDialog(
        content: Text("Cancelled"),
      ));
    }catch (e){
      print('$e');
    }
  }


  createPaymentIntent(String amount, String currency)async{
    try{
      Map<String, dynamic> body={
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response= await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers:  {
          'Authorization': 'Bearer $secretKey',
          'Content-Type':'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);

    }catch(err){
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount){
    final calculatedAmount=(int.parse(amount)*100);

    return calculatedAmount.toString();
  }

}
