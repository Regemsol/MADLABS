import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Interactive Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FormPage(),
    );
  }
}

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {

  final _formKey = GlobalKey<FormState>();

  String? selectedCourse;
  bool agree = false;

  void submitForm() {
    if (_formKey.currentState!.validate()) {

      if (!agree) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the terms and conditions.'),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form submitted successfully!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Form'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            child: Column(
              children: [

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  keyboardType: TextInputType.emailAddress,

                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  obscureText: true,

                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),

                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must have 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Course',
                    border: OutlineInputBorder(),
                  ),

                  value: selectedCourse,

                  items: const [
                    DropdownMenuItem(
                      value: 'Computer Science',
                      child: Text('Computer Science'),
                    ),
                    DropdownMenuItem(
                      value: 'Information Technology',
                      child: Text('Information Technology'),
                    ),
                    DropdownMenuItem(
                      value: 'Artificial Intelligence',
                      child: Text('Artificial Intelligence'),
                    ),
                  ],

                  onChanged: (value) {
                    setState(() {
                      selectedCourse = value;
                    });
                  },

                  validator: (value) {
                    if (value == null) {
                      return 'Please select a course';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                CheckboxListTile(
                  title: const Text('I agree to the terms and conditions'),

                  value: agree,

                  onChanged: (value) {
                    setState(() {
                      agree = value ?? false;
                    });
                  },
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}