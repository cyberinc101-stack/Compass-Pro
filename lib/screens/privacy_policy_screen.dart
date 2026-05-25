import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(localization.translate('privacy_policy')),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F5F5),
              Colors.white,
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
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.privacy_tip,
                        size: 48,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localization.translate('privacy_policy'),
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

              // Introduction
              _buildSection(
                title: localization.translate('pp_introduction'),
                content: localization.translate('pp_introduction_content'),
              ),

              _buildSection(
                title: localization.translate('pp_info_we_collect'),
                content: localization.translate('pp_info_we_collect_content'),
              ),

              _buildSubSection(
                title: localization.translate('pp_location_data'),
                content: localization.translate('pp_location_data_content'),
              ),

              _buildSubSection(
                title: localization.translate('pp_device_info'),
                content: localization.translate('pp_device_info_content'),
              ),

              _buildSubSection(
                title: localization.translate('pp_app_settings'),
                content: localization.translate('pp_app_settings_content'),
              ),

              _buildSubSection(
                title: localization.translate('pp_weather_data'),
                content: localization.translate('pp_weather_data_content'),
              ),

              _buildSection(
                title: localization.translate('pp_how_we_use_info'),
                content: localization.translate('pp_how_we_use_info_content'),
              ),

              _buildSection(
                title: localization.translate('pp_data_storage_security'),
                content: localization.translate('pp_data_storage_security_content'),
              ),

              _buildSection(
                title: localization.translate('pp_location_permissions'),
                content: localization.translate('pp_location_permissions_content'),
              ),

              _buildSection(
                title: localization.translate('pp_third_party_services'),
                content: localization.translate('pp_third_party_services_content'),
              ),

              _buildSection(
                title: localization.translate('pp_data_sharing'),
                content: localization.translate('pp_data_sharing_content'),
              ),

              _buildSection(
                title: localization.translate('pp_your_rights'),
                content: localization.translate('pp_your_rights_content'),
              ),

              _buildSection(
                title: localization.translate('pp_childrens_privacy'),
                content: localization.translate('pp_childrens_privacy_content'),
              ),

              _buildSection(
                title: localization.translate('pp_changes_to_policy'),
                content: localization.translate('pp_changes_to_policy_content'),
              ),

              _buildSection(
                title: localization.translate('pp_data_retention'),
                content: localization.translate('pp_data_retention_content'),
              ),

              _buildSection(
                title: localization.translate('pp_international_users'),
                content: localization.translate('pp_international_users_content'),
              ),

              _buildSection(
                title: localization.translate('pp_contact_us'),
                content: localization.translate('pp_contact_us_content'),
              ),

              const SizedBox(height: 32),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.security, color: Colors.blue, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      localization.translate('pp_your_privacy_matters'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localization.translate('pp_commitment_message'),
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
              color: Colors.blue,
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

  Widget _buildSubSection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}