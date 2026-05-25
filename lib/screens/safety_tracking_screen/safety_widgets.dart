import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import 'safety_utils.dart';

// ============================================================================
// SAFETY HEADER
// ============================================================================
class SafetyHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const SafetyHeader({Key? key, this.onBackPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              if (onBackPressed != null) {
                onBackPressed!();
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
                  'Safety Tracking',
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
                    Icon(Icons.shield, size: 16, color: Colors.white70),
                    SizedBox(width: 6),
                    Text(
                      'Share your location for safety',
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
    );
  }
}

// ============================================================================
// TRACKING STATUS CARD
// ============================================================================
class TrackingStatusCard extends StatelessWidget {
  final bool isTracking;
  final int elapsedSeconds;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const TrackingStatusCard({
    Key? key,
    required this.isTracking,
    required this.elapsedSeconds,
    required this.onStart,
    required this.onStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isTracking
                    ? [Colors.green[400]!, Colors.green[600]!]
                    : [Colors.red[300]!, Colors.red[500]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isTracking ? Colors.green : Colors.red).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              isTracking ? Icons.shield : Icons.shield_outlined,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isTracking ? 'Tracking Active' : 'Not Tracking',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isTracking ? Colors.green[700] : Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          if (isTracking) ...[
            Text(
              SafetyUtils.formatDuration(elapsedSeconds),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isTracking ? onStop : onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: isTracking ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 8,
                shadowColor: (isTracking ? Colors.red : Colors.green).withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isTracking ? Icons.stop : Icons.play_arrow, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    isTracking ? 'Stop Tracking' : 'Start Tracking',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// INFO CARD (Reusable for Contact and Message)
// ============================================================================
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const InfoCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EMERGENCY ALERT SECTION
// ============================================================================
class EmergencyAlertSection extends StatelessWidget {
  final VoidCallback onSendAlert;

  const EmergencyAlertSection({Key? key, required this.onSendAlert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[400]!, Colors.red[600]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text(
            'EMERGENCY ALERT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send your location to emergency contact',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSendAlert,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 24),
                  SizedBox(width: 8),
                  Text('Send Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CURRENT LOCATION CARD
// ============================================================================
class CurrentLocationCard extends StatelessWidget {
  final LocationService locationService;

  const CurrentLocationCard({Key? key, required this.locationService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.withOpacity(0.2), Colors.red.withOpacity(0.3)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.my_location, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Current Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locationService.currentAddress ?? 'Loading address...',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.pin_drop, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${locationService.currentPosition!.latitude.toStringAsFixed(6)}, ${locationService.currentPosition!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// INFO SECTION
// ============================================================================
class InfoSection extends StatelessWidget {
  const InfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'How it works',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('1. Set your emergency contact'),
          _buildInfoRow('2. Start tracking when traveling'),
          _buildInfoRow('3. Send alert if you need help'),
          _buildInfoRow('4. Your location will be shared'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.red[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.red[900], fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}