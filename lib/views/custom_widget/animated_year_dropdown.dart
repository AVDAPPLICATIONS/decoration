import 'package:flutter/material.dart';

class AnimatedYearDropdown extends StatefulWidget {
  final String? selectedYear;
  final List<String> years;
  final Function(String?) onChanged;
  final String? hintText;

  const AnimatedYearDropdown({
    super.key,
    required this.selectedYear,
    required this.years,
    required this.onChanged,
    this.hintText,
  });

  @override
  State<AnimatedYearDropdown> createState() => _AnimatedYearDropdownState();
}

class _AnimatedYearDropdownState extends State<AnimatedYearDropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
              if (_isExpanded) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedYear ?? widget.hintText ?? 'Select Year',
                  style: TextStyle(
                    color: widget.selectedYear != null
                        ? Colors.black
                        : Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _animation,
          child: Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              children: widget.years.map((year) {
                return InkWell(
                  onTap: () {
                    widget.onChanged(year);
                    setState(() {
                      _isExpanded = false;
                      _animationController.reverse();
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Text(
                      year,
                      style: TextStyle(
                        color: widget.selectedYear == year
                            ? Colors.blue
                            : Colors.black,
                        fontWeight: widget.selectedYear == year
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
