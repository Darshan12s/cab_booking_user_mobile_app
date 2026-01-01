// widgets/profile/add_new_address_card.dart
import 'package:flutter/material.dart';
import '../../models/address.dart';

class AddNewAddressCard extends StatefulWidget {
  final Function(Address) onAddAddress;
  final VoidCallback onCancel;
  final VoidCallback? onChooseOnMap;
  final String? selectedAddress;
  final double? selectedLatitude;
  final double? selectedLongitude;

  const AddNewAddressCard({
    required this.onAddAddress,
    required this.onCancel,
    this.onChooseOnMap,
    this.selectedAddress,
    this.selectedLatitude,
    this.selectedLongitude,
    super.key,
  });

  @override
  State<AddNewAddressCard> createState() => _AddNewAddressCardState();
}

class _AddNewAddressCardState extends State<AddNewAddressCard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedType = 'Other';

  @override
  void initState() {
    super.initState();
    // Pre-fill the address if provided
    if (widget.selectedAddress != null) {
      _addressController.text = widget.selectedAddress!;
    }
  }

  @override
  void didUpdateWidget(AddNewAddressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update address field if selectedAddress changes
    if (widget.selectedAddress != oldWidget.selectedAddress &&
        widget.selectedAddress != null) {
      _addressController.text = widget.selectedAddress!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Add New Address",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: _nameController,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: "Address name (e.g. Home, Office)",
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: _addressController,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: "Full address",
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (widget.onChooseOnMap != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: widget.onChooseOnMap,
                  icon: const Icon(Icons.map, size: 18, color: Colors.green),
                  label: const Text(
                    'Choose on Map',
                    style: TextStyle(color: Colors.green),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            // Display coordinates if available
            if (widget.selectedLatitude != null && widget.selectedLongitude != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Coordinates: ${widget.selectedLatitude!.toStringAsFixed(6)}, ${widget.selectedLongitude!.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ...<String>['Home', 'Work', 'Other'].map<Widget>((String type) {
                  final bool isSelected = _selectedType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() => _selectedType = type);
                    },
                    selectedColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.2),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    labelPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.trim().isNotEmpty &&
                          _addressController.text.trim().isNotEmpty) {
                        widget.onAddAddress(
                          Address(
                            name: _nameController.text.trim(),
                            address: _addressController.text.trim(),
                            latitude: widget.selectedLatitude ?? 0.0,
                            longitude: widget.selectedLongitude ?? 0.0,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Address added successfully!'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Add Address"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
