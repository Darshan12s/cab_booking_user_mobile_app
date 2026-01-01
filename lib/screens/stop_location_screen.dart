// screens/stop_location_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StopLocationScreen extends StatefulWidget {
  final List<String> existingStops;

  const StopLocationScreen({super.key, this.existingStops = const []});

  @override
  State<StopLocationScreen> createState() => _StopLocationScreenState();
}

class _StopLocationScreenState extends State<StopLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedStops = [];

  final List<Map<String, String>> _locations = [
    {
      'name': 'Kuvempu Nagar,Mysore',
      'address': 'Karnataka, India',
      'distance': '20Kms',
    },
    {
      'name': 'Kuvempu Nagar,Mysore',
      'address': 'Karnataka, India',
      'distance': '20Kms',
    },
    {
      'name': 'Kuvempu Nagar,Mysore',
      'address': 'Karnataka, India',
      'distance': '20Kms',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedStops = List.from(widget.existingStops);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark
            ? theme.appBarTheme.backgroundColor
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Choose your stop Location',
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Choose on map button
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(screenWidth * 0.04),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Map selection coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6FCF97),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: Icon(Icons.location_on, size: screenWidth * 0.05),
              label: Text(
                'Choose on map',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Add Stop field with number badge
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.01,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF6FCF97), width: 2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: screenWidth * 0.06,
                  height: screenWidth * 0.06,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '1',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: screenWidth * 0.04,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add Stop',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[500],
                        fontSize: screenWidth * 0.04,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.03,
                      ),
                    ),
                    onChanged: (value) {
                      // TODO: Implement search functionality
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.025),

          // Location suggestions
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (!selectedStops.contains(location['name']!)) {
                        selectedStops.add(location['name']!);
                      }
                    });
                    // Return the updated stops list
                    Navigator.pop(context, selectedStops);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          size: screenWidth * 0.05,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location['name']!,
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.005),
                              Text(
                                location['address']!,
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.035,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          location['distance']!,
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.03,
                            color: isDark ? Colors.white60 : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}