import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/app_localizations.dart';
import '../logic/dashboard/dashboard_bloc.dart';
import '../repositories/location_repository.dart';
import '../services/audio_service.dart';
import '../services/permission_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => DashboardBloc(
        audioService: context.read<AudioService>(),
        permissionService: context.read<PermissionService>(),
        locationRepository: context.read<LocationRepository>(),
      ),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.t('dashboard'),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(value: state.recordingProgress),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            FilledButton.icon(
                              onPressed: state.isRecording
                                  ? null
                                  : () => context.read<DashboardBloc>().add(
                                      DashboardRecordingStarted(),
                                    ),
                              icon: const Icon(Icons.mic),
                              label: Text(l10n.t('record')),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: state.isRecording
                                  ? () => context.read<DashboardBloc>().add(
                                      DashboardRecordingStopped(),
                                    )
                                  : null,
                              icon: const Icon(Icons.stop),
                              label: Text(l10n.t('stop')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: () => context.read<DashboardBloc>().add(
                            DashboardUploadLocationRequested(),
                          ),
                          icon: const Icon(Icons.location_searching),
                          label: const Text('Upload Current GPS Location'),
                        ),
                        if (state.status != null) ...[
                          const SizedBox(height: 12),
                          Text(state.status!),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
