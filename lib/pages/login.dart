import 'package:coffee/admin/home_admin.dart';
import 'package:coffee/pages/bottomnav.dart';
import 'package:coffee/pages/forgotpassword.dart';
import 'package:coffee/pages/signup.dart';
import 'package:coffee/widget/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  @override
  void dispose() {
    useremailcontroller.dispose();
    userpasswordcontroller.dispose();

    super.dispose();
  }

  User? currentUser;
  String email = "", password = "";

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();


  TextEditingController useremailcontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();

  userLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: useremailcontroller.text,
        password: userpasswordcontroller.text,
      );
      User? user = FirebaseAuth.instance.currentUser;
      print('User after login: $user');

      setState(() {
        currentUser = user;
      });

      print(currentUser?.uid);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const BottomNav()));
    }  on FirebaseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'An error occurred while signing in. Please try again.',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
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
                          "Lets Get Started 😁",
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
                              // Center vertically
                              children: [
                                Text(
                                  "Sign up or Sign In to have a full digital experience in our restaurant",
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
                      Form(
                        key: _formkey,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: useremailcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Email';
                                  }
                                  return null;
                                },
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  prefixIcon:
                                      const Icon(Icons.email, color: Colors.white),
                                  // Email icon
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
                                controller: userpasswordcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Password';
                                  }
                                  return null;
                                },
                                style: const TextStyle(color: Colors.white),
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  prefixIcon:
                                      const Icon(Icons.lock, color: Colors.white),
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
                                height: 10.0,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgotPassword()));
                                },
                                child: Container(
                                    alignment: Alignment.topRight,
                                    child: Text("Forgot Password?",
                                        style:
                                            AppWidget.semibold3TextFeildStyle())),
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (_formkey.currentState!.validate()) {
                                    String enteredEmail = useremailcontroller.text;
                                    String enteredPassword = userpasswordcontroller.text;

                                    if (enteredEmail == 'admin' && enteredPassword == 'admin') {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const HomeAdmin(),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        email = enteredEmail;
                                        password = enteredPassword;
                                      });

                                      userLogin();
                                    }
                                  }
                                },
                                child: Material(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: const Color(0xff615793),
                                  child: const SizedBox(
                                    width: 400.0,
                                    height: 50.0,
                                    child: Center(
                                      child: Text(
                                        "Sign In",
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
                              const SizedBox(height: 30.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1.0,
                                      color: Colors.grey,
                                      margin:
                                          const EdgeInsets.symmetric(horizontal: 10.0),
                                    ),
                                  ),
                                  const Text(
                                    "Or",
                                    style: TextStyle(color: Colors.white,fontSize: 20.0,fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1.0,
                                      color: Colors.grey,
                                      margin:
                                          const EdgeInsets.symmetric(horizontal: 10.0),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "No Account?",
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
                                              builder: (context) => const SignUp()));
                                      print("Sign Up tapped!");
                                    },
                                    child: const Text(
                                      "Sign Up",
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
