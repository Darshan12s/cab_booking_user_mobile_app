// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart' as main_app;
import 'terms_conditions.dart';

/// Enum to specify which setting a SettingsSwitchTile controls.
enum SettingType { darkMode, pushNotifications, sound, locationSharing }

/// Enum for different payment method types.
enum PaymentType { visa, mastercard, paypal, upi, cash }

/// Data model for a single payment method.
class PaymentMethod {
  final String id;
  final PaymentType type;
  final String? lastFourDigits;
  final String? expiryDate;
  final String? accountName;
  final String? upiId;
  bool isDefault;

  static List<PaymentMethod>? allPaymentMethods;

  PaymentMethod({
    required this.id,
    required this.type,
    this.lastFourDigits,
    this.expiryDate,
    this.accountName,
    this.upiId,
    this.isDefault = false,
  });

  IconData get icon {
    switch (type) {
      case PaymentType.visa:
        return Icons.credit_card;
      case PaymentType.mastercard:
        return Icons.credit_card;
      case PaymentType.paypal:
        return Icons.payment;
      case PaymentType.upi:
        return Icons.mobile_friendly;
      case PaymentType.cash:
        return Icons.money;
    }
  }

  String get name {
    switch (type) {
      case PaymentType.visa:
        return 'Visa';
      case PaymentType.mastercard:
        return 'Mastercard';
      case PaymentType.paypal:
        return 'PayPal';
      case PaymentType.upi:
        return 'UPI';
      case PaymentType.cash:
        return 'Cash';
    }
  }
}

/// Enum for transaction status.
enum TransactionStatus { paid, pending, failed }

/// Data model for a single billing transaction.
class BillingTransaction {
  final String id;
  final String description;
  final DateTime date;
  final double amount;
  final String paymentMethod;
  final TransactionStatus status;

  BillingTransaction({
    required this.id,
    required this.description,
    required this.date,
    required this.amount,
    required this.paymentMethod,
    required this.status,
  });
}

// Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late final User? _user;

  // Settings state
  bool _arePushNotificationsEnabled = false;
  bool _isSoundEnabled = true;
  bool _isLocationSharingEnabled = false;
  bool _isDarkModeEnabled = false;

  // Payment methods and billing data
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'visa_1234',
      type: PaymentType.visa,
      lastFourDigits: '1234',
      expiryDate: '12/2027',
      isDefault: true,
    ),
    PaymentMethod(
      id: 'mastercard_5678',
      type: PaymentType.mastercard,
      lastFourDigits: '5678',
      expiryDate: '08/2026',
      isDefault: false,
    ),
    PaymentMethod(
      id: 'paypal_account',
      type: PaymentType.paypal,
      accountName: 'PayPal Account',
      isDefault: false,
    ),
  ];

  final List<BillingTransaction> _transactions = [
    BillingTransaction(
      id: 'tx_1',
      description: 'Airport Transfer - Downtown to JFK',
      date: DateTime(2025, 8, 1),
      amount: 45.50,
      paymentMethod: 'Credit Card ****1234',
      status: TransactionStatus.paid,
    ),
    BillingTransaction(
      id: 'tx_2',
      description: 'City Ride - Mall to Home',
      date: DateTime(2025, 7, 1),
      amount: 18.75,
      paymentMethod: 'PayPal',
      status: TransactionStatus.paid,
    ),
    BillingTransaction(
      id: 'tx_3',
      description: 'Outstation Trip - City to Beach Resort',
      date: DateTime(2025, 6, 1),
      amount: 125.00,
      paymentMethod: 'Credit Card ****5678',
      status: TransactionStatus.pending,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _user = _supabase.auth.currentUser;

    // Initialize theme state based on current global theme
    _isDarkModeEnabled = main_app.themeModeNotifier.value == ThemeMode.light;

    // Listen for theme changes
    main_app.themeModeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    main_app.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {
        _isDarkModeEnabled =
            main_app.themeModeNotifier.value == ThemeMode.light;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }
  }

  void _deletePaymentMethod(String id) {
    setState(() {
      bool wasDefault = false;
      int deletedIndex = _paymentMethods.indexWhere(
        (method) => method.id == id,
      );
      if (deletedIndex != -1) {
        wasDefault = _paymentMethods[deletedIndex].isDefault;
        _paymentMethods.removeAt(deletedIndex);
      }

      if (wasDefault && _paymentMethods.isNotEmpty) {
        _paymentMethods.first.isDefault = true;
      }
    });
  }

  void _setAsDefault(String id) {
    setState(() {
      for (PaymentMethod method in _paymentMethods) {
        method.isDefault = (method.id == id);
      }
    });
  }

  Future<void> _addPaymentMethod() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<PaymentType>(
        builder: (context) => const AddPaymentMethodScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        final String newId = 'new_${DateTime.now().millisecondsSinceEpoch}';
        final PaymentMethod newMethod;

        switch (result) {
          case PaymentType.upi:
            newMethod = PaymentMethod(
              id: newId,
              type: PaymentType.upi,
              upiId: 'user@upi',
              isDefault: false,
            );
            break;
          case PaymentType.cash:
            newMethod = PaymentMethod(
              id: newId,
              type: PaymentType.cash,
              isDefault: false,
            );
            break;
          default:
            newMethod = PaymentMethod(
              id: newId,
              type: PaymentType.visa,
              lastFourDigits: '${1000 + _paymentMethods.length}',
              expiryDate: '01/${2025 + _paymentMethods.length}',
              isDefault: false,
            );
        }

        if (_paymentMethods.isEmpty) {
          newMethod.isDefault = true;
        }
        _paymentMethods.add(newMethod);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: <Widget>[
            if (_user != null) ...[
              SettingsCard(
                title: 'Account',
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(_user.email ?? 'User'),
                    subtitle: Text(
                      'Account ID: ${_user.id.substring(0, 8)}...',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],

            SettingsCard(
              title: 'Appearance',
              children: <Widget>[
                SwitchListTile(
                  secondary: Icon(
                    _isDarkModeEnabled ? Icons.light_mode : Icons.dark_mode,
                    color: _isDarkModeEnabled
                        ? Colors.yellow[700]
                        : Colors.orange,
                  ),
                  title: const Text('Theme'),
                  subtitle: Text(
                    _isDarkModeEnabled
                        ? 'Light theme is enabled'
                        : 'Dark theme is enabled',
                  ),
                  value: _isDarkModeEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _isDarkModeEnabled = value;
                    });

                    // Update global theme
                    ThemeMode newThemeMode = value
                        ? ThemeMode.light
                        : ThemeMode.dark;
                    main_app.themeModeNotifier.value = newThemeMode;
                    await main_app.saveThemeMode(newThemeMode);

                    // Show feedback to user
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Switched to Light Theme'
                                : 'Switched to Dark Theme',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SettingsCard(
              title: 'Notifications',
              children: <Widget>[
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive ride updates and offers'),
                  value: _arePushNotificationsEnabled,
                  onChanged: (value) =>
                      setState(() => _arePushNotificationsEnabled = value),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up),
                  title: const Text('Sound'),
                  subtitle: const Text('Play sounds for notifications'),
                  value: _isSoundEnabled,
                  onChanged: (value) => setState(() => _isSoundEnabled = value),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SettingsCard(
              title: 'Privacy & Security',
              children: <Widget>[
                const ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Privacy Settings'),
                  subtitle: Text('Manage your privacy preferences'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.location_on),
                  title: const Text('Location Sharing'),
                  subtitle: const Text('Share location during rides'),
                  value: _isLocationSharingEnabled,
                  onChanged: (value) =>
                      setState(() => _isLocationSharingEnabled = value),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SettingsCard(
              title: 'Payment & Billing',
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: const Text('Payment Methods'),
                  subtitle: const Text('Manage your payment options'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => PaymentMethodsScreen(
                          paymentMethods: _paymentMethods,
                          onDelete: _deletePaymentMethod,
                          onSetDefault: _setAsDefault,
                          onAdd: _addPaymentMethod,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Billing History'),
                  subtitle: const Text('View your past transactions'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            BillingHistoryScreen(transactions: _transactions),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SettingsCard(
              title: 'Support',
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help Center'),
                  subtitle: const Text('Get help and support'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpTopicsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star_border),
                  title: const Text('Rate App'),
                  subtitle: const Text('Rate Green Mobility on the app store'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RatingPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SettingsCard(
              title: 'Terms & Conditions',
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.policy),
                  title: const Text('Terms & Conditions'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsAndConditionsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SettingsCard(
              title: 'Account Actions',
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('Sign out of your account'),
                  onTap: _signOut,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Help Topics Screen with full functionality
/// A simple data model for a help topic.
class HelpTopicData {
  final String title;

  const HelpTopicData({required this.title});
}

/// A simple data model for an FAQ item.
class FAQItemData {
  final String title;

  const FAQItemData({required this.title});
}

class HelpTopicsScreen extends StatefulWidget {
  const HelpTopicsScreen({super.key});

  @override
  State<HelpTopicsScreen> createState() => _HelpTopicsScreenState();
}

class _HelpTopicsScreenState extends State<HelpTopicsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data for the help topics, making the UI data-driven.
  final List<HelpTopicData> _allHelpTopics = const [
    HelpTopicData(title: 'Ride fare related Issues'),
    HelpTopicData(title: 'Captain and Vehicle related issues'),
    HelpTopicData(title: 'Pass and Payment related Issues'),
    HelpTopicData(title: 'Other Topics'),
  ];

  List<HelpTopicData> get _filteredHelpTopics {
    if (_searchQuery.isEmpty) {
      return _allHelpTopics;
    }
    return _allHelpTopics.where((topic) {
      return topic.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back if possible, otherwise do nothing
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text('Help topics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  hintText: 'Search Help Topics',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Help Topics List
            Expanded(
              child: _filteredHelpTopics.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No help topics found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try searching with different keywords',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredHelpTopics.length,
                      itemBuilder: (BuildContext context, int index) {
                        final HelpTopicData topic = _filteredHelpTopics[index];
                        return Column(
                          children: <Widget>[
                            HelpTopicItem(title: topic.title),
                            // Add a divider after each item except the last one
                            if (index < _filteredHelpTopics.length - 1)
                              Divider(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white12
                                    : Colors.grey[300],
                                height: 1,
                                thickness: 0.5,
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpTopicItem extends StatelessWidget {
  final String title;

  const HelpTopicItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      onTap: () {
        if (title == 'Ride fare related Issues') {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const RideFareIssuesScreen(),
            ),
          );
        } else if (title == 'Captain and Vehicle related issues') {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  const CaptainVehicleIssuesScreen(),
            ),
          );
        } else if (title == 'Pass and Payment related Issues') {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  const PassPaymentIssuesScreen(),
            ),
          );
        } else if (title == 'Other Topics') {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const OtherTopicsScreen(),
            ),
          );
        }
      },
    );
  }
}

class RideFareIssuesScreen extends StatefulWidget {
  const RideFareIssuesScreen({super.key});

  @override
  State<RideFareIssuesScreen> createState() => _RideFareIssuesScreenState();
}

class _RideFareIssuesScreenState extends State<RideFareIssuesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<FAQItemData> _allRideFareFAQs = const <FAQItemData>[
    FAQItemData(title: 'I have been charged higher than the estimated fare'),
    FAQItemData(title: 'I have been charged a cancellation fee'),
    FAQItemData(
      title: 'I didn\'t take the ride but I was charged for the same',
    ),
    FAQItemData(title: 'I didn\'t receive cashback in my wallet'),
    FAQItemData(title: 'Billing Related Issues'),
  ];

  List<FAQItemData> get _filteredFAQs {
    if (_searchQuery.isEmpty) {
      return _allRideFareFAQs;
    }
    return _allRideFareFAQs.where((faq) {
      return faq.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text('FAQs'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              // Handle tickets button tap
            },
            icon: Icon(
              Icons.receipt_long,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            label: Text(
              'Tickets',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0x80FFFFFF)
                      : const Color(0x80000000),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                hintText: 'Search FAQs',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Ride fare related Issues',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _filteredFAQs.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No FAQs found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredFAQs.length,
                            itemBuilder: (BuildContext context, int index) {
                              final FAQItemData faq = _filteredFAQs[index];
                              return Column(
                                children: <Widget>[
                                  FAQItemWidget(title: faq.title),
                                  if (index < _filteredFAQs.length - 1)
                                    Divider(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white12
                                          : Colors.grey[300],
                                      height: 1,
                                      thickness: 0.5,
                                    ),
                                ],
                              );
                            },
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CaptainVehicleIssuesScreen extends StatefulWidget {
  const CaptainVehicleIssuesScreen({super.key});

  @override
  State<CaptainVehicleIssuesScreen> createState() =>
      _CaptainVehicleIssuesScreenState();
}

class _CaptainVehicleIssuesScreenState
    extends State<CaptainVehicleIssuesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<FAQItemData> _allCaptainVehicleFAQs = const <FAQItemData>[
    FAQItemData(title: 'Captain was rude or unprofessional'),
    FAQItemData(title: 'Captain was driving dangerously'),
    FAQItemData(title: 'Captain asked me to cancel the ride'),
    FAQItemData(title: 'Captain was demanding extra cash'),
    FAQItemData(title: 'Captain/Vehicle details didn\'t match'),
    FAQItemData(title: 'I have an issue with the given helmet'),
    FAQItemData(title: 'I left an item/my personal belonging in the vehicle'),
    FAQItemData(title: 'I want to report an issue about the Captain/Ride'),
  ];

  List<FAQItemData> get _filteredFAQs {
    if (_searchQuery.isEmpty) {
      return _allCaptainVehicleFAQs;
    }
    return _allCaptainVehicleFAQs.where((faq) {
      return faq.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text('FAQs'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              // Handle tickets button tap
            },
            icon: Icon(
              Icons.receipt_long,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            label: Text(
              'Tickets',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0x80FFFFFF)
                      : const Color(0x80000000),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                hintText: 'Search Captain & Vehicle FAQs',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Captain and Vehicle related issues',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _filteredFAQs.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No FAQs found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredFAQs.length,
                            itemBuilder: (BuildContext context, int index) {
                              final FAQItemData faq = _filteredFAQs[index];
                              return Column(
                                children: <Widget>[
                                  FAQItemWidget(title: faq.title),
                                  if (index < _filteredFAQs.length - 1)
                                    Divider(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white12
                                          : Colors.grey[300],
                                      height: 1,
                                      thickness: 0.5,
                                    ),
                                ],
                              );
                            },
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PassPaymentIssuesScreen extends StatelessWidget {
  const PassPaymentIssuesScreen({super.key});

  final List<FAQItemData> _passPaymentTopics = const <FAQItemData>[
    FAQItemData(title: 'Payment & Wallets'),
    FAQItemData(title: 'Rapido Coins'),
    FAQItemData(title: 'Power Pass'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text('FAQs'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              // Handle tickets button tap
            },
            icon: Icon(
              Icons.receipt_long,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            label: Text(
              'Tickets',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0x80FFFFFF)
                      : const Color(0x80000000),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                'Pass and Payment related Issues',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _passPaymentTopics.length,
                itemBuilder: (BuildContext context, int index) {
                  final FAQItemData topic = _passPaymentTopics[index];
                  return Column(
                    children: <Widget>[
                      FAQItemWidget(title: topic.title),
                      if (index < _passPaymentTopics.length - 1)
                        Divider(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white12
                              : Colors.grey[300],
                          height: 1,
                          thickness: 0.5,
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class OtherTopicsScreen extends StatelessWidget {
  const OtherTopicsScreen({super.key});

  final List<FAQItemData> _otherTopicsFAQs = const <FAQItemData>[
    FAQItemData(title: 'Account & App'),
    FAQItemData(title: 'Referrals'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text('FAQs'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              // Handle tickets button tap
            },
            icon: Icon(
              Icons.receipt_long,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            label: Text(
              'Tickets',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0x80FFFFFF)
                      : const Color(0x80000000),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                'Other Topics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _otherTopicsFAQs.length,
                itemBuilder: (BuildContext context, int index) {
                  final FAQItemData faq = _otherTopicsFAQs[index];
                  return Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          faq.title,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 0,
                        ),
                        onTap: () {
                          if (faq.title == 'Account & App') {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const AccountAppScreen(),
                              ),
                            );
                          }
                          // Add similar navigation for other items if needed
                        },
                      ),
                      if (index < _otherTopicsFAQs.length - 1)
                        Divider(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white12
                              : Colors.grey[300],
                          height: 1,
                          thickness: 0.5,
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountAppScreen extends StatefulWidget {
  const AccountAppScreen({super.key});

  @override
  State<AccountAppScreen> createState() => _AccountAppScreenState();
}

class _AccountAppScreenState extends State<AccountAppScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<FAQItemData> _allAccountAppFAQs = const <FAQItemData>[
    FAQItemData(title: 'How can I book a ride?'),
    FAQItemData(title: 'How can I schedule a ride in advance?'),
    FAQItemData(title: 'How do I turn off the Notifications?'),
    FAQItemData(title: 'How do I turn on/off picture-in-picture feature?'),
    FAQItemData(title: 'How can I update my mobile number?'),
    FAQItemData(title: 'How do I update my email ID?'),
    FAQItemData(title: 'How can I update the language on my app?'),
    FAQItemData(title: 'How to update my work/home or favourite locations?'),
    FAQItemData(title: 'How do I deactivate my account?'),
    FAQItemData(title: 'I am unable to request a ride'),
    FAQItemData(title: 'My app is crashing suddenly'),
    FAQItemData(title: 'I am not able to find a captain for my ride'),
  ];

  List<FAQItemData> get _filteredFAQs {
    if (_searchQuery.isEmpty) {
      return _allAccountAppFAQs;
    }
    return _allAccountAppFAQs.where((faq) {
      return faq.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text('FAQs'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              // Handle tickets button tap
            },
            icon: Icon(
              Icons.receipt_long,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            label: Text(
              'Tickets',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0x80FFFFFF)
                      : const Color(0x80000000),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                hintText: 'Search Account & App FAQs',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Account & App',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _filteredFAQs.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No FAQs found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredFAQs.length,
                            itemBuilder: (BuildContext context, int index) {
                              final FAQItemData faq = _filteredFAQs[index];
                              return Column(
                                children: <Widget>[
                                  FAQItemWidget(title: faq.title),
                                  if (index < _filteredFAQs.length - 1)
                                    Divider(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white12
                                          : Colors.grey[300],
                                      height: 1,
                                      thickness: 0.5,
                                    ),
                                ],
                              );
                            },
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItemWidget extends StatelessWidget {
  final String title;

  const FAQItemWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0),
      onTap: () {
        // Handle FAQ item selection - e.g., navigate to detail screen for this FAQ
      },
    );
  }
}

// Settings Card Widget
class SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            ...children,
          ],
        ),
      ),
    );
  }
}

// Payment Methods Screen
class PaymentMethodsScreen extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final Function(String) onDelete;
  final Function(String) onSetDefault;
  final Function() onAdd;

  const PaymentMethodsScreen({
    super.key,
    required this.paymentMethods,
    required this.onDelete,
    required this.onSetDefault,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: ListView.builder(
        itemCount: paymentMethods.length + 1,
        itemBuilder: (context, index) {
          if (index == paymentMethods.length) {
            return ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Payment Method'),
              onTap: () => onAdd(),
            );
          }
          final method = paymentMethods[index];
          return ListTile(
            leading: Icon(method.icon),
            title: Text(method.name),
            subtitle: method.lastFourDigits != null
                ? Text('•••• ${method.lastFourDigits}')
                : method.upiId != null
                ? Text(method.upiId!)
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (method.isDefault)
                  const Chip(
                    label: Text('Default'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onDelete(method.id),
                ),
              ],
            ),
            onTap: () => onSetDefault(method.id),
          );
        },
      ),
    );
  }
}

// Billing History Screen
class BillingHistoryScreen extends StatelessWidget {
  final List<BillingTransaction> transactions;

  const BillingHistoryScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing History')),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            leading: const Icon(Icons.receipt),
            title: Text(transaction.description),
            subtitle: Text(
              '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} - ${transaction.paymentMethod}',
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  transaction.status.toString().split('.').last,
                  style: TextStyle(
                    color: transaction.status == TransactionStatus.paid
                        ? Colors.green
                        : transaction.status == TransactionStatus.pending
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Add Payment Method Screen
class AddPaymentMethodScreen extends StatelessWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Payment Method')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Credit/Debit Card'),
            onTap: () => Navigator.pop(context, PaymentType.visa),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('PayPal'),
            onTap: () => Navigator.pop(context, PaymentType.paypal),
          ),
          ListTile(
            leading: const Icon(Icons.mobile_friendly),
            title: const Text('UPI'),
            onTap: () => Navigator.pop(context, PaymentType.upi),
          ),
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Cash'),
            onTap: () => Navigator.pop(context, PaymentType.cash),
          ),
        ],
      ),
    );
  }
}

// Rating Page
class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a rating before submitting.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Thank you for your feedback!'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );

    // Clear the form
    _feedbackController.clear();
    setState(() {
      _rating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate & Feedback'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'How would you rate our app?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(5, (int index) {
                  return IconButton(
                    iconSize: 40,
                    icon: Icon(
                      Icons.star,
                      color: index < _rating ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
            ),
            Center(
              child: Text(
                _rating == 0 ? '' : 'You rated: $_rating/5',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Your feedback (optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                hintText: 'Tell us what you think...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
              maxLines: 5,
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitFeedback,
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'SUBMIT FEEDBACK',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}