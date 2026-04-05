import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/app_localizations.dart';
import '../logic/locale/locale_cubit.dart';
import '../repositories/group_repository.dart';
import '../services/permission_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> _groups = const [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await context.read<GroupRepository>().getGroups();
    if (!mounted) {
      return;
    }
    setState(() {
      _groups = groups.map((group) => group.name).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('settings'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              l10n.t('language'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(l10n.t('english'))),
                ButtonSegment(value: 'he', label: Text(l10n.t('hebrew'))),
              ],
              selected: {
                context.watch<LocaleCubit>().state.locale.languageCode,
              },
              onSelectionChanged: (selection) {
                final code = selection.first;
                context.read<LocaleCubit>().setLocale(Locale(code));
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () =>
                  context.read<PermissionService>().requestStartupPermissions(),
              icon: const Icon(Icons.privacy_tip),
              label: Text(l10n.t('requestPermissions')),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.t('groups'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ..._groups.map((groupName) => ListTile(title: Text(groupName))),
          ],
        ),
      ),
    );
  }
}
