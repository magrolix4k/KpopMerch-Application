import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  DateTime? _selectedDate;

  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    // Uint8List imageBytes = await _selectedImage!.readAsBytes();
    // String base64String = base64Encode(imageBytes);

    final String formattedDate = DateFormat('yyyy-MM-dd').format(
        _selectedDate!);
    if (_selectedImage != null) {
      List<int> imageBytes = await _selectedImage!.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      final Map<String, dynamic> requestData = {
        'u_name': username,
        'u_email': email,
        'u_password': password,
        'u_birthday': formattedDate,
        'u_image': base64Image,
      };

      final response = await http.post(
        Uri.parse(
            'https://kpopmerch.comsciproject.net/db_connect/db_register.php'),
        body: requestData,
      );
      final responseData = json.decode(response.body);
      if (responseData == "Success") {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('email', _emailController.text.trim());
        setState(() {
          _errorMessage = "Registration successful";
        });
        Navigator.of(context).popAndPushNamed('/login');
      } else {
        if (responseData == 'User already exists') {
          setState(() {
            _errorMessage = "This email is already registered";
          });
        } else {
          setState(() {
            _errorMessage = responseData;
          });
        }
      }
    }
  }

  Future<void> _selectImage() async {
    final pickedImage =
    await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Widget _buildSelectedImage() {
    if (_selectedImage != null) {
      return Image.file(_selectedImage!);
    } else {
      return Text('No Image Selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              GestureDetector(
                onTap: _selectImage,
                child: _buildSelectedImage(),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _birthdayController,
                decoration: const InputDecoration(labelText: 'Birthday'),
                onTap: _selectDate,
                readOnly: true,
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Please select your birthday';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _register,
                child: Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
