import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newapp/services/auth_service.dart';
import 'package:newapp/services/location_service.dart';
import 'package:newapp/theme/theme_data.dart';
import 'package:newapp/widgets/const_sizedbox.dart';
import 'package:newapp/widgets/custom_button.dart';
import 'package:newapp/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final LocationService _locationService = LocationService();
  bool _useCurrentLocation = false;
  List<String> _suggestions = ['Current Location', 'Enter Manually'];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> _uploadProfileImage(String userId) async {
    if (_profileImage == null) return null;
    Reference storageReference =
        FirebaseStorage.instance.ref().child('user_profiles/$userId.jpg');
    UploadTask uploadTask = storageReference.putFile(_profileImage!);
    await uploadTask.whenComplete(() => null);
    return await storageReference.getDownloadURL();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      setState(() {
        _addressController.text = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      print(e);
    }
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl = _profileImage != null
            ? await _uploadProfileImage('unique_user_id')
            : null;
        if (_profileImage != null) {
          await Provider.of<AuthService>(context, listen: false).signUp(
            email: _emailController.text,
            password: _passwordController.text,
            username: _usernameController.text,
            mobileNumber: _mobileNumberController.text,
            address: _addressController.text,
            profileImageUrl: imageUrl!,
          );
          imageUrl = await _uploadProfileImage('unique_user_id');
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme myColorScheme = themeData.colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: myColorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Satmat Signup",
          style: themeData.textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              obscureText: false,
              controller: _emailController,
              labelText: "Email",
            ),
            const MidSizedBoxHeight(),
            CustomTextField(
              obscureText: false,
              controller: _usernameController,
              labelText: "User Name",
              textInputType: TextInputType.emailAddress,
            ),
            const MidSizedBoxHeight(),
            CustomTextField(
              obscureText: false,
              controller: _mobileNumberController,
              labelText: "Mobile Number",
              textInputType: TextInputType.phone,
            ),
            const MidSizedBoxHeight(),
            TypeAheadField<String>(
                controller: _addressController,
                suggestionsCallback: (String search) async {
                  return _suggestions
                      .where((suggestion) => suggestion
                          .toLowerCase()
                          .contains(search.toLowerCase()))
                      .toList();
                },
                itemBuilder: (BuildContext context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSelected: (String suggestion) {
                  if (suggestion == 'Current Location') {
                    _getCurrentLocation();
                  } else {
                    _addressController.text = suggestion;
                  }
                }),
            const MidSizedBoxHeight(),
            CustomTextField(
              obscureText: true,
              controller: _passwordController,
              labelText: "Password",
            ),
            const LargeSizedBoxHeight(),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Profile Image'),
            ),
            const LargeSizedBoxHeight(),
            CustomButton(
              onPressed: _signup,
              myColorScheme: myColorScheme,
              buttonText: const Text("Signup"),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account?",
                ),
                TextButton(
                  style: const ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(Colors.green),
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.all(0),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
