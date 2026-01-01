// widgets/profile/saved_addresses_widget.dart
import 'package:flutter/material.dart';
import 'address_item.dart';
import 'add_new_address_card.dart';
import '../../models/address.dart';

class SavedAddressesWidget extends StatelessWidget {
  final List<Address> savedAddresses;
  final bool showAddAddressForm;
  final Function(Address) onAddAddress;
  final Function(Address) onDeleteAddress;
  final VoidCallback onToggleAddAddressForm;
  final Function()? onChooseOnMap;
  final String? selectedMapAddress;
  final double? selectedLatitude;
  final double? selectedLongitude;

  const SavedAddressesWidget({
    super.key,
    required this.savedAddresses,
    required this.showAddAddressForm,
    required this.onAddAddress,
    required this.onDeleteAddress,
    required this.onToggleAddAddressForm,
    this.onChooseOnMap,
    this.selectedMapAddress,
    this.selectedLatitude,
    this.selectedLongitude,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saved Addresses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: onToggleAddAddressForm,
                icon: const Icon(Icons.add, color: Colors.green, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (savedAddresses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No saved addresses yet',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            ...savedAddresses.map(
              (address) => AddressItem(
                address: address,
                onDelete: () => onDeleteAddress(address),
              ),
            ),
          if (showAddAddressForm)
            AddNewAddressCard(
              onAddAddress: onAddAddress,
              onCancel: onToggleAddAddressForm,
              onChooseOnMap: onChooseOnMap,
              selectedAddress: selectedMapAddress,
              selectedLatitude: selectedLatitude,
              selectedLongitude: selectedLongitude,
            ),
        ],
      ),
    );
  }
}
