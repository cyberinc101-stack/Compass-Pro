import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

class EmergencyContactsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const EmergencyContactsScreen({Key? key, this.onBackPressed}) : super(key: key);

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  // Contact fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Time interval for coordinate updates (in minutes)
  int _updateInterval = 5;
  
  // Communication methods
  final Map<String, bool> _communicationMethods = {
    'SMS': true,
    'Phone Call': false,
    'Email': false,
    'WhatsApp': false,
    'Facebook Messenger': false,
    'Telegram': false,
    'Signal': false,
    'Viber': false,
    'WeChat': false,
    'Line': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    // Validate required fields
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Name and phone are required'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Check description length
    if (_descriptionController.text.length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Description must be 200 characters or less'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      // Create new contact
      final contact = EmergencyContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        description: _descriptionController.text,
        updateInterval: _updateInterval,
        communicationMethods: Map.from(_communicationMethods),
      );

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      List<String> contactsJson = prefs.getStringList('emergency_contacts') ?? [];
      contactsJson.add(json.encode(contact.toJson()));
      await prefs.setStringList('emergency_contacts', contactsJson);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Emergency contact saved'),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      if (widget.onBackPressed != null) {
        widget.onBackPressed!();
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text('Error saving contact: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red[400]!, Colors.red[600]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (widget.onBackPressed != null) {
                        widget.onBackPressed!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Contact',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person_add, size: 16, color: Colors.white70),
                            SizedBox(width: 6),
                            Text(
                              'Configure emergency contact details',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact Information Section
                    _buildSectionHeader('Contact Information'),
                    const SizedBox(height: 12),
                    
                    _buildTextField(
                      controller: _nameController,
                      label: 'Contact Name',
                      hint: 'e.g., Mom, John Doe',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+1234567890',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email (Optional)',
                      hint: 'contact@example.com',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    // Description Section
                    _buildSectionHeader('Description'),
                    const SizedBox(height: 8),
                    Text(
                      'Brief description (max 200 characters)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: 'e.g., Primary emergency contact, available 24/7',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        counterStyle: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Update Interval Section
                    _buildSectionHeader('Location Update Interval'),
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Send coordinates every:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[900],
                                ),
                              ),
                              Text(
                                '$_updateInterval minutes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Slider(
                            value: _updateInterval.toDouble(),
                            min: 1,
                            max: 60,
                            divisions: 59,
                            activeColor: Colors.red,
                            inactiveColor: Colors.red[200],
                            label: '$_updateInterval min',
                            onChanged: (value) {
                              setState(() {
                                _updateInterval = value.toInt();
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('1 min', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              Text('60 min', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Communication Methods Section
                    _buildSectionHeader('Communication Methods'),
                    const SizedBox(height: 8),
                    Text(
                      'Select how to send emergency alerts',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: _communicationMethods.keys.map((method) {
                          return Column(
                            children: [
                              CheckboxListTile(
                                title: Text(method),
                                secondary: Icon(_getMethodIcon(method), color: Colors.red),
                                value: _communicationMethods[method],
                                activeColor: Colors.red,
                                onChanged: (value) {
                                  setState(() {
                                    _communicationMethods[method] = value ?? false;
                                  });
                                },
                              ),
                              if (method != _communicationMethods.keys.last)
                                Divider(height: 1, color: Colors.grey[300]),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveContact,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Save Contact',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.red[900],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'SMS':
        return Icons.sms;
      case 'Phone Call':
        return Icons.phone;
      case 'Email':
        return Icons.email;
      case 'WhatsApp':
        return Icons.chat;
      case 'Facebook Messenger':
        return Icons.messenger;
      case 'Telegram':
        return Icons.send;
      case 'Signal':
        return Icons.verified_user;
      case 'Viber':
        return Icons.phone_android;
      case 'WeChat':
        return Icons.chat_bubble;
      case 'Line':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }
}