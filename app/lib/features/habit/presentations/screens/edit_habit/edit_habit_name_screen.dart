import 'package:flutter/material.dart';

class EditHabitNameScreen extends StatefulWidget {
  final String habitId;
  const EditHabitNameScreen({super.key, required this.habitId});

  @override
  State<EditHabitNameScreen> createState() => _EditHabitNameScreenState();
}

class _EditHabitNameScreenState extends State<EditHabitNameScreen> {
  late final TextEditingController _nameController;
  bool _isPositiveHabit = true; // true for 'build', false for 'break'

  final List<String> _positiveHabitSuggestions = [
    'Read for 15 minutes',
    'Meditate for 10 mins',
    'Go for a run',
    'Drink 8 glasses of water',
    'Journal daily',
    'Wake up early',
    'No screen time before bed',
    'Practice gratitude',
  ];

  final List<String> _negativeHabitSuggestions = [
    'Stop smoking',
    'No junk food',
    'Quit social media',
    'Stop biting nails',
    'No sugary drinks',
    'Avoid procrastination',
    'No complaining',
    'Limit caffeine',
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Fetch initial values from habit using widget.habitId
    _nameController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Habit'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement save logic with _nameController.text and _isPositiveHabit
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What's the habit?",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Give your new habit a name. Be specific!",
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'e.g., Read for 15 minutes',
                border: OutlineInputBorder(),
              ),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Text(
              "What's the goal?",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _HabitTypeSelector(
                    title: 'Build a Habit',
                    subtitle: 'I want to start doing this.',
                    icon: Icons.add_circle_outline,
                    isSelected: _isPositiveHabit,
                    onTap: () => setState(() => _isPositiveHabit = true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _HabitTypeSelector(
                    title: 'Break a Habit',
                    subtitle: 'I want to stop doing this.',
                    icon: Icons.remove_circle_outline,
                    isSelected: !_isPositiveHabit,
                    onTap: () => setState(() => _isPositiveHabit = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildHabitSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitSuggestions() {
    final theme = Theme.of(context);
    final suggestions = _isPositiveHabit
        ? _positiveHabitSuggestions
        : _negativeHabitSuggestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Or get inspired",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Pick from our popular suggestions to get started quickly.",
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          runSpacing: 10.0,
          children: suggestions.map((habit) {
            return Material(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _nameController.text = habit;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    habit,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _HabitTypeSelector extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _HabitTypeSelector({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : Colors.grey.shade400;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.05)
              : Colors.grey.shade100,
          border: Border.all(
            color:
                isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.colorScheme.primary : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.8)
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
