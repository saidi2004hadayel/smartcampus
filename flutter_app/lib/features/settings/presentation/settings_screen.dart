import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the cubit already provided by main.dart — do NOT create a new one
    return const _SettingsView();
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticatedState ? authState.name : '';
    final userEmail = authState is AuthAuthenticatedState ? authState.email : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();
          return ListView(
            children: [
              // ── Profile section ────────────────────────────────────────
              _SectionHeader('Account'),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(userName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(userEmail),
              ),
              const Divider(),

              // ── Appearance ─────────────────────────────────────────────
              _SectionHeader('Appearance'),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark theme'),
                value: settings.isDarkMode,
                onChanged: (v) => cubit.toggleDarkMode(v),
              ),

              // ── Notifications ──────────────────────────────────────────
              _SectionHeader('Notifications'),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive announcements and reminders'),
                value: settings.notificationsEnabled,
                onChanged: (v) => cubit.toggleNotifications(v),
              ),

              // ── Language ───────────────────────────────────────────────
              _SectionHeader('Language'),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('Display Language'),
                trailing: DropdownButton<String>(
                  value: settings.language,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  ],
                  onChanged: (v) => cubit.setLanguage(v!),
                ),
              ),

              // ── About ─────────────────────────────────────────────────
              _SectionHeader('About'),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('App Version'),
                trailing: const Text('1.0.0',
                    style: TextStyle(color: Colors.grey)),
              ),
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: const Text('Security Info'),
                subtitle: const Text(
                    'Data encrypted with AES-256 via flutter_secure_storage'),
              ),
              ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: const Text('Storage'),
                subtitle: const Text(
                    'Offline cache stored in SQLite sandbox on device'),
              ),

              // ── Logout ────────────────────────────────────────────────
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log Out',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600)),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Log Out'),
                      content:
                      const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Log Out',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    context.read<AuthBloc>().add(AuthLogoutEvent());
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}