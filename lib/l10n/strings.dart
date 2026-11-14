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
  // One-time registration fee — Loan, Education & Emergency (₹99).
  // Medical campaigns are free.
  String get registrationFeeTitle =>
      isHi
          ? 'रजिस्ट्रेशन फीस — ₹99 (सिर्फ़ एक बार)'
          : 'One-time registration fee ₹99';
  String get registrationFeeInfo =>
      isHi
          ? 'लोन, पढ़ाई और आपात मदद वाले अभियान के लिए एक बार ₹99 रजिस्ट्रेशन फीस लगती है। ये फीस सिर्फ़ एक बार देनी है और वापस नहीं होगी। इलाज वाले अभियान बिल्कुल मुफ़्त हैं।'
          : 'Loan Relief, Education and Emergency campaigns need a one-time ₹99 registration fee. It is charged only once and is non-refundable. Medical campaigns are completely free.';
  String get registrationFee =>
      isHi ? 'रजिस्ट्रेशन फीस' : 'Registration fee';
  String get total => isHi ? 'कुल' : 'Total';
  String get payFeeDemo => isHi ? '₹99 दें (Demo)' : 'Pay ₹99 (Demo)';
  String get feePaymentDemoNote =>
      isHi
          ? 'डेमो पेमेंट — असली पैसे नहीं कटेंगे।'
          : 'Demo payment — no real money is charged.';
  String get registrationFeePaid =>
      isHi ? '₹99 रजिस्ट्रेशन फीस दी गई' : '₹99 registration fee paid';
  String get feePaidSuccess =>
      isHi
          ? 'फीस मिल गई! (Demo) अब आप अभियान जमा कर सकते हैं।'
          : 'Fee received! (Demo) You can now submit your campaign.';
  String get feeRequired =>
      isHi
          ? 'आगे बढ़ने से पहले ₹99 रजिस्ट्रेशन फीस दें।'
          : 'Please pay the ₹99 registration fee to continue.';
  String get adminPanel => isHi ? 'एडमिन पैनल' : 'Admin Panel';
  String get loanRelief => isHi ? 'लोन में मदद' : 'Loan Relief';
  String get medicalHelp => isHi ? 'इलाज के लिए' : 'Medical Help';
  String get education => isHi ? 'पढ़ाई में मदद' : 'Education';
  String get emergency => isHi ? 'आपात मदद' : 'Emergency';
}
