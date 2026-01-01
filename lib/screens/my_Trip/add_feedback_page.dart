// screens/my_Trip/add_feedback_page.dart
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'choose_issue_type_page.dart';
import 'feedback_success_page.dart';
import '../../utils/file_utils.dart';

class AddFeedbackPage extends StatefulWidget {
  const AddFeedbackPage({super.key});

  @override
  State<AddFeedbackPage> createState() => _AddFeedbackPageState();
}

class _AddFeedbackPageState extends State<AddFeedbackPage> {
  String _selectedOption = FeedbackOption.issue;
  final TextEditingController _issueDescriptionController =
      TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  String? _selectedIssueType;
  final LinearGradient _buttonGradient = const LinearGradient(
    colors: <Color>[Color(0xFF6DC476), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  List<File> _selectedMedia = [];

  @override
  void dispose() {
    _issueDescriptionController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final option = await showModalBottomSheet<MediaOption>(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: isDark ? Colors.white : Colors.black,
                ),
                title: Text(
                  'Gallery',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () => Navigator.pop(context, MediaOption.gallery),
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: isDark ? Colors.white : Colors.black,
                ),
                title: Text(
                  'Camera',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () => Navigator.pop(context, MediaOption.camera),
              ),
              ListTile(
                leading: Icon(
                  Icons.video_library,
                  color: isDark ? Colors.white : Colors.black,
                ),
                title: Text(
                  'Video',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () => Navigator.pop(context, MediaOption.video),
              ),
            ],
          ),
        );
      },
    );

    if (option == null) return;

    try {
      XFile? pickedFile;
      switch (option) {
        case MediaOption.gallery:
          pickedFile = await picker.pickImage(source: ImageSource.gallery);
          break;
        case MediaOption.camera:
          pickedFile = await picker.pickImage(source: ImageSource.camera);
          break;
        case MediaOption.video:
          pickedFile = await picker.pickVideo(source: ImageSource.gallery);
          break;
      }

      if (pickedFile != null) {
        setState(() {
          _selectedMedia.add(File(pickedFile!.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick media: ${e.toString()}')),
      );
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  void _submitFeedback() {
    debugPrint('Feedback Type: $_selectedOption');
    debugPrint('Description: ${_issueDescriptionController.text}');
    debugPrint('Contact Info: ${_contactInfoController.text}');
    debugPrint('Issue Type: $_selectedIssueType');
    debugPrint('Media files: ${_selectedMedia.length}');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const FeedbackSuccessPage(),
      ),
    );
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
            Navigator.pop(context);
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Feedback',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Report any issue that you are facing.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      'Issue',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    value: FeedbackOption.issue,
                    groupValue: _selectedOption,
                    onChanged: (String? option) {
                      if (option != null) {
                        setState(() {
                          _selectedOption = option;
                        });
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      'Suggestions',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    value: FeedbackOption.suggestion,
                    groupValue: _selectedOption,
                    onChanged: (String? option) {
                      if (option != null) {
                        setState(() {
                          _selectedOption = option;
                        });
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Describe the issue you\'ve encountered',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Describe your issue in few words.\n'
                    '2. Upload appropriate proofs(eg: Images, Screenshots or video clip).\n'
                    '3. Give any additional information about your issue that might help us fix the issue.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _issueDescriptionController,
                    maxLines: 5,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type your feedback here...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey[600]! : Colors.grey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey[600]! : Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      alignLabelWithHint: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selected media preview
                  if (_selectedMedia.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedMedia.length,
                        itemBuilder: (context, index) {
                          final file = _selectedMedia[index];
                          final isImage =
                              file.path.toLowerCase().endsWith('.jpg') ||
                              file.path.toLowerCase().endsWith('.jpeg') ||
                              file.path.toLowerCase().endsWith('.png');

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.grey[600]!
                                          : Colors.grey,
                                    ),
                                  ),
                                  child: isImage
                                      ? Image.file(file, fit: BoxFit.cover)
                                      : Container(
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.grey[800]
                                                : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.videocam,
                                                  size: 40,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                                Text(
                                                  'Video',
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeMedia(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black54,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  // Image/Video Upload Area
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: isDark ? Colors.grey[600]! : Colors.grey,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: InkWell(
                      onTap: _pickMedia,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add_box_outlined,
                            size: 30,
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add an image or short video clip',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[400] : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Add phone/Email field
            TextField(
              controller: _contactInfoController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Add phone/Email',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[600]! : Colors.grey,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[600]! : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Choose the type of Issue field
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => ChooseIssueTypePage(
                      onIssueTypeSelected: (String type) {
                        setState(() {
                          _selectedIssueType = type;
                        });
                      },
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: isDark ? Colors.grey[600]! : Colors.grey,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _selectedIssueType ?? 'Choose the type of Issue',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedIssueType == null
                            ? (isDark ? Colors.grey[500] : Colors.grey[700])
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          _selectedIssueType == null ? 'Required' : '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.grey[400] : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                gradient: _buttonGradient,
                onPressed: () {
                  if (_issueDescriptionController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please describe your issue.'),
                      ),
                    );
                  } else if (_selectedIssueType == null ||
                      _selectedIssueType!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please choose or type an issue type.'),
                      ),
                    );
                  } else {
                    _submitFeedback();
                  }
                },
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

class FeedbackOption {
  static const String issue = 'issue';
  static const String suggestion = 'suggestion';
}

enum MediaOption { gallery, camera, video }
