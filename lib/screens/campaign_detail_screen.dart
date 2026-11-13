import 'package:material_ui/material_ui.dart';

import '../models/campaign.dart';
import '../utils/theme.dart';
import '../widgets/campaign_card.dart';
import '../widgets/progress_bar.dart';
import 'donate_screen.dart';

/// Campaign details.
/// PRIVACY: never shows loan/bank account numbers, Aadhaar, PAN, or
/// private medical documents — those live only in the private
/// PaymentDestination / admin verification views.
class CampaignDetailScreen extends StatelessWidget {
  final Campaign campaign;
  const CampaignDetailScreen({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share link copied (demo).'),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              campaign.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => Container(
                height: 220,
                color: DonexiaTheme.surface,
                child: const Icon(
                  Icons.volunteer_activism,
                  size: 56,
                  color: DonexiaTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Chip(label: Text(campaign.category.label)),
              const SizedBox(width: 8),
              if (campaign.verified)
                const Chip(
                  label: Text('✓ Verified'),
                  backgroundColor: DonexiaTheme.surface,
                ),
              const Spacer(),
              Chip(label: Text(campaign.status.label)),
            ],
          ),
          Text(
            campaign.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${campaign.beneficiaryName} • ${campaign.city}, ${campaign.district}, ${campaign.state}',
            style: const TextStyle(color: DonexiaTheme.muted),
          ),
          const SizedBox(height: 16),
          CampaignProgressBar(progress: campaign.progress, height: 10),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _amount(inr(campaign.raisedAmount), 'Raised'),
              _amount(inr(campaign.targetAmount), 'Target'),
              _amount(inr(campaign.remaining), 'Remaining'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${campaign.donorCount} donors • ${campaign.daysLeft} days left • ${campaign.progressPercent}% funded',
            style: const TextStyle(color: DonexiaTheme.muted),
          ),
          const SizedBox(height: 20),
          const Text(
            'Story',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(campaign.story, style: const TextStyle(height: 1.5)),
          if (campaign.updates.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Updates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            ...campaign.updates.map(
              (u) => ListTile(
                leading: const Icon(
                  Icons.update,
                  color: DonexiaTheme.primary,
                ),
                title: Text(u),
              ),
            ),
          ],
          const SizedBox(height: 20),
          const DemoBanner(
            text:
                'Privacy: account numbers, Aadhaar, PAN & medical documents are never shown here.',
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DonateScreen(campaign: campaign),
            ),
          ),
          child: const Text('Donate Now'),
        ),
      ),
    );
  }

  Widget _amount(String value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: DonexiaTheme.muted)),
    ],
  );
}
