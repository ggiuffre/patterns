import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:http/http.dart' as http;

final googleDataProvider = StateNotifierProvider<GoogleDataProvider, GoogleData>((_) => GoogleDataProvider());

class GoogleDataProvider extends StateNotifier<GoogleData> {
  CalendarApi? _calendarApi;

  GoogleDataProvider({GoogleData googleData = const GoogleData()}) : super(googleData);

  static final _googleSignIn = GoogleSignIn(
    scopes: const [
      'email',
      CalendarApi.calendarReadonlyScope,
      CalendarApi.calendarEventsReadonlyScope,
    ],
  );

  Future<GoogleSignInAccount?> signIn() async {
    final googleAccount = await _googleSignIn.signIn();
    if (googleAccount != null) {
      final headers = await googleAccount.authHeaders;
      _calendarApi = CalendarApi(_GoogleAuthClient(headers));
      state = state.copyWith(enabled: true, account: googleAccount, authHeaders: headers);
    }
  }

  Future<GoogleSignInAccount?> signOut() async {
    final googleAccount = await _googleSignIn.signOut();
    state = state.copyWith(enabled: false, account: googleAccount);
    _calendarApi = null;
  }

  /// Retrieve a list of calendars and set default settings to any new calendar.
  Future<Iterable<CalendarListEntry>> get calendars =>
      _calendarApi?.calendarList
          .list()
          .then((calendars) => calendars.items ?? <CalendarListEntry>[])
          .then((calendars) => calendars.map((calendar) {
                if (!state.enabledCalendarIds.contains(calendar.id)) {
                  final isEnabledByDefault = calendar.primary ?? false;
                  setCalendarImportance(calendar, isEnabledByDefault);
                }
                return calendar;
              })) ??
      Future.value([]);

  void setCalendarImportance(CalendarListEntry calendar, bool isEnabled) {
    final calendarId = calendar.id;
    final enabledCalendarIds = state.enabledCalendarIds;
    if (calendarId != null) {
      if (isEnabled && !enabledCalendarIds.contains(calendarId)) {
        state = state.copyWith(enabledCalendarIds: enabledCalendarIds.union({calendarId}));
      } else if (!isEnabled && enabledCalendarIds.contains(calendarId)) {
        state = state.copyWith(enabledCalendarIds: enabledCalendarIds.difference({calendarId}));
      }
    }
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) => _client.send(request..headers.addAll(_headers));
}

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
