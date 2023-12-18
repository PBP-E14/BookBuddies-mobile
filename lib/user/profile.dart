import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../widgets/left_drawer.dart';
import 'models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String _username = '';
  String _email = '';
  TextEditingController _dateController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  String selectedGender = 'Other'; // Default value 'Other' if null

  @override
  void initState() {
    super.initState();
    fetchUserData().then((userData) {
      setState(() {
        _username = userData.fields.username;
        _email = userData.fields.email;
        _dateController.text = formatDateTime(userData.fields.birthDate);
        phoneNumberController.text = userData.fields.phoneNumber ?? '';
        addressController.text = userData.fields.address ?? '';
        bioController.text = userData.fields.bio ?? '';
        selectedGender = userData.fields.gender ?? 'Other'; 
      });
    });
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return ""; 
    }
    return "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }

  Future<User> fetchUserData() async {
    final request = context.read<CookieRequest>(); 
    var responseJson = await request.get(('http://127.0.0.1:8000/user/fetch_user_data/'));

    if (responseJson != null && responseJson['user_data'] != null) {
      // Decode the JSON string inside 'user_data' field
      var userDataJson = json.decode(responseJson['user_data']);

      if (userDataJson.isNotEmpty && userDataJson is List) {
        // Parse the first user object in the list
        var user = User.fromJson(userDataJson.first);
        return user;
      } else {
        throw Exception('User data is empty or invalid');
      }
    } else {
      throw Exception('Failed to load user data');
    }
  }


  Future<void> _selectDate(BuildContext context) async {
      DateTime initialDate = DateTime.now();

      // Attempt to parse the current date from the controller, if available
      try {
        if (_dateController.text.isNotEmpty) {
          List<String> parts = _dateController.text.split('-');
          initialDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      } catch (e) {
        // Handle error or invalid date format
        // You might want to log this error or set a default date
      }

      // Show the date picker dialog
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      // Check if a date was picked and update the controller text
      if (picked != null) {
        setState(() {
          _dateController.text = formatDateTime(picked);
        });
      }
  }

  Future<void> updateProfile(BuildContext context) async {
    final request = context.read<CookieRequest>();

    if (_formKey.currentState!.validate()) {
      // Collect data from the form fields
      var userData = {
        'gender': selectedGender,
        'birth_date': _dateController.text,
        'phone_number': phoneNumberController.text,
        'address': addressController.text,
        'bio': bioController.text,
      };

      // Send data to Django backend using postJson
      final response = await request.postJson(
        'http://127.0.0.1:8000/user/update_profile_flutter/',
        jsonEncode(userData),
      );

      // Handle the response
      if (response['success'] == true) {
        // Handle successful update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully."))
        );
        print("Profile updated successfully.");
      } else {
        // Handle failed update
        String errorMessage = response['error'] ?? 'Unknown error occurred.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $errorMessage"))
        );
        print("Failed to update profile: $errorMessage");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile Page'),
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Profile Picture and Details
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/default_profile_picture.jpeg'),
                ),
              ),
              SizedBox(height: 10),
              Center(child: Text(_username, style: TextStyle(fontSize: 20))),
              SizedBox(height: 5),
              Center(child: Text(_email, style: TextStyle(color: Colors.grey))),
              
              // Profile Form
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    // Gender field
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue ?? 'Other'; // Default to 'Other' if new value is null
                          });
                        },
                        items: <String>['Male', 'Female', 'Other']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Gender',
                        ),
                      ),
                    ),

                    // Birth Date field
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Birth Date',
                          hintText: 'YYYY-MM-DD',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        keyboardType: TextInputType.datetime,
                      ),
                    ),

                    // Phone number field
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: phoneNumberController,
                        decoration: InputDecoration(
                          hintText: "Phone Number",
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number cannot be empty';
                          }
                        },
                      ),
                    ),

                    // Address field
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(
                          hintText: "Address",
                          labelText: 'Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Address cannot be empty';
                          }
                        },
                      ),
                    ),

                    // Bio field
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: bioController,
                        decoration: InputDecoration(
                          hintText: "Bio",
                          labelText: 'Bio',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bio cannot be empty';
                          }
                        },
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Builder(
                        builder: (context) => ElevatedButton(
                          onPressed: () => updateProfile(context),
                          child: Text("Update Profile"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Add more widgets as per your requirement
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
