import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/bread_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/archive_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';

/// Settings screen for configuring Odoo servers, single-db resolution, authentication, and theme.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _serverController;
  late TextEditingController _dbController;

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showLoginForm = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _serverController = TextEditingController(text: auth.serverUrl);
    _dbController = TextEditingController(text: auth.database);
  }

  @override
  void dispose() {
    _serverController.dispose();
    _dbController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _saveServerUrl() async {
    final auth = context.read<AuthProvider>();
    final archiveProv = context.read<ArchiveProvider>();
    final newUrl = _serverController.text.trim();

    final success = await auth.setServerUrl(newUrl);
    if (!mounted) return;

    if (success) {
      archiveProv.loadArchives(auth.serverUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server updated to ${auth.serverUrl} and archives refreshed.'),
          backgroundColor: BreadColors.yeastGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.connectionResult?.message ?? 'Could not connect to server.'),
          backgroundColor: BreadColors.ovenRed,
        ),
      );
    }
  }

  void _submitLogin() async {
    final auth = context.read<AuthProvider>();
    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username/email and password.')),
      );
      return;
    }

    final success = await auth.signIn(login, password);
    if (!mounted) return;

    if (success) {
      setState(() => _showLoginForm = false);
      _loginController.clear();
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${auth.currentUser?.name}!'),
          backgroundColor: BreadColors.yeastGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.authError ?? 'Authentication failed.'),
          backgroundColor: BreadColors.ovenRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final favProv = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Odoo Server Configuration Card
          _buildSectionHeader(theme, 'Odoo Server & Deployment'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _serverController,
                    decoration: InputDecoration(
                      labelText: 'Server Host URL',
                      helperText: 'Default: ${AppConstants.defaultServerUrl}',
                      prefixIcon: const Icon(Icons.dns_rounded),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        tooltip: 'Apply Server',
                        onPressed: _saveServerUrl,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Single database detection explanation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BreadColors.crustGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: BreadColors.crustGold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: BreadColors.crustGoldDark),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Single Database Mode is active: servers with 'list_db = False' in odoo.conf (like austinatts.co.uk) are handled automatically without requiring a database selection modal.",
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: isDark ? BreadColors.textLightSecondary : BreadColors.textDarkSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Test Connection Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: auth.isTestingConnection
                            ? null
                            : () => auth.testConnection(_serverController.text),
                        icon: auth.isTestingConnection
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.network_check_rounded, size: 18),
                        label: const Text('Test Connection'),
                      ),
                      if (auth.connectionResult != null)
                        Text(
                          auth.connectionResult!.success ? '● Reached' : '● Failed',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: auth.connectionResult!.success
                                ? BreadColors.yeastGreen
                                : BreadColors.ovenRed,
                          ),
                        ),
                    ],
                  ),

                  if (auth.connectionResult != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      auth.connectionResult!.message +
                          (auth.connectionResult!.latencyMs != null
                              ? ' (${auth.connectionResult!.latencyMs} ms)'
                              : ''),
                      style: TextStyle(
                        fontSize: 12,
                        color: auth.connectionResult!.success
                            ? BreadColors.yeastGreen
                            : BreadColors.ovenRed,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Authentication Card (Public / Guest vs Signed In)
          _buildSectionHeader(theme, 'Odoo User Account'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: auth.isAuthenticated
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: BreadColors.crustGold.withValues(alpha: 0.2),
                              backgroundImage: (auth.currentUser?.avatarUrl != null)
                                  ? NetworkImage(auth.currentUser!.avatarUrl!)
                                  : null,
                              child: auth.currentUser?.avatarUrl == null
                                  ? FaIcon(FontAwesomeIcons.user, color: BreadColors.crustGoldDark)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    auth.currentUser!.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    auth.currentUser!.username,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted,
                                    ),
                                  ),
                                  if (auth.currentUser!.isAdmin)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: BreadColors.crustGoldDark,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Administrator',
                                        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => auth.signOut(),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(foregroundColor: BreadColors.ovenRed),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.public, color: BreadColors.crustGoldDark, size: 24),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Public Guest Mode',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    'Browsing public archives and recipes freely.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (!_showLoginForm)
                          OutlinedButton.icon(
                            onPressed: () => setState(() => _showLoginForm = true),
                            icon: const Icon(Icons.login, size: 18),
                            label: const Text('Sign in as Admin / Odoo User'),
                          )
                        else ...[
                          const Divider(height: 24),
                          TextField(
                            controller: _loginController,
                            decoration: const InputDecoration(
                              labelText: 'Username or Email',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: auth.isAuthenticating ? null : _submitLogin,
                                child: auth.isAuthenticating
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Sign In'),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () => setState(() => _showLoginForm = false),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Theme & Appearance
          _buildSectionHeader(theme, 'Appearance Theme'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: RadioGroup<String>(
                groupValue: themeProv.currentMode,
                onChanged: (val) {
                  if (val != null) themeProv.setMode(val);
                },
                child: const Column(
                  children: [
                    RadioListTile<String>(
                      title: Text('Warm Crust (Artisan Light)'),
                      subtitle: Text('Warm sourdough cream with toasted crust accents'),
                      value: 'warm_crust',
                      activeColor: BreadColors.crustGoldDark,
                    ),
                    Divider(height: 1),
                    RadioListTile<String>(
                      title: Text('Dark Toast (Oven Dark)'),
                      subtitle: Text('Charcoal espresso with roasted honey highlights'),
                      value: 'dark_toast',
                      activeColor: BreadColors.crustGoldDark,
                    ),
                    Divider(height: 1),
                    RadioListTile<String>(
                      title: Text('System Default'),
                      value: 'system',
                      activeColor: BreadColors.crustGoldDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 4. Offline Storage Management
          _buildSectionHeader(theme, 'Offline Storage'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Offline Saved Recipes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '${favProv.favorites.length} recipe${favProv.favorites.length == 1 ? '' : 's'} cached locally',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted,
                        ),
                      ),
                    ],
                  ),
                  if (favProv.favorites.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        for (final r in favProv.favorites) {
                          favProv.removeFavorite(r.id);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cleared all offline saved recipes.')),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: BreadColors.ovenRed),
                      child: const Text('Clear All'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 5. About Toasty Software
          _buildSectionHeader(theme, 'About'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.breadSlice, color: BreadColors.crustGoldDark, size: 28),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Version ${AppConstants.appVersion}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? BreadColors.textLightMuted : BreadColors.textDarkMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Created as a mobile companion for The Baker\'s Archive Odoo module. Owned and maintained by All Things Toasty Software Ltd.',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _launchUrl(AppConstants.toastyWebsiteUrl),
                        icon: const Icon(Icons.language, size: 16),
                        label: const Text('Toasty Software'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _launchUrl(AppConstants.austinattsUrl),
                        icon: const Icon(Icons.open_in_browser, size: 16),
                        label: const Text('Austin ATTS'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _launchUrl(AppConstants.githubRepoUrl),
                        icon: const FaIcon(FontAwesomeIcons.github, size: 16),
                        label: const Text('GitHub Module'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: BreadColors.crustGoldDark,
        ),
      ),
    );
  }
}
