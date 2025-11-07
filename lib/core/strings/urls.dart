// live google sheet url
const String _baseServerUrl =
    "https://script.google.com/macros/s/AKfycbzhSu7rXJHN1A8TDD9NGd2z7Y-OiOOpyS-IQ0NmaMdKN6CEUgvN7a1g5b5Qbwf7XP8R/exec";

// old google sheet url
//const String _baseServerUrl =
//  "https://script.google.com/macros/s/AKfycbxkZpmo4AYofd2f4sMlyyDSPUWYl8tftZ2MzEZsCQHejbBul0jyCPEzty9P1FLxG2xK/exec";

// Use this everywhere in your app
String get serverUrl {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return '$_baseServerUrl?cacheBust=$timestamp';
}
