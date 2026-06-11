import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescue_app/constants/app_colors.dart';
import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'package:rescue_app/domain/services/audio_service.dart';
import 'package:rescue_app/domain/services/auth_service.dart';
import 'package:rescue_app/domain/services/deeplink_service.dart';
import 'package:rescue_app/domain/services/device_service.dart';
import 'package:rescue_app/domain/services/location_service.dart';
import 'package:rescue_app/domain/services/notification_service.dart';
import 'package:rescue_app/domain/services/permission_service.dart';
import 'package:rescue_app/localization/language_constants.dart';
import 'package:rescue_app/logic/auth/auth_bloc.dart';
import 'package:rescue_app/logic/locale/locale_cubit.dart';
import 'package:rescue_app/presentation/router/app_router.dart';
import 'package:rescue_app/repositories/group_repository.dart';
import 'package:rescue_app/repositories/location_repository.dart';
import 'package:rescue_app/repositories/message_repository.dart';

class RescueAlertApp extends StatefulWidget {
  const RescueAlertApp({super.key});

  @override
  State<RescueAlertApp> createState() => _RescueAlertAppState();
}

class _RescueAlertAppState extends State<RescueAlertApp> {
  late final RestApiService _apiClient;
  late final AuthService _authService;
  late final NotificationService _notificationService;
  late final PermissionService _permissionService;
  late final LocationService _locationService;
  late final AudioService _audioService;
  late final DeepLinkService _deepLinkService;
  late final DeviceService _deviceService;
  late final MessageRepository _messageRepository;
  late final LocationRepository _locationRepository;
  late final GroupRepository _groupRepository;
  StreamSubscription? _authSub;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    // _appRouter.dispose();
    unawaited(_messageRepository.dispose());
    unawaited(_audioService.dispose());
    unawaited(_deepLinkService.dispose());
    unawaited(_notificationService.dispose());
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    // _authSub = _authService.authStateChanges.listen((user) async {
    //   if (user == null) return;
    //   final token = await user.getIdToken();
    //   if (token != null) {
    //     await _apiClient.setAccessAuthToken(access: token);
    //   }
    //   await _notificationService.registerCurrentToken();
    // });

    try {
      _authService = AuthService();
      _deepLinkService = DeepLinkService();
      _apiClient = RestApiService();
      _permissionService = PermissionService();
      _locationService = LocationService();
      _audioService = AudioService();
      _deviceService = DeviceService();
      _messageRepository = MessageRepository(apiClient: _apiClient);
      _locationRepository = LocationRepository(
        apiClient: _apiClient,
        locationService: _locationService,
      );
      _notificationService = NotificationService(
        authService: _authService,
        deepLinkService: _deepLinkService,
        apiClient: _apiClient,
        deviceService: _deviceService,
      );

      _groupRepository = GroupRepository(apiClient: _apiClient);
      await _notificationService.initialize();

      _authSub = FirebaseAuth.instance.idTokenChanges().listen((user) async {
        if (user == null) return;
        final token = await user.getIdToken();
        if (token != null) {
          await _apiClient.setAccessAuthToken(access: token);
        }
        await _notificationService.registerCurrentToken();
      });
    } catch (e) {
      debugPrint('Notification setup skipped: $e');
    }
    await _permissionService.requestStartupPermissions();
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
        child: BlocBuilder<LocaleCubit, LocaleState>(builder: (context, state) {
          return ProviderScope(
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'אפליקציית הצלה',
              theme: ThemeData(
                useMaterial3: true,
                // colorScheme: ColorScheme.fromSeed(
                //   seedColor: Colors.blue,
                // ).copyWith(
                //   surface: Colors.grey[100], // 👈 THIS controls background
                // ),
                scaffoldBackgroundColor: AppColors.screenBackground,

                appBarTheme: AppBarTheme(
                  backgroundColor:
                      AppColors.appBarBackground, // Sets the background color
                  foregroundColor: AppColors
                      .appBarForeground, // Sets the text and icon color
                ),
                filledButtonTheme: FilledButtonThemeData(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    foregroundColor: AppColors.buttonForeground,
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    foregroundColor: AppColors.buttonForeground,
                  ),
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.buttonBackground,
                    side: BorderSide(color: AppColors.buttonBackground),
                  ),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ),
              routerConfig: appRouter, //_appRouter.router
              locale: const Locale('he'),
              supportedLocales: const [
                Locale('he', ''),
                Locale('en', ''),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                VTranslation.delegate,
              ],
            ),
          );
        }),
      ),
    );
  }
}
