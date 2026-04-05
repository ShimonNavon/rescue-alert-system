import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/locale/locale_cubit.dart';
import 'navigation/app_router.dart';
import 'repositories/group_repository.dart';
import 'repositories/location_repository.dart';
import 'repositories/message_repository.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/audio_service.dart';
import 'services/deeplink_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';

class RescueAlertApp extends StatefulWidget {
  const RescueAlertApp({super.key});

  @override
  State<RescueAlertApp> createState() => _RescueAlertAppState();
}

class _RescueAlertAppState extends State<RescueAlertApp> {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final PermissionService _permissionService;
  late final LocationService _locationService;
  late final AudioService _audioService;
  late final DeepLinkService _deepLinkService;
  late final NotificationService _notificationService;
  late final AppRouter _appRouter;
  late final MessageRepository _messageRepository;
  late final LocationRepository _locationRepository;
  late final GroupRepository _groupRepository;
  StreamSubscription? _authSub;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(baseUrl: 'https://api.example.com');
    _authService = AuthService();
    _permissionService = PermissionService();
    _locationService = LocationService();
    _audioService = AudioService();
    _deepLinkService = DeepLinkService();
    _messageRepository = MessageRepository(apiClient: _apiClient);
    _locationRepository = LocationRepository(
      apiClient: _apiClient,
      locationService: _locationService,
    );
    _groupRepository = GroupRepository(apiClient: _apiClient);
    _notificationService = NotificationService(
      authService: _authService,
      deepLinkService: _deepLinkService,
      apiClient: _apiClient,
    );
    _appRouter = AppRouter(
      authService: _authService,
      deepLinkService: _deepLinkService,
    );
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _authSub = _authService.authStateChanges.listen((user) async {
      if (user == null) {
        return;
      }
      final token = await user.getIdToken();
      if (token != null) {
        await _apiClient.setAuthToken(token);
      }
    });

    try {
      await _notificationService.initialize();
    } catch (e) {
      debugPrint('Notification setup skipped: $e');
    }
    await _permissionService.requestStartupPermissions();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _appRouter.dispose();
    unawaited(_messageRepository.dispose());
    unawaited(_audioService.dispose());
    unawaited(_deepLinkService.dispose());
    unawaited(_notificationService.dispose());
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _apiClient),
        RepositoryProvider.value(value: _authService),
        RepositoryProvider.value(value: _permissionService),
        RepositoryProvider.value(value: _locationService),
        RepositoryProvider.value(value: _audioService),
        RepositoryProvider.value(value: _messageRepository),
        RepositoryProvider.value(value: _locationRepository),
        RepositoryProvider.value(value: _groupRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LocaleCubit()),
          BlocProvider(
            create: (_) =>
                AuthBloc(authService: _authService)..add(AuthStarted()),
          ),
        ],
        child: BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, state) {
            return MaterialApp.router(
              title: 'Rescue Alert',
              debugShowCheckedModeBanner: false,
              locale: state.locale,
              routerConfig: _appRouter.router,
              supportedLocales: AppLocalizations.supportedLocales,
              localeResolutionCallback:
                  AppLocalizations.localeResolutionCallback,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF1A6D5B),
                ),
                useMaterial3: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
