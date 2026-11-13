import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../widgets/campaign_card.dart';

class MyDonationsScreen extends StatelessWidget {
  const MyDonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final donations = state.donations;
    final total = donations.fold<double>(0, (s, d) => s + d.amount);
    return Scaffold(
      appBar: AppBar(title: const Text('My Donations')),
      body: donations.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'You have not donated yet.\nExplore campaigns and make your first donation.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat(inr(total), 'Total donated'),
                        _stat('${donations.length}', 'Donations'),
                        _stat(
                          inr(
                            donations.fold<double>(
                              0,
                              (s, d) => s + d.platformFee,
                            ),
                          ),
                          'Platform fees (1%)',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...donations.map(
                  (d) => Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.volunteer_activism,
                        color: Colors.green,
                      ),
                      title: Text(d.campaignTitle),
                      subtitle: Text(
                        '${d.receiptId} • ${d.method} • ${d.createdAt.toLocal().toString().split(' ').first}',
                      ),
                      trailing: Text(
                        inr(d.amount),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _stat(String value, String label) => Column(
    children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ],
  );
}
