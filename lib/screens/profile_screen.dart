// screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/profile/personal_info_card.dart';
import '../widgets/profile/trip_stats_card.dart';
import '../widgets/profile/saved_addresses_widget.dart';
import 'map_screen.dart';

import '../models/address.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  final _supabase = Supabase.instance.client;
  late final TextEditingController nameController;
  late final TextEditingController numberController;
  late final TextEditingController emailController;
  late final TextEditingController dobController;

  CameraController? _cameraController;
  bool _isLoading = true;
  String? _profileImageUrl;

  // Trip statistics - loaded from backend
  double _rating = 0.0;
  int _totalTrips = 0;
  double _totalSpent = 0.0;

  DateTime? _selectedDob;
  String _formattedDob = '';
  final List<Address> _savedAddresses = [
    Address(name: 'Home', address: '123 Main Street, City'),
    Address(name: 'Work', address: '456 Business Ave, Downtown'),
  ];

  // Profile image
  File? _profileImage;

  // Editing states
  bool _isEditingPersonalInfo = false;
  bool _showAddAddressForm = false;

  // Selected address from map
  String? _selectedMapAddress;
  double? _selectedLatitude;
  double? _selectedLongitude;

  // Temporary variables for editing
  String _tempUserName = '';
  String _tempPhoneNumber = '';
  String _tempEmail = '';
  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize controllers with empty values
    nameController = TextEditingController();
    numberController = TextEditingController();
    emailController = TextEditingController();
    dobController = TextEditingController(text: "");

    _initializeCamera();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      try {
        // Try to load from users table with correct column names
        final response = await _supabase
            .from('users')
            .select('*')
            .eq('id', userId)
            .single();

        final customer = await _supabase
            .from('customers')
            .select('*')
            .eq('id', userId)
            .single();

        // Load saved locations from the saved_locations table
        final locationsResponse = await _supabase
            .from('saved_locations')
            .select('*')
            .eq('user_id', userId);

        setState(() {
          // Use 'name' column which should exist from your database trigger
          nameController.text = response['full_name'] ?? '';
          emailController.text = response['email'] ?? '';
          numberController.text = response['phone_no'] ?? '';
          _profileImageUrl = response['profile_picture_url'];

          _savedAddresses.clear();
          if (locationsResponse.isNotEmpty) {
            _savedAddresses.addAll(
              locationsResponse
                  .map(
                    (location) => Address(
                      name: location['title'] ?? '',
                      address: location['address'] ?? '',
                    ),
                  )
                  .toList(),
            );
          }

          // Load date of birth from backend
          if (customer['dob'] != null &&
              customer['dob'].toString().isNotEmpty) {
            dobController.text = customer['dob'];
            _formattedDob = customer['dob'];

            // Try to parse the date if it's in a valid format
            try {
              if (customer['dob'].contains('-')) {
                final parts = customer['dob'].split('-');
                if (parts.length == 3) {
                  _selectedDob = DateTime(
                    int.parse(parts[2]), // year
                    int.parse(parts[1]), // month
                    int.parse(parts[0]), // day
                  );
                }
              }
            } catch (e) {
              // If parsing fails, keep the string format
              _selectedDob = null;
            }
          } else {
            dobController.text = "";
            _formattedDob = "";
          }

          _isLoading = false;

          // Initialize temp variables
          _tempUserName = nameController.text;
          _tempPhoneNumber = numberController.text;
          _tempEmail = emailController.text;
        });
      } catch (e) {
        // If user doesn't exist in users table, try to get data from auth
        final user = _supabase.auth.currentUser;
        if (user != null) {
          final userName =
              user.userMetadata?['full_name'] ?? user.email ?? 'User';
          setState(() {
            nameController.text = userName;
            emailController.text = user.email ?? '';
            numberController.text = user.phone ?? '';
            _profileImageUrl = user.userMetadata?['avatar_url'];
            _isLoading = false;

            // Initialize temp variables
            _tempUserName = nameController.text;
            _tempPhoneNumber = numberController.text;
            _tempEmail = emailController.text;
          });

          // The user should already exist due to the database trigger
          // But if not, we'll rely on the trigger to create the record
        } else {
          throw Exception('Failed to load user data');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load profile: ${e.toString()}');
    }

    // Load trip statistics after profile data
    await _loadTripStatistics();
  }

  Future<void> _loadTripStatistics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Load trip statistics from trips table
      final response = await _supabase
          .from('trips')
          .select('total_amount, rating, status')
          .eq('user_id', userId)
          .eq('status', 'completed'); // Only completed trips

      if (response.isNotEmpty) {
        // Calculate statistics
        int totalTrips = response.length;
        double totalSpent = 0.0;
        double totalRating = 0.0;
        int ratedTrips = 0;

        for (var trip in response) {
          // Calculate total spent
          final fare = trip['total_amount'] as num?;
          if (fare != null) {
            totalSpent += fare.toDouble();
          }

          // Calculate average rating
          final rating = trip['rating'] as num?;
          if (rating != null && rating > 0) {
            totalRating += rating.toDouble();
            ratedTrips++;
          }
        }

        // Calculate average rating
        double averageRating = ratedTrips > 0 ? totalRating / ratedTrips : 0.0;

        setState(() {
          _totalTrips = totalTrips;
          _totalSpent = totalSpent;
          _rating = averageRating;
        });
      } else {
        // No completed trips found - set default values
        setState(() {
          _totalTrips = 0;
          _totalSpent = 0.0;
          _rating = 0.0;
        });
      }
    } catch (e) {
      print('Failed to load trip statistics: ${e.toString()}');
      // Keep default values on error
      setState(() {
        _totalTrips = 0;
        _totalSpent = 0.0;
        _rating = 0.0;
      });
    }
  }

  Future<void> refreshTripStatistics() async {
    await _loadTripStatistics();
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        if (!await imageFile.exists()) {
          throw Exception('Selected image file does not exist');
        }
        setState(() {
          _profileImage = imageFile;
        });
        await _uploadImage(imageFile);
      }
    } catch (e) {
      _showError('Failed to pick image: ${e.toString()}');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              if (_profileImage != null || _profileImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    setState(() {
                      _profileImage = null;
                      _profileImageUrl = null;
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void toggleEditPersonalInfo() {
    if (_isEditingPersonalInfo) {
      // Save changes - update controllers with temp values first
      nameController.text = _tempUserName;
      numberController.text = _tempPhoneNumber;
      emailController.text = _tempEmail;

      // Show loading indicator and save to backend
      setState(() {
        _isEditingPersonalInfo = false; // Exit edit mode
      });

      // Update profile in background
      _updateProfile()
          .then((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Changes saved successfully!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          })
          .catchError((error) {
            if (mounted) {
              // Revert to edit mode on error
              setState(() {
                _isEditingPersonalInfo = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to save changes: ${error.toString()}'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          });
    } else {
      // Start editing - copy current values to temp
      setState(() {
        _tempUserName = nameController.text;
        _tempPhoneNumber = numberController.text;
        _tempEmail = emailController.text;
        _isEditingPersonalInfo = true;
      });
    }
  }

  void addAddress(Address newAddress) {
    print('🏠 Adding new address: ${newAddress.name} - ${newAddress.address}');
    print('🌍 Coordinates: ${newAddress.latitude}, ${newAddress.longitude}');
    setState(() {
      _savedAddresses.add(newAddress);
      _selectedMapAddress = null; // Clear the selected address
      _selectedLatitude = null; // Clear coordinates
      _selectedLongitude = null;
    });
    print('📤 Saving address to backend...');
    // Save to backend using the saved_locations table
    _saveAddressesToBackend();
  }

  void deleteAddress(Address addressToDelete) {
    setState(() {
      _savedAddresses.removeWhere(
        (address) =>
            address.name == addressToDelete.name &&
            address.address == addressToDelete.address,
      );
    });
    // Save to backend after deletion
    _saveAddressesToBackend();
  }

  Future<void> chooseAddressOnMap() async {
    print('🗺️ Opening map to choose address location');
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          title: 'Choose Address Location',
          isSelectMode: true, // Enable selection mode
        ),
      ),
    );

    if (result != null &&
        result['address'] != null &&
        result['address'].isNotEmpty) {
      print('📍 Address selected from map: ${result['address']}');
      print('📍 Coordinates: ${result['latitude']}, ${result['longitude']}');
      setState(() {
        _selectedMapAddress = result['address'];
        _selectedLatitude = result['latitude'];
        _selectedLongitude = result['longitude'];
      });
    }
  }

  Future<void> _saveAddressesToBackend() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // First, delete existing saved locations for this user
      await _supabase.from('saved_locations').delete().eq('user_id', userId);

      // Then insert new saved locations
      final locationsToInsert = _savedAddresses
          .map(
            (address) => {
              'user_id': userId,
              'title': address.name,
              'address': address.address,
              'latitude': address.latitude,
              'longitude': address.longitude,
              'is_default': false,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            },
          )
          .toList();

      if (locationsToInsert.isNotEmpty) {
        await _supabase.from('saved_locations').insert(locationsToInsert);
      }
    } catch (e) {
      _showError('Failed to save addresses: ${e.toString()}');
    }
  }

  void toggleAddAddressForm() {
    setState(() {
      _showAddAddressForm = !_showAddAddressForm;
    });
  }

  Future<void> selectDateOfBirth() async {
    final DateTime defaultDate = DateTime.now().subtract(
      const Duration(days: 6570),
    );

    DateTime initialDate = defaultDate;
    if (_selectedDob != null) {
      final minDate = DateTime(1900);
      final maxDate = DateTime.now().subtract(const Duration(days: 6570));

      if (_selectedDob!.isAfter(minDate) && _selectedDob!.isBefore(maxDate)) {
        initialDate = _selectedDob!;
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 6570)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDob = pickedDate;
        _formattedDob =
            "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
        dobController.text = _formattedDob;
      });

      // Save DOB to backend
      await _saveDobToBackend();
    }
  }

  Future<void> _saveDobToBackend() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('customers')
          .update({
            'dob': _formattedDob,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Date of birth saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to save date of birth: ${e.toString()}');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'user_profile_pictures/$fileName';

      await _supabase.storage
          .from('drivers-profile-pictures')
          .upload(filePath, imageFile);

      final imageUrl = _supabase.storage
          .from('drivers-profile-pictures')
          .getPublicUrl(filePath);

      await _supabase
          .from('users')
          .update({
            'profile_picture_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      setState(() => _profileImageUrl = imageUrl);
    } catch (e) {
      _showError('Failed to upload image: ${e.toString()}');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
      }
    } catch (e) {
      _showError('Failed to initialize camera: ${e.toString()}');
    }
  }

  Future<void> _updateProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (nameController.text.isNotEmpty) {
        updateData['full_name'] = nameController.text.trim();
      }
      if (emailController.text.isNotEmpty) {
        updateData['email'] = emailController.text.trim();
      }
      // Phone number is not updated here as it should remain from OTP login

      await _supabase.from('users').update(updateData).eq('id', userId);
      await _supabase.from('customers').insert({
        'id': userId,
        'dob': dobController.text.trim(),
      });

      await _loadProfileData();
    } catch (e) {
      _showError('Failed to update profile: ${e.toString()}');
      rethrow;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text('Profile', style: TextStyle(color: colorScheme.onSurface)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isLargeScreen ? 600 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFEEEEEE),
                      child: _profileImage != null
                          ? ClipOval(
                              child: Image.file(
                                _profileImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : _profileImageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _profileImageUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 70,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                    ),
                    Positioned(
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: _showImagePickerOptions,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  nameController.text.isNotEmpty
                      ? nameController.text
                      : 'Your Name',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$_rating ($_totalTrips trips)',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                PersonalInformationCard(
                  isEditing: _isEditingPersonalInfo,
                  userName: _isEditingPersonalInfo
                      ? _tempUserName
                      : nameController.text,
                  phoneNumber: _isEditingPersonalInfo
                      ? _tempPhoneNumber
                      : numberController.text,
                  email: _isEditingPersonalInfo
                      ? _tempEmail
                      : emailController.text,
                  dob: _formattedDob.isNotEmpty
                      ? _formattedDob
                      : 'Tap to select date of birth',
                  onToggleEdit: toggleEditPersonalInfo,
                  onUserNameChanged: (value) =>
                      setState(() => _tempUserName = value),
                  onPhoneNumberChanged: (value) =>
                      setState(() => _tempPhoneNumber = value),
                  onEmailChanged: (value) => setState(() => _tempEmail = value),
                  onDobChanged: (value) => {},
                  onDobTap:
                      selectDateOfBirth, // Connect calendar tap to date selection
                ),
                const SizedBox(height: 20),
                TripStatisticsCard(
                  totalTrips: _totalTrips,
                  rating: _rating,
                  totalSpent: _totalSpent,
                ),
                const SizedBox(height: 20),
                SavedAddressesWidget(
                  savedAddresses: _savedAddresses,
                  showAddAddressForm: _showAddAddressForm,
                  onAddAddress: addAddress,
                  onDeleteAddress: deleteAddress,
                  onToggleAddAddressForm: toggleAddAddressForm,
                  onChooseOnMap: chooseAddressOnMap,
                  selectedMapAddress: _selectedMapAddress,
                  selectedLatitude: _selectedLatitude,
                  selectedLongitude: _selectedLongitude,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await _supabase.auth.signOut();

                      if (!mounted) return;

                      // Navigate to OTP login page and remove all previous routes
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/otp-login',
                        (Route<dynamic> route) => false,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You have been logged out.'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      side: BorderSide(color: theme.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    nameController.dispose();
    numberController.dispose();
    emailController.dispose();
    dobController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }
}
