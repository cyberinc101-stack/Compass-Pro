import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/premium_service.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({Key? key}) : super(key: key);

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  bool _isLoading = false;
  String? _selectedPlan; // 'monthly' | 'yearly'

  Future<void> _purchase(String plan) async {
    setState(() {
      _isLoading = true;
      _selectedPlan = plan;
    });

    final premiumService = Provider.of<PremiumService>(context, listen: false);
    bool success = false;

    if (plan == 'monthly') {
      success = await premiumService.purchaseMonthly();
    } else {
      success = await premiumService.purchaseYearly();
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorSnack();
      }
    }
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    final premiumService = Provider.of<PremiumService>(context, listen: false);
    final success = await premiumService.restorePurchases();
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Purchases restored successfully'
              : 'No purchases found to restore'),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a2a3a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4A90E2), size: 28),
            SizedBox(width: 12),
            Text('Welcome to Pro!',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
        content: const Text(
          'Ads have been removed. Enjoy Compass Safe Pro!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Continue',
                style: TextStyle(color: Color(0xFF4A90E2))),
          ),
        ],
      ),
    );
  }

  void _showErrorSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Purchase failed. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _subscribeButtonLabel() {
    if (_selectedPlan == null) return 'Select a Plan';
    if (_selectedPlan == 'monthly') return 'Subscribe — \$2.99/month';
    return 'Subscribe — \$8.99/year';
  }

  @override
  Widget build(BuildContext context) {
    final premiumService = context.watch<PremiumService>();
    final isPremium = premiumService.isPremium;

    return Scaffold(
      backgroundColor: const Color(0xFF0d1b2a),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0d1b2a),
                  Color(0xFF1a2a3a),
                  Color(0xFF0d1b2a),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Expanded(
                        child: Text(
                          'Upgrade to Pro',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Hero icon
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4A90E2).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.explore,
                              size: 56, color: Colors.white),
                        ),

                        const SizedBox(height: 24),

                        if (isPremium) ...[
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.green.withOpacity(0.4)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.verified,
                                    color: Colors.green, size: 48),
                                const SizedBox(height: 12),
                                const Text(
                                  'You\'re a Pro Member!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  premiumService.subscriptionType == 'yearly'
                                      ? 'Yearly plan active'
                                      : 'Monthly plan active',
                                  style: const TextStyle(
                                      color: Colors.green, fontSize: 15),
                                ),
                                if (premiumService.daysRemaining != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${premiumService.daysRemaining} days remaining',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Remove Ads & Go Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'One simple upgrade. No more interruptions.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 32),

                          _FeatureRow(
                            icon: Icons.block,
                            title: 'Remove All Ads',
                            subtitle: 'No banners, no video interruptions',
                            color: const Color(0xFF4A90E2),
                          ),
                          const SizedBox(height: 16),
                          _FeatureRow(
                            icon: Icons.explore,
                            title: 'Full Compass Experience',
                            subtitle: 'Clean, distraction-free navigation',
                            color: const Color(0xFF4A90E2),
                          ),
                          const SizedBox(height: 16),
                          _FeatureRow(
                            icon: Icons.analytics_rounded,
                            title: 'Unlock All Stats Cards',
                            subtitle: 'Speed, altitude, bearing, elevation & more',
                            color: const Color(0xFF4A90E2),
                          ),
                          const SizedBox(height: 16),
                          _FeatureRow(
                            icon: Icons.support_agent,
                            title: 'Priority Support',
                            subtitle: 'Get help when you need it',
                            color: const Color(0xFF4A90E2),
                          ),

                          const SizedBox(height: 36),

                          // Yearly — BEST VALUE
                          _PlanCard(
                            label: 'BEST VALUE',
                            title: 'Yearly',
                            price: '\$8.99',
                            period: '/year',
                            subtext: 'Just \$0.75/month — save 75%',
                            monthlyEquiv: '\$0.75/mo',
                            isSelected: _selectedPlan == 'yearly',
                            onTap: _isLoading ? null : () => _purchase('yearly'),
                          ),

                          const SizedBox(height: 12),

                          // Monthly
                          _PlanCard(
                            label: '',
                            title: 'Monthly',
                            price: '\$2.99',
                            period: '/month',
                            subtext: 'Cancel anytime',
                            monthlyEquiv: null,
                            isSelected: _selectedPlan == 'monthly',
                            onTap: _isLoading ? null : () => _purchase('monthly'),
                          ),

                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading || _selectedPlan == null
                                  ? null
                                  : () => _purchase(_selectedPlan!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                disabledBackgroundColor:
                                    const Color(0xFF4A90E2).withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 8,
                                shadowColor:
                                    const Color(0xFF4A90E2).withOpacity(0.5),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      _subscribeButtonLabel(),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: _isLoading ? null : _restore,
                            child: Text(
                              'Restore Purchases',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Subscriptions renew automatically. Cancel anytime in Google Play.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 11,
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 13)),
            ],
          ),
        ),
        Icon(Icons.check_circle, color: color, size: 20),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String label;
  final String title;
  final String price;
  final String period;
  final String subtext;
  final String? monthlyEquiv;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PlanCard({
    required this.label,
    required this.title,
    required this.price,
    required this.period,
    required this.subtext,
    required this.monthlyEquiv,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A90E2).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A90E2)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                    ),
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtext,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: price,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: period,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13)),
                    ],
                  ),
                ),
                if (monthlyEquiv != null)
                  Text(
                    monthlyEquiv!,
                    style: TextStyle(
                      color: const Color(0xFF4A90E2).withOpacity(0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4A90E2)
                      : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF4A90E2) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}