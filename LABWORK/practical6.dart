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
      title: 'Icons Images Charts',
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Icons, Images & Charts'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // HEADER ICON
            const Icon(
              Icons.dashboard,
              size: 70,
              color: Colors.blue,
            ),

            const SizedBox(height: 10),

            const Text(
              'Student Dashboard',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(15),

              child: Image.network(
                'https://picsum.photos/600/250',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Performance Chart',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // SIMPLE BAR CHART
            SizedBox(
              height: 250,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                crossAxisAlignment: CrossAxisAlignment.end,

                children: [

                  buildBar(
                    'Math',
                    150,
                    Colors.blue,
                  ),

                  buildBar(
                    'AI',
                    200,
                    Colors.green,
                  ),

                  buildBar(
                    'Flutter',
                    175,
                    Colors.orange,
                  ),

                  buildBar(
                    'DBMS',
                    125,
                    Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ICON ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: const [

                Column(
                  children: [
                    Icon(
                      Icons.school,
                      size: 40,
                      color: Colors.blue,
                    ),
                    Text('Study'),
                  ],
                ),

                Column(
                  children: [
                    Icon(
                      Icons.code,
                      size: 40,
                      color: Colors.green,
                    ),
                    Text('Coding'),
                  ],
                ),

                Column(
                  children: [
                    Icon(
                      Icons.star,
                      size: 40,
                      color: Colors.orange,
                    ),
                    Text('Score'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to create chart bars
  static Widget buildBar(
    String label,
    double height,
    Color color,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,

      children: [

        Container(
          width: 45,
          height: height,

          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(label),
      ],
    );
  }
}