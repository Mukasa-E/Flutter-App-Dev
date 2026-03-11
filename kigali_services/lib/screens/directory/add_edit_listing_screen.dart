import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_categories.dart';
import '../../core/utils/validators.dart';
import '../../models/listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/custom_text_field.dart';

class AddEditListingScreen extends StatefulWidget {
  final Listing? listing;

  const AddEditListingScreen({super.key, this.listing});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late String _selectedCategory;

  bool get isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.listing?.name ?? '');
    _addressController =
        TextEditingController(text: widget.listing?.address ?? '');
    _contactController =
        TextEditingController(text: widget.listing?.contactNumber ?? '');
    _descriptionController =
        TextEditingController(text: widget.listing?.description ?? '');
    _latitudeController = TextEditingController(
      text: widget.listing?.latitude.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.listing?.longitude.toString() ?? '',
    );

    _selectedCategory = widget.listing?.category ?? 'Hospital';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUserId = context.read<AuthProvider>().user?.uid;
    if (currentUserId == null) return;

    final listing = Listing(
      id: widget.listing?.id ?? '',
      name: _nameController.text.trim(),
      category: _selectedCategory,
      address: _addressController.text.trim(),
      contactNumber: _contactController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      createdBy: widget.listing?.createdBy ?? currentUserId,
      timestamp: widget.listing?.timestamp ?? Timestamp.now(),
    );

    if (isEditing) {
      await context.read<ListingProvider>().updateListing(listing);
    } else {
      await context.read<ListingProvider>().addListing(listing);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Listing' : 'Add Listing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Place or Service Name',
                validator: (value) => Validators.requiredField(value, 'Name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: appCategories
                    .where((item) => item != 'All')
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _addressController,
                label: 'Address',
                validator: (value) => Validators.requiredField(value, 'Address'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _contactController,
                label: 'Contact Number',
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    Validators.requiredField(value, 'Contact Number'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
                validator: (value) =>
                    Validators.requiredField(value, 'Description'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _latitudeController,
                label: 'Latitude',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (value) => Validators.number(value, 'Latitude'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _longitudeController,
                label: 'Longitude',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (value) => Validators.number(value, 'Longitude'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: provider.isLoading ? null : _saveListing,
                child: Text(isEditing ? 'Update Listing' : 'Create Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}