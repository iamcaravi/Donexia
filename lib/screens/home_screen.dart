import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/campaign.dart';
import '../services/app_state.dart';
import '../utils/theme.dart';
import '../widgets/campaign_card.dart';
import 'campaign_detail_screen.dart';
import 'explore_screen.dart';
import 'my_donations_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(onOpenCampaign: _openCampaign),
      const ExploreScreen(),
      const MyDonationsScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: DonexiaTheme.primary,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'My Donations',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, '/create-campaign'),
              backgroundColor: DonexiaTheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create Campaign',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  void _openCampaign(Campaign c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CampaignDetailScreen(campaign: c)),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final ValueChanged<Campaign> onOpenCampaign;
  const _HomeTab({required this.onOpenCampaign});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final name = state.user?.name.split(' ').first ?? 'दोस्त';
    final featured = state.publicCampaigns.take(3).toList();
    final recent = state.filtered(sort: 'recent').take(3).toList();
    final mostNeeded = state.filtered(sort: 'mostNeeded').take(3).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: DonexiaTheme.primary,
                child: Icon(Icons.volunteer_activism, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'नमस्ते, $name 👋',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      state.user?.district ?? 'Uttar Pradesh',
                      style: const TextStyle(color: DonexiaTheme.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: state.toggleLocale,
                icon: const Icon(Icons.language),
                tooltip: 'हिंदी / English',
              ),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications (demo)')),
                ),
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            readOnly: true,
            onTap: () => Navigator.pushNamed(context, '/explore'),
            decoration: const InputDecoration(
              hintText: 'Search campaigns, places, needs…',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          _TotalsCard(state: state),
          const SizedBox(height: 16),
          const Text(
            'Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _categoryTile(
                context,
                Icons.account_balance,
                'Loan Relief',
                CampaignCategory.loan,
              ),
              _categoryTile(
                context,
                Icons.local_hospital,
                'Medical Help',
                CampaignCategory.medical,
              ),
              _categoryTile(
                context,
                Icons.school,
                'Education',
                CampaignCategory.education,
              ),
              _categoryTile(
                context,
                Icons.warning_amber,
                'Emergency',
                CampaignCategory.emergency,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _section(context, 'Featured Campaigns', featured),
          _section(context, 'Recently Added', recent),
          _section(context, 'Most Needed', mostNeeded),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _categoryTile(
    BuildContext context,
    IconData icon,
    String label,
    CampaignCategory category,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExploreScreen(initialCategory: category),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DonexiaTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: DonexiaTheme.primary, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    List<Campaign> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/explore'),
              child: const Text('See All'),
            ),
          ],
        ),
        ...items.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CampaignCard(campaign: c, onTap: () => onOpenCampaign(c)),
          ),
        ),
      ],
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final AppState state;
  const _TotalsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DonexiaTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(inr(state.totalRaised), 'Total raised'),
          _stat('${state.totalDonors}', 'Donors'),
          _stat('${state.totalBeneficiaries}', 'Campaigns live'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ],
  );
}
