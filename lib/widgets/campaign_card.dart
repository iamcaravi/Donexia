import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../models/campaign.dart';
import '../utils/theme.dart';
import 'progress_bar.dart';

String inr(double amount) =>
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
        .format(amount);

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onTap;
  const CampaignCard({super.key, required this.campaign, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  campaign.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => Container(
                    height: 150,
                    color: DonexiaTheme.surface,
                    child: const Icon(
                      Icons.volunteer_activism,
                      size: 48,
                      color: DonexiaTheme.primary,
                    ),
                  ),
                ),
                if (campaign.verified)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DonexiaTheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      campaign.category.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${campaign.beneficiaryName} • ${campaign.city}, ${campaign.state}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: DonexiaTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CampaignProgressBar(progress: campaign.progress),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${inr(campaign.raisedAmount)} raised',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${campaign.progressPercent}% • ${campaign.daysLeft} days left',
                        style: const TextStyle(
                          fontSize: 12,
                          color: DonexiaTheme.muted,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Target ${inr(campaign.targetAmount)} • ${campaign.donorCount} donors',
                    style: const TextStyle(
                      fontSize: 12,
                      color: DonexiaTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal category chip row used on Home + Explore.
class CategoryChips extends StatelessWidget {
  final CampaignCategory? selected;
  final ValueChanged<CampaignCategory?> onSelected;
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(CampaignCategory?, String, IconData)>[
      (null, 'All', Icons.grid_view),
      (CampaignCategory.loan, 'Loan Relief', Icons.account_balance),
      (CampaignCategory.medical, 'Medical Help', Icons.local_hospital),
      (CampaignCategory.education, 'Education', Icons.school),
      (CampaignCategory.emergency, 'Emergency', Icons.warning_amber),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final isSel = selected == item.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(item.$2),
              avatar: Icon(item.$3, size: 16),
              selected: isSel,
              onSelected: (_) => onSelected(item.$1),
              selectedColor: DonexiaTheme.primary,
              labelStyle: TextStyle(
                color: isSel ? Colors.white : DonexiaTheme.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
