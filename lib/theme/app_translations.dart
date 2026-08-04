class AppTranslations {
  static String tr(String lang, String khmerText, String englishText) {
    return lang == 'Khmer' ? khmerText : englishText;
  }
}
