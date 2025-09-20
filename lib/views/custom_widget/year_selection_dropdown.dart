import 'package:flutter/material.dart';

class YearSelectionDropdown extends StatelessWidget {
  final String? selectedYear;
  final List<String> years;
  final Function(String?) onChanged;

  const YearSelectionDropdown({
    super.key,
    required this.selectedYear,
    required this.years,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedYear,
      decoration: const InputDecoration(
        labelText: 'Select Year',
        border: OutlineInputBorder(),
      ),
      items: years.map((year) {
        return DropdownMenuItem<String>(
          value: year,
          child: Text(year),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
