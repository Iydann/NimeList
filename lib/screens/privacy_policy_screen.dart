import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const String privacyPolicyUrl =
      'https://iydann.github.io/NimeList/privacy-policy.html';
  static const String deleteAccountUrl =
      'https://iydann.github.io/NimeList/delete-account.html';
  static const String contactEmail = 'willy.iedans@gmail.com';

  const PrivacyPolicyScreen({super.key});

  Future<void> _copyText(
    BuildContext context,
    String label,
    String value,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied to clipboard.')));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    'NimeList Privacy Policy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const Text(
                    'Effective Date: November 27, 2026',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const Text(
                    'NimeList (com.iydain.nimelist), developed by Iydain (Willy), '
                    'only collects data needed to provide Google Sign-In, sync '
                    'your favorite anime list, and display comments you choose to post.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _PolicySectionCard(
            title: '1. Information We Collect',
            bullets: [
              'Account & Profile Info (via Google Sign-In): display name, email address, Google/Supabase user IDs, and Google profile photo URL (if available).',
              'My List (Favorites): anime entries you save to or remove from your personal list.',
              'User-Generated Content: text comments you post on anime detail pages. Your display name, avatar, and comments are visible to other NimeList users.',
              'Search Queries: search keywords are sent over HTTPS to api.tenrai.org solely to fetch results and are not stored in our database.',
              'What we do NOT collect: no ads, no advertising IDs, no location, contacts, health, or payment data, and we never sell your data.',
            ],
          ),
          const SizedBox(height: 12),
          const _PolicySectionCard(
            title: '2. How We Use & Share Information',
            bullets: [
              'Authenticate your session with Google Sign-In and Supabase Auth.',
              'Sync your saved My List and display or delete your own comments.',
              'Service providers used: Google Sign-In (authentication), Supabase (database & auth hosting), and Tenrai API / MyAnimeList CDN (public anime metadata & posters).',
              'All network communication is encrypted in transit using HTTPS/TLS.',
            ],
          ),
          const SizedBox(height: 12),
          const _PolicySectionCard(
            title: '3. Data Retention, Deletion & Age Requirement',
            bullets: [
              'You can remove items from My List, delete your own comments, or sign out inside the app at any time.',
              'To permanently delete your account and all associated data (profile, favorites, and comments), email willy.iedans@gmail.com from your signed-in Google email or visit our Account Deletion page. Verified requests are completed within 7 business days.',
              'NimeList is intended for users aged 13 and older and applies a two-layer SFW filter to exclude adult-rated (R+ and Rx) anime.',
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    'Official Web Links & Contact',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  _CopyableLinkTile(
                    label: 'Online Privacy Policy',
                    value: privacyPolicyUrl,
                    onCopy: () => _copyText(
                      context,
                      'Privacy Policy URL',
                      privacyPolicyUrl,
                    ),
                  ),
                  _CopyableLinkTile(
                    label: 'Account & Data Deletion',
                    value: deleteAccountUrl,
                    onCopy: () => _copyText(
                      context,
                      'Account Deletion URL',
                      deleteAccountUrl,
                    ),
                  ),
                  _CopyableLinkTile(
                    label: 'Developer Contact Email',
                    value: contactEmail,
                    onCopy: () =>
                        _copyText(context, 'Contact email', contactEmail),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySectionCard extends StatelessWidget {
  final String title;
  final List<String> bullets;

  const _PolicySectionCard({required this.title, required this.bullets});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            for (final bullet in bullets)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  const Text('•'),
                  Expanded(child: Text(bullet)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CopyableLinkTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _CopyableLinkTile({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: SelectableText(value),
      trailing: IconButton(
        icon: const Icon(Icons.copy_outlined),
        tooltip: 'Copy $label',
        onPressed: onCopy,
      ),
    );
  }
}
