import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInAccount;
import 'package:googleapis/calendar/v3.dart' as g;
import 'package:logging/logging.dart' show Logger;
import 'package:shared_preferences/shared_preferences.dart';

import 'google_auth_client.dart';

final googleDataProvider =
    AsyncNotifierProvider<GoogleDataController, GoogleData>(
        () => GoogleDataController());

final _logger = Logger((GoogleDataController).toString());

/// Controller for [GoogleData].
class GoogleDataController extends AsyncNotifier<GoogleData> {
  static final _googleApiAuth = GoogleSignIn(
    scopes: const [
      'email',
      g.CalendarApi.calendarReadonlyScope,
      g.CalendarApi.calendarEventsReadonlyScope,
    ],
  );

  Future<GoogleData> _fetchGoogleData() async {
    final localStorage = await SharedPreferences.getInstance();

    try {
      final googleDataEnabled = localStorage.getBool("googleDataEnabled");
      final enabledGoogleCalendars =
          localStorage.containsKey("enabledGoogleCalendars")
              ? localStorage.getStringList("enabledGoogleCalendars") ??
                  const <String>[]
              : const <String>[];

      GoogleData googleData = const GoogleData();
      if (googleDataEnabled ?? false) {
        final googleAccount = await _googleApiAuth.signInSilently();
        if (googleAccount != null) {
          final headers = await googleAccount.authHeaders;
          if (headers.isNotEmpty) {
            googleData = googleData.copyWith(
              enabled: true,
              account: googleAccount,
              authHeaders: headers,
              enabledCalendarIds: enabledGoogleCalendars.toSet(),
            );
          }
        }
      }

      return googleData;
    } catch (error, stackTrace) {
      _logger.severe("Error reading from local storage", error, stackTrace);
      return const GoogleData();
    }
  }

  @override
  Future<GoogleData> build() async {
    return _fetchGoogleData();
  }

  Future<void> signInToGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final googleAccount = await _googleApiAuth
          .signInSilently()
          .then((account) async => account ?? await _googleApiAuth.signIn());

      if (googleAccount != null) {
        final localStorage = await SharedPreferences.getInstance();
        await localStorage.setBool("googleDataEnabled", true);
      }

      return _fetchGoogleData();
    });
  }

  Future<void> signOutOfGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final localStorage = await SharedPreferences.getInstance();
      await localStorage.setBool("googleDataEnabled", false);
      await _googleApiAuth.signOut();

      return _fetchGoogleData();
    });
  }

  void setGoogleCalendarImportance(
      g.CalendarListEntry calendar, bool isEnabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final calendarId = calendar.id;
      if (calendarId != null) {
        final localStorage = await SharedPreferences.getInstance();
        try {
          final enabledCalendarIds =
              localStorage.containsKey("enabledGoogleCalendars")
                  ? localStorage.getStringList("enabledGoogleCalendars") ??
                      const <String>[]
                  : const <String>[];
          if (isEnabled && !enabledCalendarIds.contains(calendarId)) {
            enabledCalendarIds.add(calendarId);
          } else if (!isEnabled && enabledCalendarIds.contains(calendarId)) {
            enabledCalendarIds.remove(calendarId);
          }
          localStorage.setStringList(
              "enabledGoogleCalendars", enabledCalendarIds);
        } catch (error, stackTrace) {
          _logger.severe("Error reading from local storage", error, stackTrace);
        }
      }

      return _fetchGoogleData();
    });
  }
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
        authHeaders: (enabled ?? this.enabled)
            ? (authHeaders ?? this.authHeaders)
            : null,
      );

  /// Retrieve a list of calendars and assign default settings to any new calendar.
  Future<Iterable<g.CalendarListEntry>> get calendars {
    final logger = Logger((GoogleData).toString());

    final headers = authHeaders;
    if (headers == null) {
      logger.warning("No headers to retrieve Google calendars");
      return Future.value(const {});
    }

    return g.CalendarApi(GoogleAuthClient(headers))
        .calendarList
        .list()
        .then((calendars) => calendars.items ?? <g.CalendarListEntry>[]);
  }
}
