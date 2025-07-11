import 'dart:async';

import 'package:filely/core/core.dart';
import 'package:filely/screens/main_screen/main_screen.dart';
import 'package:filely/services/permission_service.dart';
import 'package:filely/utils/utils.dart';
import 'package:filely/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _permissionDenied = false;
  bool _isPermanentlyDenied = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation = const AlwaysStoppedAnimation<double>(
    1.0,
  );

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    Timer(const Duration(seconds: 1), () => _checkPermissions());
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  Future<void> _checkPermissions() async {
    if (!mounted) return;

    try {
      final status = await PermissionService.checkStoragePermission();

      if (status == AppPermissionStatus.granted) {
        _navigateToMainScreen();
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _permissionDenied = true;
          _isPermanentlyDenied =
              status == AppPermissionStatus.permanentlyDenied;
        });
      }
    } catch (e) {
      debugPrint('Erro ao verificar permissões: $e');
      _navigateToMainScreen();
    }
  }

  Future<void> _requestPermission() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _permissionDenied = false;
    });

    try {
      final status = await PermissionService.requestStoragePermission();

      if (status == AppPermissionStatus.granted) {
        _navigateToMainScreen();
      } else {
        await _checkPermissions();
      }
    } catch (e) {
      debugPrint('Erro ao solicitar permissões: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _permissionDenied = true;
        });
      }
    }
  }

  void _navigateToMainScreen() {
    if (mounted) {
      Navigate.pushPageReplacement(context, const MainScreen());
    }
  }

  Future<void> _openAppSettings() async {
    final opened = await PermissionService.openAppSettings();
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir as configurações do aplicativo',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [theme.colorScheme.surface, theme.colorScheme.surface],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'app_icon',
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.folder_rounded,
                            color: accentColor,
                            size: 80,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        AppStrings.appName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Gerencie seus arquivos com facilidade',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _buildStateWidget(theme, accentColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateWidget(ThemeData theme, Color accentColor) {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child: CustomLoader(
              primaryColor: accentColor,
              secondaryColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Inicializando...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      );
    } else if (_permissionDenied) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off_rounded,
            size: 56,
            color: _isPermanentlyDenied
                ? theme.colorScheme.error
                : theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 16),
          Text(
            _isPermanentlyDenied
                ? 'Permissão de armazenamento negada'
                : 'Precisamos de sua permissão',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isPermanentlyDenied
                ? 'O Filely precisa de acesso ao armazenamento para funcionar. Por favor, habilite as permissões nas configurações do aplicativo.'
                : 'Para gerenciar seus arquivos, o Filely precisa de acesso ao armazenamento do dispositivo.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          if (_isPermanentlyDenied)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openAppSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Abrir Configurações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: theme.colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _requestPermission,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Conceder Permissão'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: theme.colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      );
    } else {
      return Center(
        child: ElevatedButton(
          onPressed: _requestPermission,
          child: const Text('Verificar Permissões'),
        ),
      );
    }
  }
}
