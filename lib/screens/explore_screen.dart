import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/campaign.dart';
import '../services/app_state.dart';
import '../widgets/campaign_card.dart';
import 'campaign_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final CampaignCategory? initialCategory;
  const ExploreScreen({super.key, this.initialCategory});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  CampaignCategory? _category;
  String _query = '';
  String? _stateFilter;
  String? _districtFilter;
  bool _verifiedOnly = false;
  String _sort = 'recent';

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final results = state.filtered(
      category: _category,
      query: _query,
      state: _stateFilter,
      district: _districtFilter,
      verifiedOnly: _verifiedOnly,
      sort: _sort,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Campaigns')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Search campaigns…',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                CategoryChips(
                  selected: _category,
                  onSelected: (c) => setState(() => _category = c),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _stateFilter,
                        hint: const Text('State'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Uttar Pradesh',
                            child: Text('Uttar Pradesh'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _stateFilter = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _districtFilter,
                        hint: const Text('District'),
                        items:
                            const [
                                  'Kanpur Nagar',
                                  'Lucknow',
                                  'Varanasi',
                                  'Agra',
                                  'Gorakhpur',
                                  'Prayagraj',
                                  'Jhansi',
                                ]
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) =>
                            setState(() => _districtFilter = v),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Verified only'),
                      selected: _verifiedOnly,
                      onSelected: (v) =>
                          setState(() => _verifiedOnly = v),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _sort,
                      items: const [
                        DropdownMenuItem(
                          value: 'recent',
                          child: Text('Recently Added'),
                        ),
                        DropdownMenuItem(
                          value: 'mostNeeded',
                          child: Text('Most Needed'),
                        ),
                        DropdownMenuItem(
                          value: 'mostRaised',
                          child: Text('Most Raised'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _sort = v!),
                    ),
                    const Spacer(),
                    Text('${results.length} results'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No campaigns match the filters.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: results.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CampaignCard(
                        campaign: results[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CampaignDetailScreen(campaign: results[i]),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
