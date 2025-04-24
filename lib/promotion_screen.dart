import 'package:flutter/material.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  static const String routeName = '/promotion';

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Offers'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildPromotionCard(
            'Summer Sale!',
            '50% OFF on all items',
            'Valid until August 31st',
            Colors.orange,
            Icons.local_offer,
          ),
          const SizedBox(height: 16),
          _buildPromotionCard(
            'Flash Deal',
            'Buy 1 Get 1 Free',
            'Today Only!',
            Colors.green,
            Icons.flash_on,
          ),
          const SizedBox(height: 16),
          _buildInteractivePromo(),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(String title, String subtitle, String validity,
      Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            Text(
              validity,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            // Add your action here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Offer claimed!')),
            );
          },
          child: const Text('Claim'),
        ),
      ),
    );
  }

  Widget _buildInteractivePromo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade300, Colors.purple.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Special Membership Offer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Get 3 months free premium membership!',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Add your action here
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Subscription'),
                  content:
                      const Text('Would you like to activate your free trial?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Trial activated!')),
                        );
                      },
                      child: const Text('Activate'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.card_giftcard),
            label: const Text('Activate Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
}
