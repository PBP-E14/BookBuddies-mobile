import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile Page'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Profile Picture and Details
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('path/to/image.jpg'), // Replace with your image path
                ),
              ),
              SizedBox(height: 10),
              Center(child: Text('Username', style: TextStyle(fontSize: 20))),
              SizedBox(height: 5),
              Center(child: Text('email@example.com', style: TextStyle(color: Colors.grey))),
              
              // Profile Form
              Form(
                // Add a GlobalKey<FormState> to manage the form state
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      // Add other properties and validators
                    ),
                    // Add other form fields
                    ElevatedButton(
                      onPressed: () {
                        // Handle form submission
                      },
                      child: Text('Update Profile'),
                    )
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
}
