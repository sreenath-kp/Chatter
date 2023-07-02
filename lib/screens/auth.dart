import 'dart:io';

import 'package:chatapp/widgets/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var isLogin = true;

  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;

  // check for image select status and show error
  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!isLogin && _selectedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image not selected'),
        ),
      );
    }
    _formKey.currentState!.save();
    try {
      if (isLogin) {
        // Login
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        if (kDebugMode) {
          print(userCredentials);
        }
      } else {
        // Sign up
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        if (_selectedImage != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('User_images')
              .child('${userCredentials.user!.uid}.jpeg');
          await storageRef.putFile(_selectedImage!);
          final imageUrl = await storageRef.getDownloadURL();
          print(imageUrl);
        }
        if (kDebugMode) {
          print(userCredentials);
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication Failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/result.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isLogin)
                          UserImagePicker(
                            onPickImage: (pickedImage) {
                              _selectedImage = pickedImage;
                            },
                          ),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredEmail = newValue!;
                          },
                        ),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password must be atleast 6 characters long';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredPassword = newValue!;
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Text(isLogin ? 'Login' : 'Sign Up'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                          child: Text(isLogin
                              ? 'Create an account'
                              : 'Already have an account. Login'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
