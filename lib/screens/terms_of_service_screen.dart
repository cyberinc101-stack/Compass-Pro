import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      backgroundColor: Colors.white, // Force white background
      appBar: AppBar(
        title: Text(localization.translate('terms_of_service')),
        elevation: 2,
        backgroundColor: Colors.white, // White AppBar
        foregroundColor: Colors.black, // Black text
        iconTheme: const IconThemeData(color: Colors.black), // Black back button
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F5F5), // Light grey
              Colors.white,      // White
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.description,
                        size: 48,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localization.translate('terms_of_service'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${localization.translate('last_updated')}: ${DateTime.now().toString().split(' ')[0]}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Agreement to Terms
              _buildSection(
                title: localization.translate('tos_agreement_to_terms'),
                content: localization.translate('tos_agreement_content'),
              ),

              // License Grant
              _buildSection(
                title: localization.translate('tos_license_grant'),
                content: localization.translate('tos_license_content'),
              ),

              // Acceptable Use
              _buildSection(
                title: localization.translate('tos_acceptable_use'),
                content: localization.translate('tos_acceptable_use_content'),
              ),

              // Location Services
              _buildSection(
                title: localization.translate('tos_location_services'),
                content: localization.translate('tos_location_services_content'),
              ),

              // Navigation and Safety Disclaimer
              _buildSection(
                title: localization.translate('tos_navigation_safety'),
                content: localization.translate('tos_navigation_safety_content'),
              ),

              // User Content and Data
              _buildSection(
                title: localization.translate('tos_user_content'),
                content: localization.translate('tos_user_content_content'),
              ),

              // Premium Features
              _buildSection(
                title: localization.translate('tos_premium_features'),
                content: localization.translate('tos_premium_features_content'),
              ),

              // Intellectual Property
              _buildSection(
                title: localization.translate('tos_intellectual_property'),
                content: localization.translate('tos_intellectual_property_content'),
              ),

              // Third-Party Services
              _buildSection(
                title: localization.translate('tos_third_party_services'),
                content: localization.translate('tos_third_party_services_content'),
              ),

              // Disclaimer of Warranties
              _buildSection(
                title: localization.translate('tos_disclaimer_warranties'),
                content: localization.translate('tos_disclaimer_warranties_content'),
              ),

              // Limitation of Liability
              _buildSection(
                title: localization.translate('tos_limitation_liability'),
                content: localization.translate('tos_limitation_liability_content'),
              ),

              // Emergency Services
              _buildSection(
                title: localization.translate('tos_emergency_services'),
                content: localization.translate('tos_emergency_services_content'),
              ),

              // Privacy
              _buildSection(
                title: localization.translate('tos_privacy'),
                content: localization.translate('tos_privacy_content'),
              ),

              // Updates and Modifications
              _buildSection(
                title: localization.translate('tos_updates_modifications'),
                content: localization.translate('tos_updates_modifications_content'),
              ),

              // Account Termination
              _buildSection(
                title: localization.translate('tos_account_termination'),
                content: localization.translate('tos_account_termination_content'),
              ),

              // Children
              _buildSection(
                title: localization.translate('tos_children'),
                content: localization.translate('tos_children_content'),
              ),

              // Governing Law
              _buildSection(
                title: localization.translate('tos_governing_law'),
                content: localization.translate('tos_governing_law_content'),
              ),

              // Severability
              _buildSection(
                title: localization.translate('tos_severability'),
                content: localization.translate('tos_severability_content'),
              ),

              // Entire Agreement
              _buildSection(
                title: localization.translate('tos_entire_agreement'),
                content: localization.translate('tos_entire_agreement_content'),
              ),

              // Contact Information
              _buildSection(
                title: localization.translate('tos_contact_info'),
                content: localization.translate('tos_contact_info_content'),
              ),

              const SizedBox(height: 32),

              // Acknowledgment Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      localization.translate('tos_important_notice'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localization.translate('tos_acknowledgment'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}