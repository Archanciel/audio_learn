/// Contains the title local key and content local key of a help item.
/// 
/// The local key is the key of the element of the help item defined
/// in the app_en.arb or app_fr.arb localization files.
class HelpItem {
  final String titleLocalKey;
  final String contentLocalKey;

  HelpItem({
    required this.titleLocalKey,
    required this.contentLocalKey,
  });
}
