import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'safety_widgets.dart';
import 'safety_dialogs.dart';
import 'emergency_contacts_screen.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String description;
  final int updateInterval;
  final Map<String, bool> communicationMethods;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.description = '',
    this.updateInterval = 5,
    required this.communicationMethods,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'description': description,
      'updateInterval': updateInterval,
      'communicationMethods': communicationMethods,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'] ?? '',
      description: json['description'] ?? '',
      updateInterval: json['updateInterval'] ?? 5,
      communicationMethods: Map<String, bool>.from(json['communicationMethods']),
    );
  }

  List<String> getActiveMethods() {
    return communicationMethods.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }
}

class SafetyTrackingScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const SafetyTrackingScreen({Key? key, this.onBackPressed}) : super(key: key);

  @override
  State<SafetyTrackingScreen> createState() => _SafetyTrackingScreenState();
}

class _SafetyTrackingScreenState extends State<SafetyTrackingScreen> {
  bool _isTracking = false;
  Timer? _trackingTimer;
  int _elapsedSeconds = 0;
  String _emergencyContact = '';
  String _emergencyMessage = '';
  List<EmergencyContact> _savedContacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> contactsJson = prefs.getStringList('emergency_contacts') ?? [];
      
      setState(() {
        _savedContacts = contactsJson
            .map((jsonStr) => EmergencyContact.fromJson(json.decode(jsonStr)))
            .toList();
      });
    } catch (e) {
      print('Error loading contacts: $e');
    }
  }

  Future<void> _deleteContact(String contactId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> contactsJson = prefs.getStringList('emergency_contacts') ?? [];
      
      contactsJson.removeWhere((jsonStr) {
        final contact = EmergencyContact.fromJson(json.decode(jsonStr));
        return contact.id == contactId;
      });
      
      await prefs.setStringList('emergency_contacts', contactsJson);
      await _loadContacts();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Contact deleted'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      print('Error deleting contact: $e');
    }
  }

  void _startTracking() {
    if (_savedContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Please add an emergency contact first')),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isTracking = true;
      _elapsedSeconds = 0;
    });

    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Safety tracking started'),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
      _elapsedSeconds = 0;
    });
    _trackingTimer?.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.stop_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Safety tracking stopped'),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _sendEmergencyAlert() {
    SafetyDialogs.showEmergencyAlert(
      context: context,
      emergencyContact: _emergencyContact,
      emergencyMessage: _emergencyMessage,
    );
  }

  void _openEmergencyContactsScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyContactsScreen(
          onBackPressed: () => Navigator.pop(context),
        ),
      ),
    );
    // Reload contacts when returning from the contacts screen
    _loadContacts();
  }

  void _showContactDetails(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                contact.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(Icons.phone, 'Phone', contact.phone),
              if (contact.email.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.email, 'Email', contact.email),
              ],
              if (contact.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.description, 'Description', contact.description),
              ],
              const SizedBox(height: 12),
              _buildDetailRow(Icons.update, 'Update Interval', '${contact.updateInterval} minutes'),
              const SizedBox(height: 12),
              const Text(
                'Communication Methods:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: contact.getActiveMethods().map((method) {
                  return Chip(
                    label: Text(method, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.red[50],
                    labelStyle: TextStyle(color: Colors.red[900]),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete(contact);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.red),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteContact(contact.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button
            SafetyHeader(onBackPressed: widget.onBackPressed),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Tracking Status Card
                    TrackingStatusCard(
                      isTracking: _isTracking,
                      elapsedSeconds: _elapsedSeconds,
                      onStart: _startTracking,
                      onStop: _stopTracking,
                    ),

                    const SizedBox(height: 20),

                    // Emergency Contact Card (Add Button)
                    InfoCard(
                      icon: Icons.person_add,
                      title: 'Add Emergency Contact',
                      subtitle: 'Tap to add a new emergency contact',
                      color: Colors.red,
                      onTap: _openEmergencyContactsScreen,
                    ),

                    const SizedBox(height: 20),

                    // Saved Emergency Contacts Section
                    if (_savedContacts.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Saved Emergency Contacts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Display each saved contact
                      ..._savedContacts.map((contact) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildContactCard(contact),
                      )).toList(),
                      
                      const SizedBox(height: 8),
                    ],

                    // Emergency Alert Button
                    EmergencyAlertSection(onSendAlert: _sendEmergencyAlert),

                    const SizedBox(height: 20),

                    // Current Location Card
                    if (locationService.currentPosition != null)
                      CurrentLocationCard(locationService: locationService),

                    const SizedBox(height: 20),

                    // Info Section
                    const InfoSection(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[50]!, Colors.red[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showContactDetails(contact),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Contact Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Text(
                            contact.phone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (contact.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          contact.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.update, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Updates every ${contact.updateInterval} min',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${contact.getActiveMethods().length} methods',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}