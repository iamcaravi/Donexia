import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/campaign.dart';
import '../models/user.dart';
import '../services/app_state.dart';
import '../utils/theme.dart';
import '../widgets/campaign_card.dart';
import '../widgets/progress_bar.dart';

/// Donation flow — DEMO payments only. 1% platform fee is calculated
/// and shown transparently. No real money moves.
class DonateScreen extends StatefulWidget {
  final Campaign campaign;
  const DonateScreen({super.key, required this.campaign});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  double _amount = 100;
  final _customController = TextEditingController();
  String _method = 'UPI';
  bool _processing = false;
  Donation? _done;

  double get _fee => Donation.feeFor(_amount);
  double get _toBeneficiary => _amount - _fee;

  Future<void> _pay() async {
    if (_amount < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum donation is ₹10.')),
      );
      return;
    }
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 1)); // demo processing
    if (!mounted) return;
    final state = context.read<AppState>();
    final donation = Donation.create(
      campaignId: widget.campaign.id,
      campaignTitle: widget.campaign.title,
      donorName: state.user?.name ?? 'Anonymous Donor',
      amount: _amount,
      method: '$_method (Demo)',
    );
    await state.addDonation(donation);
    setState(() {
      _processing = false;
      _done = donation;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done != null) return _success(context, _done!);
    return Scaffold(
      appBar: AppBar(title: const Text('Donate')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const DemoBanner(
            text: 'DEMO PAYMENT — no real money is charged. UPI / QR / Card / Net Banking are simulated.',
          ),
          const SizedBox(height: 16),
          Text(
            widget.campaign.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Text(
            '${widget.campaign.beneficiaryName} • ${widget.campaign.city}',
            style: const TextStyle(color: DonexiaTheme.muted),
          ),
          const SizedBox(height: 20),
          const Text('Choose amount'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [10, 50, 100, 500, 1000].map((a) {
              final sel = _amount == a.toDouble();
              return ChoiceChip(
                label: Text('₹$a'),
                selected: sel,
                onSelected: (_) => setState(() => _amount = a.toDouble()),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Other amount (₹)',
              hintText: 'Enter any amount',
            ),
            onChanged: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null) setState(() => _amount = parsed);
            },
          ),
          const SizedBox(height: 20),
          const Text('Payment method (demo)'),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: _method,
            onChanged: (v) => setState(() => _method = v!),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ['UPI', 'QR Code', 'Card', 'Net Banking']
                  .map(
                    (m) => RadioListTile<String>(
                      title: Text(m),
                      value: m,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row('Donation amount', inr(_amount)),
                  _row('Platform fee (1%)', inr(_fee)),
                  const Divider(),
                  _row(
                    'Beneficiary receives',
                    inr(_toBeneficiary),
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _processing ? null : _pay,
            child: _processing
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Pay ${inr(_amount)} (Demo)'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(fontWeight: bold ? FontWeight.w800 : null),
        ),
      ],
    ),
  );

  Widget _success(BuildContext context, Donation d) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donation Successful')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: DonexiaTheme.primary, size: 72),
            const SizedBox(height: 16),
            const Text(
              'दान सफल रहा!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            Text(
              'Thank you — your help brings hope to ${widget.campaign.beneficiaryName}.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Receipt ID', d.receiptId, bold: true),
                    _row('Campaign', d.campaignTitle),
                    _row('Amount', inr(d.amount)),
                    _row('Platform fee (1%)', inr(d.platformFee)),
                    _row('Beneficiary gets', inr(d.beneficiaryAmount), bold: true),
                    _row('Method', d.method),
                    _row('Date', d.createdAt.toLocal().toString().split('.').first),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.popUntil(
                context,
                (r) => r.isFirst,
              ),
              child: const Text('Back to Home'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receipt download (demo).')),
              ),
              child: const Text('Download / Share Receipt'),
            ),
          ],
        ),
      ),
    );
  }
}
