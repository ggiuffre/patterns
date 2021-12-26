import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as g;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final appSettingsProvider = StateNotifierProvider<AppSettingsController, AppSettings>((_) => AppSettingsController());

/// Controller for [AppSettings].
class AppSettingsController extends StateNotifier<AppSettings> {
  AppSettingsController({AppSettings appSettings = const AppSettings()}) : super(appSettings);

  g.CalendarApi? _calendarApi;

  static final _googleApiAuth = GoogleSignIn(
    scopes: const [
      'email',
      g.CalendarApi.calendarReadonlyScope,
      g.CalendarApi.calendarEventsReadonlyScope,
    ],
  );

  Future<void> setDarkMode(bool darkMode) async {
    state = state.copyWith(themeMode: darkMode ? ThemeMode.dark : ThemeMode.light);
    try {
      final localStorage = await SharedPreferences.getInstance();
      await localStorage.setBool("darkMode", darkMode);
    } catch (error) {
      developer.log("Couldn't persist setting 'darkMode' to disk. $error");
    }
  }

  Future<void> syncFromSharedPreferences() async {
    final localStorage = await SharedPreferences.getInstance();

    final darkMode = localStorage.getBool("darkMode");
    if (darkMode != null) {
      state = state.copyWith(themeMode: darkMode ? ThemeMode.dark : ThemeMode.light);
    }

    final googleDataEnabled = localStorage.getBool("googleDataEnabled");
    final enabledGoogleCalendars = localStorage.getStringList("enabledGoogleCalendars") ?? const <String>{};

    if (googleDataEnabled != null) {
      if (googleDataEnabled) {
        final googleAccount = await _googleApiAuth.signInSilently();
        if (googleAccount != null) {
          final headers = await googleAccount.authHeaders;
          if (headers.isNotEmpty) {
            _calendarApi = g.CalendarApi(_GoogleAuthClient(headers));
            state = state.copyWith(
              google: state.google.copyWith(
                enabled: true,
                account: googleAccount,
                authHeaders: headers,
                enabledCalendarIds: enabledGoogleCalendars.toSet(),
              ),
            );
          }
        }
      }
    }
  }

  Future<GoogleSignInAccount?> signInToGoogle() async {
    final googleAccount =
        await _googleApiAuth.signInSilently().then((account) async => account ?? await _googleApiAuth.signIn());

    if (googleAccount != null) {
      final headers = await googleAccount.authHeaders;
      _calendarApi = g.CalendarApi(_GoogleAuthClient(headers));
      state =
          state.copyWith(google: state.google.copyWith(enabled: true, account: googleAccount, authHeaders: headers));
      try {
        final localStorage = await SharedPreferences.getInstance();
        await localStorage.setBool("googleDataEnabled", true);
      } catch (error) {
        developer.log("Couldn't persist setting 'googleDataEnabled' to disk. $error");
      }
    }

    return googleAccount;
  }

  Future<GoogleSignInAccount?> signOutOfGoogle() async {
    try {
      final localStorage = await SharedPreferences.getInstance();
      await localStorage.setBool("googleDataEnabled", false);
    } catch (error) {
      developer.log("Couldn't persist setting 'googleDataEnabled' to disk. $error");
    }

    final googleAccount = await _googleApiAuth.signOut();
    state = state.copyWith(google: state.google.copyWith(enabled: false, account: googleAccount));
    _calendarApi = null;

    return googleAccount;
  }

  /// Retrieve a list of calendars and assign default settings to any new calendar.
  Future<Iterable<g.CalendarListEntry>> get googleCalendars =>
      _calendarApi?.calendarList.list().then((calendars) => calendars.items ?? <g.CalendarListEntry>[]).whenComplete(
          () => SharedPreferences.getInstance()
                  .then((sharedPrefs) =>
                      sharedPrefs.setStringList("enabledGoogleCalendars", state.google.enabledCalendarIds.toList()))
                  .catchError((error) {
                developer.log("Couldn't persist setting 'enabledGoogleCalendars' to disk. $error");
                return true; // ignore error
              })) ??
      Future.value(const {});

  void setGoogleCalendarImportance(g.CalendarListEntry calendar, bool isEnabled) {
    final calendarId = calendar.id;
    final enabledCalendarIds = state.google.enabledCalendarIds;
    if (calendarId != null) {
      if (isEnabled && !enabledCalendarIds.contains(calendarId)) {
        state =
            state.copyWith(google: state.google.copyWith(enabledCalendarIds: enabledCalendarIds.union({calendarId})));
      } else if (!isEnabled && enabledCalendarIds.contains(calendarId)) {
        state = state.copyWith(
            google: state.google.copyWith(enabledCalendarIds: enabledCalendarIds.difference({calendarId})));
      }
    }
  }
}

/// Settings for the app, persisted to and retrieved from disk.
///
/// Default or user-defined settings for the app, including the theme mode
/// (dark or light) and Google Calendar settings.
class AppSettings {
  final ThemeMode themeMode;
  final GoogleData google;

  const AppSettings({this.themeMode = ThemeMode.system, this.google = const GoogleData()});

  AppSettings copyWith({
    ThemeMode? themeMode,
    GoogleData? google,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        google: google ?? this.google,
      );
}

/// Data regarding a Google user.
///
/// This data class stores whether a Google user has given permission to
/// source their events from Google Calendar, which calendars should be read
/// and which not, and the authentication details needed to retrieve their
/// data.
class GoogleData {
  final bool enabled;
  final GoogleSignInAccount? account;
  final Map<String, String>? authHeaders;
  final Set<String> enabledCalendarIds;

  const GoogleData({
    this.enabled = false,
    this.enabledCalendarIds = const {},
    this.account,
    this.authHeaders,
  });

  GoogleData copyWith({
    bool? enabled,
    GoogleSignInAccount? account,
    Map<String, String>? authHeaders,
    Set<String>? enabledCalendarIds,
  }) =>
      GoogleData(
        enabled: enabled ?? this.enabled,
        enabledCalendarIds: enabledCalendarIds ?? this.enabledCalendarIds,
        account: (enabled ?? this.enabled) ? (account ?? this.account) : null,
        authHeaders: (enabled ?? this.enabled) ? (authHeaders ?? this.authHeaders) : null,
      );
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => _client.send(request..headers.addAll(_headers));
}
