const _sensitiveBuildKeys = {
  'PROFILE_KEY',
  'BASE_DOMAIN',
  'SPARE_DOMAIN',
  'API_DOMAIN',
  'SPARE_API_DOMAIN',
  'FLCLASH_APP_SECRET',
  'FLCLASH_KEY',
};

String redactSensitiveText(String value) {
  var result = value;
  for (final key in _sensitiveBuildKeys) {
    result = result.replaceAllMapped(
      RegExp('(${RegExp.escape(key)}=)([^\\s]+)'),
      (match) => '${match[1]}<redacted>',
    );
  }
  return result;
}

String redactSensitiveOutput(String value) {
  return redactSensitiveText(value).replaceAllMapped(
    RegExp(r'((?:--)?DartDefines=|DART_DEFINES\s*=\s*)[^\r\n\s]+'),
    (match) => '${match[1]}<redacted>',
  );
}

Object? redactSensitiveData(Object? value, [Object? key]) {
  if (key is String && _sensitiveBuildKeys.contains(key)) {
    return '<redacted>';
  }
  if (value is Map) {
    return value.map((entryKey, entryValue) {
      return MapEntry(entryKey, redactSensitiveData(entryValue, entryKey));
    });
  }
  if (value is List) {
    return value.map(redactSensitiveData).toList();
  }
  if (value is String) {
    return redactSensitiveText(value);
  }
  return value;
}
