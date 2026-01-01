// widgets/my_Trip/driver_card_widget.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Define custom colors for consistency with the design

class DriverCardWidget extends StatelessWidget {
  final bool showContact;
  final String? driverPhone;

  const DriverCardWidget({
    super.key,
    this.showContact = true,
    this.driverPhone,
  });

  void _callDriver(BuildContext context) async {
    String? phone = driverPhone;
    // If driverPhone is not provided, use logged-in user's phone number
    if ((phone == null || phone.isEmpty) &&
        Supabase.instance.client.auth.currentUser != null) {
      phone = Supabase.instance.client.auth.currentUser?.phone;
    }
    if (phone != null && phone.isNotEmpty) {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot launch phone dialer')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available')),
      );
    }
  }

  void _messageDriver(BuildContext context) async {
    String? phone = driverPhone;
    // If driverPhone is not provided, use logged-in user's phone number
    if ((phone == null || phone.isEmpty) &&
        Supabase.instance.client.auth.currentUser != null) {
      phone = Supabase.instance.client.auth.currentUser?.phone;
    }
    if (phone != null && phone.isNotEmpty) {
      final uri = Uri(scheme: 'sms', path: phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot launch messaging app')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: const Text("Vignesh"),
        subtitle: const Text("Driver Details"),
        trailing: showContact
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () => _callDriver(context),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.blue),
                    onPressed: () => _messageDriver(context),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
