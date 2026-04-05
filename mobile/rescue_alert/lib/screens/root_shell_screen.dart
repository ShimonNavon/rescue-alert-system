import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../logic/auth/auth_bloc.dart';

class RootShellScreen extends StatelessWidget {
  const RootShellScreen({super.key, required this.child});

  final Widget child;

  int _currentIndex(String location) {
    if (location.startsWith('/dashboard')) {
      return 1;
    }
    if (location.startsWith('/messages')) {
      return 2;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('appTitle')),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(
                l10n.t('appTitle'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.t('settings')),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.t('logout')),
              onTap: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthSignOutRequested());
              },
            ),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(location),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/map');
              break;
            case 1:
              context.go('/dashboard');
              break;
            default:
              context.go('/messages');
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.map),
            label: l10n.t('map'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.dashboard),
            label: l10n.t('dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.queue),
            label: l10n.t('messages'),
          ),
        ],
      ),
    );
  }
}
