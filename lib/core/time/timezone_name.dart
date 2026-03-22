import 'package:timezone/timezone.dart' as tz;

const kDefaultTimezoneName = 'Asia/Karachi';

bool isValidTimezoneName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return false;
  }

  try {
    tz.getLocation(trimmed);
    return true;
  } catch (_) {
    return false;
  }
}

String sanitizeTimezoneName(
  String? value, {
  String fallback = kDefaultTimezoneName,
}) {
  final trimmed = value?.trim();
  if (trimmed != null && isValidTimezoneName(trimmed)) {
    return trimmed;
  }
  if (isValidTimezoneName(fallback)) {
    return fallback;
  }
  return 'UTC';
}

tz.Location resolveTimezoneLocation(
  String? value, {
  String fallback = kDefaultTimezoneName,
}) {
  return tz.getLocation(sanitizeTimezoneName(value, fallback: fallback));
}
