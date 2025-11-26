import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gold_mobile/core/constants/app_strings.dart';
import 'package:gold_mobile/core/theme/app_theme.dart';
import 'package:gold_mobile/core/theme/theme_cubit.dart';
import 'package:gold_mobile/core/utils/app_router.dart';
import 'package:gold_mobile/core/l10n/app_localizations.dart';
import 'package:gold_mobile/core/services/notification_service.dart';
import 'package:gold_mobile/core/services/call_detection_service.dart';
import 'package:gold_mobile/core/widgets/call_block_overlay.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gold_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:gold_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:gold_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:gold_mobile/features/favorites/presentation/bloc/favorites_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize notification service
  await NotificationService().initialize();

  // Initialize call detection service
  final hasPhonePermission = await CallDetectionService().checkPermission();
  if (hasPhonePermission) {
    await CallDetectionService().initialize();
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isCallActive = false;

  @override
  void initState() {
    super.initState();
    _listenToCallState();
  }

  void _listenToCallState() {
    CallDetectionService().callStateStream.listen((state) {
      setState(() {
        _isCallActive =
            state == CallState.incoming || state == CallState.active;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X/11 Pro size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => ThemeCubit()),
            BlocProvider(
              create: (context) => AuthBloc()..add(CheckAuthStatus()),
            ),
            BlocProvider(create: (context) => HomeBloc()),
            BlocProvider(create: (context) => CartBloc(widget.prefs)),
            BlocProvider(create: (context) => FavoritesBloc(widget.prefs)),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                title: AppStrings.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                routerConfig: AppRouter.router,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('uz', ''), // O'zbek
                  Locale('ru', ''), // Rus
                ],
                locale: const Locale('uz', ''), // Default til
                builder: (context, child) {
                  // Show call block overlay if call is active
                  if (_isCallActive) {
                    return const CallBlockOverlay();
                  }

                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.noScaling),
                    child: child!,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
