import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'AppUser.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

// Ideal time to initialize
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.authStateChanges().listen((User? user) {
                  if (user == null) {
                    print('User is currently signed out!');
                  } else {
                    print('User is signed in!');
                    print(user.uid);
                  }
                });
              },
              child: Text("Get Auth"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: '+911111111111',
                  verificationCompleted: (PhoneAuthCredential credential) {
                    print("verificationCompleted");
                  },
                  verificationFailed: (FirebaseAuthException e) {
                    print("verificationFailed");
                  },
                  codeSent: (String verificationId, int? resendToken) {
                    print("codeSent");
                    print(verificationId);
                    // redirect to otp screen
                  },
                  codeAutoRetrievalTimeout: (String verificationId) {
                    print("codeAutoRetrievalTimeout");
                  },
                );
              },
              child: Text("Login with phone"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: '+911111111111',
                  verificationCompleted:
                      (PhoneAuthCredential credential) async {
                    print("verificationCompleted");
                    await FirebaseAuth.instance
                        .signInWithCredential(credential);
                  },
                  verificationFailed: (FirebaseAuthException e) {
                    print("verificationFailed");
                    print(e.message);
                  },
                  codeSent: (String verificationId, int? resendToken) async {
                    print("codeSent");
                    print(verificationId);
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: "111111");

                    // Sign the user in (or link) with the credential
                    await FirebaseAuth.instance
                        .signInWithCredential(credential);
                  },
                  codeAutoRetrievalTimeout: (String verificationId) {
                    print("codeAutoRetrievalTimeout");
                  },
                );
              },
              child: Text("Verify OTP"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final credential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: "webbrains@gmail.com",
                    password: "qwerty",
                  );
                } on FirebaseAuthException catch (e) {
                  print(e.code);
                  print(e.message);
                  if (e.code == 'weak-password') {
                    print('The password provided is too weak.');
                  } else if (e.code == 'email-already-in-use') {
                    print('The account already exists for that email.');
                  }
                } catch (e) {
                  print(e);
                }
              },
              child: Text("Sign up with email and password"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final credential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: "webbrains@gmail.com",
                    password: "qwerty",
                  );
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    print('No user found for that email.');
                  } else if (e.code == 'wrong-password') {
                    print('Wrong password provided for that user.');
                  }
                }
              },
              child: Text("Sign in with email and password"),
            ),
            TextButton(
              onPressed: () async {
                final GoogleSignInAccount? googleUser =
                    await GoogleSignIn().signIn();

                // Obtain the auth details from the request
                final GoogleSignInAuthentication? googleAuth =
                    await googleUser?.authentication;

                // Create a new credential
                final credential = GoogleAuthProvider.credential(
                  accessToken: googleAuth?.accessToken,
                  idToken: googleAuth?.idToken,
                );

                // Once signed in, return the UserCredential
                await FirebaseAuth.instance.signInWithCredential(credential);
              },
              child: Text("Google Auth"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: Text("Sign out"),
            ),
            TextButton(
              onPressed: () async {
                FirebaseFirestore.instance
                    .collection('users')
                    .add(AppUser(
                      firstName: "abc",
                      lastName: "xyz",
                      age: 12,
                    ).toJson())
                    .then((value) => print("User Added"))
                    .catchError((error) => print("Failed to add user: $error"));
              },
              child: Text("Add user to Cloud Firestore"),
            ),
            TextButton(
              onPressed: () async {
                FirebaseFirestore.instance
                    .collection("users")
                    .get()
                    .then((value) {
                  print(value.docs.length);
                });
              },
              child: Text("Get user to Cloud Firestore"),
            ),
          ],
        ),
      ),
    );
  }
}
