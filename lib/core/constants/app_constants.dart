/// Application-wide constants for The Baker's Archive Mobile Companion.
class AppConstants {
  AppConstants._();

  static const String appName = "The Baker's Archive";
  static const String appVersion = "1.0.0";
  static const String companyName = "All Things Toasty Software Ltd";

  // Default server
  static const String defaultServerUrl = "https://austinatts.co.uk";
  static const String defaultDatabase = "austinatts";

  // API Endpoints
  static const String apiArchivesPath = "/archive/api/v1/archives";
  static const String apiArchivePath = "/archive/api/v1/archive";
  static const String apiRecipePath = "/archive/api/v1/recipe";

  // Odoo Core Endpoints
  static const String odooVersionInfo = "/web/webclient/version_info";
  static const String odooLogin = "/web/login";
  static const String odooAuthenticate = "/web/session/authenticate";
  static const String odooSessionInfo = "/web/session/get_session_info";
  static const String odooDestroySession = "/web/session/destroy";

  // External Links
  static const String toastyWebsiteUrl = "https://toastysoftware.co.uk";
  static const String austinattsUrl = "https://austinatts.co.uk";
  static const String austinattsArchiveUrl = "https://austinatts.co.uk/archive";
  static const String githubRepoUrl = "https://github.com/All-Things-Toasty-Software-Ltd/bakers-archive-mobile-companion";

  // Storage Keys
  static const String prefServerUrl = "bakers_server_url";
  static const String prefDatabase = "bakers_database";
  static const String prefThemeMode = "bakers_theme_mode";
  static const String prefUserSession = "bakers_user_session";
  static const String prefFavorites = "bakers_local_favorites";
  static const String prefFavoritesData = "bakers_favorites_data_cache";
}
