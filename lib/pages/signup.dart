import 'package:coffee/pages/login.dart';
import 'package:coffee/service/database.dart';
import 'package:coffee/service/shared_preference_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import '../widget/widget_support.dart';
import 'package:coffee/pages/bottomnav.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";

  TextEditingController namecontroller = TextEditingController();

  TextEditingController passwordcontroller = TextEditingController();

  TextEditingController emailcontroller = TextEditingController();

  final _formkey= GlobalKey<FormState>();

  registration() async {
    if (_formkey.currentState?.validate() ?? false) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailcontroller.text,
          password: passwordcontroller.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Registered Successfully",
            style: TextStyle(fontSize: 20.0),
          ),
        ));

        String uid = randomAlphaNumeric(10);
        Map<String, dynamic> addUserInfo = {
          "Name": namecontroller.text,
          "Email": emailcontroller.text,
          "Wallet": "0",
          "Id": uid,
        };

        await SharedPreferenceHelper().clearAllPreferences();
        await DatabaseMethods().addUserDetail(addUserInfo, uid);
        await SharedPreferenceHelper().saveUserName(namecontroller.text);
        await SharedPreferenceHelper().saveUserEmail(emailcontroller.text);
        await SharedPreferenceHelper().saveUserUId(uid);
        await SharedPreferenceHelper().saveUserWallet('0');

        print('id saat daftar: ${await SharedPreferenceHelper().getIdUser()}');
        print('nama saat daftar: ${await SharedPreferenceHelper().getNameUser()}');
        print('email saat daftar: ${await SharedPreferenceHelper().getEmailUser()}');


        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BottomNav()));
      } on FirebaseAuthException catch (e) {
        print('Firebase Auth Exception: $e');

        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Email already exists. Please use a different email.",
              style: TextStyle(fontSize: 18.0, fontFamily: 'Poppins'),
            ),
          ));
        } else if (e.code == 'network-request-failed') {
          print('Network request failed: Check internet connection.');
        } else {
          print('Error signing up: ${e.message}');
        }
      } catch (error) {
        print('Unexpected error: $error');
      }
    }
  }

  @override
  void dispose() {
    namecontroller.dispose();
    passwordcontroller.dispose();
    emailcontroller.dispose();
    super.dispose();
  }


  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff343456),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 60.0),
                child: Container(
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          "Lets Sign Up",
                          style: AppWidget.semiboldTextFeildStyle(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Sign up to have a full digital experience in our restaurant",
                                  style: AppWidget.semibold3TextFeildStyle(),
                                  textAlign: TextAlign
                                      .center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: namecontroller,
                                validator: (value){
                                  if(value==null|| value.isEmpty){
                                    return 'Please Enter Name';
                                  }
                                  return null;
                                },
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Name',
                                  hintStyle: const TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 20.0),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: emailcontroller,
                                validator: (value){
                                  if(value==null|| value.isEmpty){
                                    return 'Please Enter Email';
                                  }
                                  return null;
                                },
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: const TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 20.0),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: passwordcontroller,
                                validator: (value){
                                  if(value==null|| value.isEmpty){
                                    return 'Please Enter Password';
                                  }
                                  return null;
                                },
                                style: const TextStyle(color: Colors.white),
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: const TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 20.0),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (_formkey.currentState!.validate()) {
                                    setState(() {
                                      email = emailcontroller.text;
                                      name = namecontroller.text;
                                      password = passwordcontroller.text;
                                    });
                                  }
                                  registration();
                                },
                                child: SizedBox(
                                  height: 50.0,
                                  width: 400.0,
                                  child: Material(
                                    color: const Color(0xff615793),
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: const Center(
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Already have an account?",
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14.0,
                                        fontFamily: 'Poppins'),
                                  ),
                                  const SizedBox(width: 5.0),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const Login()));
                                      print("Sign In tapped!");
                                    },
                                    child: const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontFamily: 'Poppins',
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
