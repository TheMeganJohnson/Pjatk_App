import 'package:flutter/material.dart';
import 'main.dart';

class ReportPage extends StatelessWidget {
  ReportPage({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController severityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Report',
      leftButtonAction: () {
        Navigator.pop(context);
      },
      leftButtonIcon: Icons.arrow_back,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bug Title',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Impact Severity',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ['Minor', 'Major', 'Critical']
                  .map((severity) => DropdownMenuItem<String>(
                        value: severity,
                        child: Text(severity),
                      ))
                  .toList(),
              onChanged: (value) {
                severityController.text = value!;
              },
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFED1C24), // Button color
                ),
                child: Text(
                  'Wyślij',
                  style: TextStyle(color: Colors.white), // Text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
