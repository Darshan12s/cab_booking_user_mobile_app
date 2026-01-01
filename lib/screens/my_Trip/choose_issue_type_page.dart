// screens/my_Trip/choose_issue_type_page.dart
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/gradient_button.dart';
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/issue_chip.dart';
import 'package:flutter/material.dart';

// Define custom colors for consistency with the design

class ChooseIssueTypePage extends StatefulWidget {
  final ValueChanged<String> onIssueTypeSelected;

  const ChooseIssueTypePage({super.key, required this.onIssueTypeSelected});

  static const Map<String, List<String>> issueCategories = {
    'User issue': [
      'Profile & Account',
      'Booking & Ride',
      'Payment & Wallet',
      'Safety & Security',
      'App Performance',
    ],
    'Driver issue': [
      'Driver Behavior',
      'Driver Navigation',
      'Driver Vehicle',
      'Driver Pickup/Drop-off',
    ],
    'Car issue': [
      'Vehicle Cleanliness',
      'Vehicle Condition',
      'AC/Heating',
      'Seat Belts',
    ],
    'Other issue': [
      'General Feedback',
      'Suggest New Feature',
      'Technical Support',
      'Lost Item',
    ],
  };

  @override
  State<ChooseIssueTypePage> createState() => _ChooseIssueTypePageState();
}

class _ChooseIssueTypePageState extends State<ChooseIssueTypePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _manualIssueController = TextEditingController();
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _manualIssueController.addListener(_onManualIssueChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _currentSearchQuery = _searchController.text.toLowerCase();
    });
  }

  void _onManualIssueChanged() {
    setState(() {
      // Rebuild to update button enabled state
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _manualIssueController.removeListener(_onManualIssueChanged);
    _manualIssueController.dispose();
    super.dispose();
  }

  // Filter issues based on search query
  Map<String, List<String>> _getFilteredIssues() {
    if (_currentSearchQuery.isEmpty) {
      return ChooseIssueTypePage.issueCategories;
    }

    final Map<String, List<String>> filtered = <String, List<String>>{};
    ChooseIssueTypePage.issueCategories.forEach((
      String category,
      List<String> issues,
    ) {
      final List<String> matchingIssues = issues
          .where(
            (String issue) => issue.toLowerCase().contains(_currentSearchQuery),
          )
          .toList();

      final bool categoryNameMatches = category.toLowerCase().contains(
        _currentSearchQuery,
      );

      if (categoryNameMatches || matchingIssues.isNotEmpty) {
        if (categoryNameMatches && matchingIssues.isEmpty) {
          filtered[category] = List<String>.from(issues);
        } else if (matchingIssues.isNotEmpty) {
          filtered[category] = matchingIssues;
        }
      }
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final LinearGradient buttonGradient = const LinearGradient(
      colors: <Color>[Color(0xFF6DC476), Color(0xFF388E3C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final Map<String, List<String>> filteredIssues = _getFilteredIssues();
    final bool isManualIssueButtonEnabled = _manualIssueController.text
        .trim()
        .isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Report an Issue',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Choose the type of Issue',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                fillColor: Colors.grey[50],
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Issue Categories
            if (filteredIssues.isEmpty && _currentSearchQuery.isNotEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No matching issues found.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              ...filteredIssues.entries.map<Widget>((
                MapEntry<String, List<String>> entry,
              ) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0, // horizontal spacing
                      runSpacing: 8.0, // vertical spacing
                      children: entry.value.map<Widget>((String issue) {
                        return IssueChip(
                          label: issue,
                          onTap: () {
                            widget.onIssueTypeSelected(issue);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }).toList(),
            const Text(
              'Type your issue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _manualIssueController,
              decoration: InputDecoration(
                hintText: 'Enter the issue manually',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                fillColor: Colors.grey[50],
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button for manual issue (conditionally enabled)
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                gradient: buttonGradient,
                onPressed: isManualIssueButtonEnabled
                    ? () {
                        widget.onIssueTypeSelected(
                          _manualIssueController.text.trim(),
                        );
                        Navigator.pop(context);
                      }
                    : null, // Disable button if manual text is empty
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}