import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/bank.dart';
import '../models/campaign.dart';
import '../services/app_state.dart';
import '../widgets/campaign_card.dart';

/// Admin Panel — role-gated (only the demo admin login reaches here
/// via the route guard in main.dart). Approve / reject with reason,
/// request more info, manage banks/NBFCs, view users/transactions/
 /// complaints (demo) and analytics.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pending = state.pendingCampaigns;
    final totalFees = state.donations.fold<double>(
      0,
      (s, d) => s + d.platformFee,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Review'),
            Tab(text: 'Banks'),
            Tab(text: 'Transactions'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // 1 — Review campaigns
          pending.isEmpty
              ? const Center(child: Text('No campaigns pending review.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pending.length,
                  itemBuilder: (_, i) {
                    final c = pending[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${c.beneficiaryName} • ${c.city}, ${c.district} • ${c.category.label}',
                            ),
                            Text(c.story),
                            const SizedBox(height: 8),
                            Text(
                              'Status: ${c.status.label}',
                              style: const TextStyle(color: Colors.orange),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await state.setCampaignStatus(
                                      c.id,
                                      CampaignStatus.active,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Campaign approved & live.'),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Approve'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () => _rejectDialog(context, c),
                                  child: const Text('Reject'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () async {
                                    await state.setCampaignStatus(
                                      c.id,
                                      CampaignStatus.moreInfo,
                                    );
                                  },
                                  child: const Text('Request docs'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          // 2 — Banks / NBFC master list
          _BanksTab(state: state),
          // 3 — Transactions
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Total donations: ${state.donations.length} • Platform fees collected (demo): ${inr(totalFees)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...state.donations.map(
                (d) => ListTile(
                  title: Text(d.campaignTitle),
                  subtitle: Text('${d.receiptId} • ${d.method}'),
                  trailing: Text(inr(d.amount)),
                ),
              ),
              if (state.donations.isEmpty)
                const Text('No demo donations yet.'),
              const SizedBox(height: 16),
              const Text(
                'Complaints (demo): none open. Users: see Profile list in a full backend build.',
              ),
            ],
          ),
          // 4 — Analytics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total raised: ${inr(state.totalRaised)}'),
                Text('Total donors: ${state.totalDonors}'),
                Text('Live campaigns: ${state.totalBeneficiaries}'),
                Text('Pending review: ${pending.length}'),
                Text('Platform fees (1%, demo): ${inr(totalFees)}'),
                const SizedBox(height: 16),
                const Text(
                  'Full charts need a backend; these are live totals from the local demo store.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectDialog(BuildContext context, Campaign c) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject campaign'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason (required)',
            hintText: 'e.g. Documents unclear',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (reason == null || reason.trim().isEmpty) return;
    if (!context.mounted) return;
    await context.read<AppState>().setCampaignStatus(
      c.id,
      CampaignStatus.rejected,
      reason: reason.trim(),
    );
  }
}

class _BanksTab extends StatefulWidget {
  final AppState state;
  const _BanksTab({required this.state});

  @override
  State<_BanksTab> createState() => _BanksTabState();
}

class _BanksTabState extends State<_BanksTab> {
  @override
  Widget build(BuildContext context) {
    final banks = widget.state.banks;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: banks.length + 1,
      itemBuilder: (_, i) {
        if (i == banks.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: _addBank,
              icon: const Icon(Icons.add),
              label: const Text('Add bank / NBFC'),
            ),
          );
        }
        final b = banks[i];
        return SwitchListTile(
          title: Text(b.name),
          subtitle: Text(b.type),
          value: b.active,
          onChanged: (v) async {
            final next = List<Bank>.from(banks);
            next[i] = b.copyWith(active: v);
            await widget.state.saveBanks(next);
          },
        );
      },
    );
  }

  Future<void> _addBank() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add bank / NBFC'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final next = List<Bank>.from(widget.state.banks)
      ..add(
        Bank(
          id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
          name: name.trim(),
          type: 'Bank',
        ),
      );
    await widget.state.saveBanks(next);
  }
}
