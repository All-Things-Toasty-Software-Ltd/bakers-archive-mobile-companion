import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/bread_colors.dart';
import '../providers/auth_provider.dart';

/// Status pill displaying current Odoo server connectivity.
class ServerStatusBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const ServerStatusBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isTesting = auth.isTestingConnection;
    final res = auth.connectionResult;

    Color indicatorColor;
    String statusText;

    if (isTesting) {
      indicatorColor = BreadColors.butterYellow;
      statusText = "Connecting...";
    } else if (res == null) {
      indicatorColor = BreadColors.butterYellow;
      statusText = "Checking...";
    } else if (res.success && res.hasBakersArchive) {
      indicatorColor = BreadColors.yeastGreen;
      // Show clean host name
      final uri = Uri.tryParse(auth.serverUrl);
      statusText = uri?.host ?? "Connected";
    } else if (res.success) {
      indicatorColor = BreadColors.warmAmber;
      statusText = "Odoo Connected";
    } else {
      indicatorColor = BreadColors.ovenRed;
      statusText = "Offline";
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: indicatorColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: indicatorColor.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: indicatorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
