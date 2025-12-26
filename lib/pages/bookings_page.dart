import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  int _currentStep = 0;
  String? _selectedService;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  final List<Map<String, dynamic>> _services = [
    {
      "name": "Concept Explanation",
      "price": "\$45",
      "duration": "45 mins",
      "icon": Icons.school,
    },
    {
      "name": "Code Review",
      "price": "\$60",
      "duration": "1 hour",
      "icon": Icons.code,
    },
    {
      "name": "Project Planning",
      "price": "\$90",
      "duration": "session",
      "icon": Icons.rocket_launch,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "BOOK A SESSION",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) setState(() => _currentStep += 1);
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep -= 1);
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Row(
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text(
                      "Back",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF137FEC),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                  ),
                  child: Text(
                    _currentStep == 2 ? "Confirm Booking" : "Continue",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            title: const Text("Service"),
            content: _buildServiceSelection(),
          ),
          Step(
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            title: const Text("Schedule"),
            content: _buildScheduler(),
          ),
          Step(
            isActive: _currentStep >= 2,
            title: const Text("Details"),
            content: _buildDetailForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Column(
      children: _services.map((s) {
        bool isSelected = _selectedService == s['name'];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF137FEC)
                  : Colors.white.withAlpha(5),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: Icon(
              s['icon'],
              color: isSelected ? const Color(0xFF137FEC) : Colors.white24,
            ),
            title: Text(
              s['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${s['duration']} • ${s['price']}",
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Color(0xFF137FEC))
                : null,
            onTap: () => setState(() => _selectedService = s['name']),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScheduler() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Date",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 20),
        CalendarDatePicker(
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          onDateChanged: (d) => setState(() => _selectedDate = d),
        ),
        const SizedBox(height: 30),
        const Text(
          "Available Slots",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          children: ["09:00 AM", "10:30 AM", "01:00 PM", "02:30 PM", "04:00 PM"]
              .map((t) {
                bool isSelected = _selectedTime == t;
                return ChoiceChip(
                  label: Text(t),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedTime = t),
                  selectedColor: const Color(0xFF137FEC),
                  backgroundColor: const Color(0xFF161616),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                  ),
                );
              })
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDetailForm() {
    return Column(
      children: [
        _inputField("Full Name", Icons.person, "Jane Doe"),
        const SizedBox(height: 15),
        _inputField("Student Email", Icons.email, "jane@university.edu"),
        const SizedBox(height: 15),
        _inputField(
          "Topic / Notes",
          Icons.description,
          "What do you need help with?",
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _inputField(
    String label,
    IconData icon,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF137FEC)),
            filled: true,
            fillColor: const Color(0xFF161616),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
