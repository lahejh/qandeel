import 'package:connectivity_plus/connectivity_plus.dart';

import '../settings/app_settings.dart';

/// Answers "may recitation be saved on the current network?" for the
/// "Save only on Wi-Fi" setting (CLAUDE.md §4, default on).
///
/// Uses `connectivity_plus` (approved 2026-11-11), which only asks the phone
/// for the connection type. It sends nothing anywhere. On Android it adds
/// the ACCESS_NETWORK_STATE permission (automatic, no prompt, no user data).
///
/// Returns true (save), false (mobile data: stream without saving) or null
/// (unknown/offline: try, and the download reports "connect to download").
Future<bool?> canSaveOnThisNetwork(
  AppSettings settings, {
  Future<List<ConnectivityResult>> Function()? check,
}) async {
  if (!settings.wifiOnly) return true;
  final List<ConnectivityResult> results;
  try {
    results = await (check ?? Connectivity().checkConnectivity)();
  } catch (_) {
    return null;
  }
  return wifiAllowsSaving(results);
}

/// Wi-Fi or a wired connection allows saving; mobile data or satellite does
/// not; no connection is unknown.
bool? wifiAllowsSaving(List<ConnectivityResult> results) {
  if (results.contains(ConnectivityResult.wifi) ||
      results.contains(ConnectivityResult.ethernet)) {
    return true;
  }
  if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
    return null;
  }
  return false;
}
