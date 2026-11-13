/// Minimal Hindi / English strings (no generated l10n — plain maps so
/// the scaffold compiles without `flutter gen-l10n`).
/// Usage: Strings.of(locale).appName
class Strings {
  final String lang; // 'en' | 'hi'
  const Strings(this.lang);
  bool get isHi => lang == 'hi';

  static Strings of(String lang) => Strings(lang);

  String get appName => 'Donexia';
  String get tagline =>
      isHi ? 'एक छोटी मदद। एक बड़ा बदलाव।' : 'A Small Help. A Big Difference.';
  String get getStarted => isHi ? 'शुरू करें' : 'Get Started';
  String get next => isHi ? 'आगे' : 'Next';
  String get skip => isHi ? 'छोड़ें' : 'Skip';
  String get loginRegister => isHi ? 'लॉगिन / रजिस्टर' : 'Login / Register';
  String get home => isHi ? 'होम' : 'Home';
  String get explore => isHi ? 'खोजें' : 'Explore';
  String get myDonations => isHi ? 'मेरे दान' : 'My Donations';
  String get profile => isHi ? 'प्रोफ़ाइल' : 'Profile';
  String get searchHint =>
      isHi ? 'अभियान, जगह या ज़रूरत खोजें' : 'Search campaigns, places, needs';
  String get createCampaign => isHi ? 'मदद के लिए अभियान बनाएं' : 'Create Campaign';
  String get featured => isHi ? 'चुनिंदा अभियान' : 'Featured Campaigns';
  String get recentlyAdded => isHi ? 'हाल ही में जुड़े' : 'Recently Added';
  String get mostNeeded => isHi ? 'सबसे ज़रूरी' : 'Most Needed';
  String get donateNow => isHi ? 'अभी दान करें' : 'Donate Now';
  String get verified => isHi ? 'सत्यापित' : 'Verified';
  String get raised => isHi ? 'जुटा' : 'Raised';
  String get target => isHi ? 'लक्ष्य' : 'Target';
  String get remaining => isHi ? 'बाकी' : 'Remaining';
  String get daysLeft => isHi ? 'दिन बाकी' : 'days left';
  String get donors => isHi ? 'दानदाता' : 'donors';
  String get demoOtpLabel =>
      isHi
          ? 'डेमो OTP — असली SMS नहीं भेजा जाता'
          : 'DEMO OTP — no real SMS is sent';
  String get platformFee =>
      isHi ? 'प्लेटफ़ॉर्म शुल्क (1%)' : 'Platform fee (1%)';
  String get adminPanel => isHi ? 'एडमिन पैनल' : 'Admin Panel';
  String get loanRelief => isHi ? 'लोन में मदद' : 'Loan Relief';
  String get medicalHelp => isHi ? 'इलाज के लिए' : 'Medical Help';
  String get education => isHi ? 'पढ़ाई में मदद' : 'Education';
  String get emergency => isHi ? 'आपात मदद' : 'Emergency';
}
