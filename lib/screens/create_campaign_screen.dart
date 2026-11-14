import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../models/campaign.dart';
import '../services/app_state.dart';
import '../widgets/progress_bar.dart';

/// 6-step campaign creation wizard (7 when a registration fee applies):
/// 1 Category · 2 Personal info · 3 Category form · 4 Payment destination
/// (private) · 5 Preview/edit · 6 Registration fee (₹99 one-time, demo
/// payment — Loan, Education & Emergency; Medical is free) · 7 Consent
/// & submit.
/// Payment details are kept private — never rendered on public screens.
class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  int _step = 0;
  CampaignCategory _category = CampaignCategory.loan;
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _city = TextEditingController();
  final String _state = 'Uttar Pradesh';
  String _district = 'Kanpur Nagar';
  final _title = TextEditingController();
  final _story = TextEditingController();
  final _target = TextEditingController();
  String _loanType = 'Personal Loan';
  String _bank = 'SBI';
  final _outstanding = TextEditingController();
  final _emi = TextEditingController();
  final _hospital = TextEditingController();
  final _disease = TextEditingController();
  final _school = TextEditingController();
  final _fees = TextEditingController();
  final _emergencyType = TextEditingController();
  final _upiId = TextEditingController();
  final _accountHolder = TextEditingController();
  bool _consent = false;
  String? _error;
  // ₹99 one-time registration fee — Loan, Education & Emergency.
  // Medical campaigns are free. Demo payment (no real money),
  // same pattern as the demo donation.
  bool _feePaid = false;
  String? _feeTxnId;
  bool _feeProcessing = false;

  /// Step index of the registration-fee step (all but Medical), or null.
  int? get _feeStepIndex =>
      _category.requiresRegistrationFee ? 5 : null;
  int get _lastStepIndex =>
      _category.requiresRegistrationFee ? 6 : 5;

  Future<void> _payFee() async {
    setState(() => _feeProcessing = true);
    await Future.delayed(const Duration(seconds: 1)); // demo processing
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      _feeProcessing = false;
      _feePaid = true;
      _feeTxnId =
          'DNXRF${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 100000}';
    });
  }

  List<Step> _steps(BuildContext context) {
    final state = context.watch<AppState>();
    final strings = Strings.of(state.locale.languageCode);
    final banks = state.banks
        .where((b) => b.active)
        .map((b) => b.name)
        .toList();
    return [
      Step(
        title: const Text('Category'),
        isActive: _step >= 0,
        content: RadioGroup<CampaignCategory>(
          groupValue: _category,
          onChanged: (v) => setState(() {
            _category = v!;
            // Switching to Medical? The fee step disappears and no
            // fee applies. Switching between Loan / Education /
            // Emergency keeps an already-paid fee.
            if (!_category.requiresRegistrationFee) {
              _feePaid = false;
              _feeTxnId = null;
            }
            if (_step > _lastStepIndex) _step = _lastStepIndex;
          }),
          child: Column(
            children: CampaignCategory.values
                .map(
                  (c) => RadioListTile<CampaignCategory>(
                    title: Text(c.label),
                    value: c,
                  ),
                )
                .toList(),
          ),
        ),
      ),
      Step(
        title: const Text('Personal Info'),
        isActive: _step >= 1,
        content: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'City *'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _district,
              decoration: const InputDecoration(labelText: 'District'),
              items: const [
                'Kanpur Nagar',
                'Lucknow',
                'Varanasi',
                'Agra',
                'Gorakhpur',
                'Prayagraj',
                'Jhansi',
              ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => _district = v!),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.photo_camera),
              label: const Text('Profile photo (optional, demo)'),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Details'),
        isActive: _step >= 2,
        content: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Campaign title *',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _target,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Requested donation amount (₹) *',
              ),
            ),
            const SizedBox(height: 12),
            if (_category == CampaignCategory.loan) ...[
              DropdownButtonFormField<String>(
                initialValue: _loanType,
                decoration: const InputDecoration(labelText: 'Loan type'),
                items:
                    const [
                          'Personal Loan',
                          'Home Loan',
                          'Education Loan',
                          'Business Loan',
                          'Vehicle Loan',
                          'Other',
                        ]
                        .map(
                          (t) => DropdownMenuItem(value: t, child: Text(t)),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _loanType = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: banks.contains(_bank) ? _bank : banks.first,
                decoration: const InputDecoration(labelText: 'Bank / NBFC'),
                items: banks
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setState(() => _bank = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _outstanding,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Outstanding loan amount (₹)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emi,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly EMI (₹)',
                ),
              ),
            ],
            if (_category == CampaignCategory.medical) ...[
              TextField(
                controller: _disease,
                decoration: const InputDecoration(labelText: 'Disease'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hospital,
                decoration: const InputDecoration(
                  labelText: 'Hospital name',
                ),
              ),
            ],
            if (_category == CampaignCategory.education) ...[
              TextField(
                controller: _school,
                decoration: const InputDecoration(
                  labelText: 'School / College',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fees,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pending fees (₹)',
                ),
              ),
            ],
            if (_category == CampaignCategory.emergency) ...[
              TextField(
                controller: _emergencyType,
                decoration: const InputDecoration(labelText: 'Emergency type'),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _story,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your story *',
              ),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Payment (Private)'),
        isActive: _step >= 3,
        content: Column(
          children: [
            const DemoBanner(
              text:
                  'PRIVATE — UPI / bank details are for verification & payout only. Never shown publicly.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _upiId,
              decoration: const InputDecoration(labelText: 'UPI ID'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _accountHolder,
              decoration: const InputDecoration(
                labelText: 'Bank account holder name',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Demo: account numbers are not collected in full in this MVP.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Preview'),
        isActive: _step >= 4,
        content: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title.text.isEmpty ? '(No title yet)' : _title.text,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text('${_name.text} • ${_city.text}, $_district'),
                Text('Category: ${_category.label}'),
                Text('Target: ₹${_target.text.isEmpty ? '0' : _target.text}'),
                const SizedBox(height: 8),
                Text(_story.text),
                const SizedBox(height: 8),
                const Text(
                  'Tap Back to edit any step.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
      if (_category.requiresRegistrationFee)
        Step(
          title: const Text('Registration Fee'),
          isActive: _step >= 5,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DemoBanner(text: strings.feePaymentDemoNote),
              const SizedBox(height: 12),
              Text(
                strings.registrationFeeTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(strings.registrationFeeInfo),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(strings.registrationFee),
                          const Text(
                            '₹99',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            strings.total,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            '₹99',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_feePaid) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(strings.feePaidSuccess)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Txn ID: ${_feeTxnId ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _feeProcessing ? null : _payFee,
                    child: _feeProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(strings.payFeeDemo),
                  ),
                ),
            ],
          ),
        ),
      Step(
        title: const Text('Consent & Submit'),
        isActive: _step >= _lastStepIndex,
        content: Column(
          children: [
            CheckboxListTile(
              value: _consent,
              onChanged: (v) => setState(() => _consent = v ?? false),
              title: const Text(
                'I confirm the details are true and I consent to verification of my documents by Donexia admin.',
              ),
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ];
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _title.text.trim().isEmpty ||
        _story.text.trim().isEmpty ||
        double.tryParse(_target.text) == null) {
      setState(
        () => _error = 'Please fill name, title, story and a valid target amount.',
      );
      return;
    }
    if (!_consent) {
      setState(() => _error = 'Please accept the consent checkbox.');
      return;
    }
    // Loan / Education / Emergency need the ₹99 one-time
    // registration fee first. Medical is free.
    final needsFee = _category.requiresRegistrationFee;
    if (needsFee && !_feePaid) {
      setState(
        () => _error =
            'Please pay the ₹99 one-time registration fee (Demo) before submitting.',
      );
      return;
    }
    final campaign = Campaign(
      id: 'cmp_${DateTime.now().millisecondsSinceEpoch}',
      title: _title.text.trim(),
      beneficiaryName: _name.text.trim(),
      city: _city.text.trim().isEmpty ? _district : _city.text.trim(),
      state: _state,
      district: _district,
      category: _category,
      status: CampaignStatus.pending,
      verified: false,
      targetAmount: double.parse(_target.text),
      raisedAmount: 0,
      donorCount: 0,
      story: _story.text.trim(),
      imageUrl: 'https://picsum.photos/seed/donexia-new/800/500',
      createdAt: DateTime.now(),
      daysLeft: 30,
      registrationFeePaid: needsFee && _feePaid,
      registrationFeeAmount:
          needsFee ? Campaign.registrationFee : 0,
      registrationTxnId: needsFee ? _feeTxnId : null,
    );
    await context.read<AppState>().submitCampaign(campaign);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Campaign submitted for admin verification.'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Campaign')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () {
          // Can't leave the fee step until the demo fee is paid.
          if (_feeStepIndex != null &&
              _step == _feeStepIndex &&
              !_feePaid) {
            final strings = Strings.of(
              context.read<AppState>().locale.languageCode,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.feeRequired)),
            );
            return;
          }
          if (_step < steps.length - 1) {
            setState(() => _step++);
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_step > 0) setState(() => _step--);
        },
        onStepTapped: (i) => setState(() => _step = i),
        steps: steps,
      ),
    );
  }
}
