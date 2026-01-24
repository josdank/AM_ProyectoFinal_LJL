import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool onboardingDone;

  const SettingsState({
    required this.themeMode,
    required this.onboardingDone,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? onboardingDone,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  static const _kThemeMode = 'settings_theme_mode';
  static const _kOnboardingDone = 'settings_onboarding_done';

  final SharedPreferences prefs;

  SettingsCubit(this.prefs)
      : super(
          SettingsState(
            themeMode: ThemeMode.values[prefs.getInt(_kThemeMode) ?? ThemeMode.system.index],
            onboardingDone: prefs.getBool(_kOnboardingDone) ?? false,
          ),
        );

  Future<void> setThemeMode(ThemeMode mode) async {
    await prefs.setInt(_kThemeMode, mode.index);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> completeOnboarding() async {
    await prefs.setBool(_kOnboardingDone, true);
    emit(state.copyWith(onboardingDone: true));
  }
}
