import 'package:material_ui/material_ui.dart';

import '../utils/theme.dart';

class CampaignProgressBar extends StatelessWidget {
  final double progress; // 0..1
  final double height;
  const CampaignProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress.clamp(0, 1),
        minHeight: height,
        backgroundColor: Colors.grey.shade200,
        valueColor: const AlwaysStoppedAnimation<Color>(
          DonexiaTheme.primary,
        ),
      ),
    );
  }
}

/// Green demo banner — shown on auth / donation screens so nobody
/// mistakes the demo for a real payment or SMS flow.
class DemoBanner extends StatelessWidget {
  final String text;
  const DemoBanner({super.key, this.text = 'DEMO — no real money, no real SMS'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DonexiaTheme.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DonexiaTheme.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF92400E)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
