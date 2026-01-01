// screens/my_Trip/feedback_page.dart
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/faq_option_tile.dart';
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/gradient_button.dart';
import 'package:flutter/material.dart';
import 'add_feedback_page.dart';

// Define custom colors for consistency with the design
// ignore: unused_element
const Color _primaryGreen = Color(0xFF34A853);

class IssueChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const IssueChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDark ? Colors.white : _primaryGreen),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // List of common FAQ options
  late final List<FeedbackItem> faqOptions;

  // Gradient for buttons
  static const LinearGradient _buttonGradient = LinearGradient(
    colors: [Color(0xFF34A853), Color(0xFF2E7D4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    faqOptions = <FeedbackItem>[
      const FeedbackItem(title: "The Rider is not picking the Call"),
      const FeedbackItem(title: "Have problem with Starting the Ride"),
      const FeedbackItem(title: "Payment Problem?"),
      const FeedbackItem(title: "Booking an Outstation Trip"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context); // Implement actual back navigation
          },
        ),
        title: Text(
          'Report an Issue',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Booking ID: #1243556',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
              ),
            ),
          ),
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Feedback section header
              Text(
                'Feedback',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // My Feedbacks and App Logs buttons (stacked vertically)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    // Wrapped in SizedBox to control width
                    width: 320, // Reduced width
                    child: GradientButton(
                      gradient: _buttonGradient,
                      onPressed: () {
                        // Handle My Feedbacks
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('My Feedbacks clicked!'),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.chat_bubble_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'My Feedbacks',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Vertical space between buttons
                  SizedBox(
                    // Wrapped in SizedBox to control width
                    width: 320, // Reduced width
                    child: GradientButton(
                      gradient: _buttonGradient,
                      onPressed: () {
                        // Handle App Logs
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('App Logs clicked!')),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.description_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'App Logs',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30), // More space before FAQ
              // FAQ section header
              Text(
                'FAQ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // List of FAQ options
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: faqOptions.length,
                separatorBuilder: (BuildContext context, int index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark ? Colors.grey[800] : Colors.grey,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return FAQOptionTile(
                    item: faqOptions[index],
                    onTap: () {
                      // Handle FAQ option selection
                      _showFAQDialog(faqOptions[index].title);
                    },
                  );
                },
              ),

              const SizedBox(height: 30),

              // Add your own feedback button
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  gradient: _buttonGradient,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            const AddFeedbackPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Add your own Feedback',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show dialog when an FAQ option is selected
  void _showFAQDialog(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Text(
          title,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          'This is a frequently asked question. A detailed answer would appear here.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: isDark ? Colors.white : _primaryGreen),
            ),
          ),
        ],
      ),
    );
  }
}
