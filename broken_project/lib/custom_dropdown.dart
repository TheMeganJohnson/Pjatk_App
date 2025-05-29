// filepath: /c:/Users/coret/Documents/Flutter/pjatk_app/lib/custom_dropdown.dart
import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({super.key, 
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  void _showDropdownMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // Set the desired height for the dropdown menu
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(widget.items[index]),
                  onTap: () {
                    widget.onChanged(widget.items[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDropdownMenu,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.value),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
