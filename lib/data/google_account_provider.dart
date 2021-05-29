import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';

final googleAccountProvider = StateNotifierProvider<GoogleAccountProvider, bool>((_) => GoogleAccountProvider());

class GoogleAccountProvider extends StateNotifier<bool> {
  GoogleAccountProvider({bool enabled = false}) : super(enabled);

  bool get enabled => state;

  set enabled(bool newValue) => state = newValue;

  // TODO can probably be static
  final _googleSignIn = GoogleSignIn(
    scopes: const <String>[
      'email',
      CalendarApi.calendarReadonlyScope,
      CalendarApi.calendarEventsReadonlyScope,
    ],
  );

  GoogleSignInAccount? _currentUser;

  Map<String, String>? _authHeaders;

  GoogleSignInAccount? get currentUser => _currentUser;

  Map<String, String>? get authHeaders => _authHeaders;

  Future<GoogleSignInAccount?> signIn() async {
    _currentUser = await _googleSignIn.signIn();
    if (_currentUser != null) {
      state = true;
      _authHeaders = await _currentUser?.authHeaders;
    }
  }

  Future<GoogleSignInAccount?> signOut() async {
    _currentUser = await _googleSignIn.signOut();
    state = false;
    _authHeaders = null;
  }
}
