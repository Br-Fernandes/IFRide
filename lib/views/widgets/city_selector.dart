import 'package:flutter/material.dart';

import 'package:if_ride/utils/cities.dart';

class CitySelector extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final void Function(String?) onChanged;

  const CitySelector({
    super.key, 
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = MediaQuery.of(context).size.height * 0.05;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing),
          DropdownButtonFormField<String>(
            icon: const Icon(Icons.search_sharp),
            decoration: InputDecoration(
              labelText: hint,
              labelStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            value: value,
            items: cities.map((city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
