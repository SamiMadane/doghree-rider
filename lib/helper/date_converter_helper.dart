import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wefrh_rider/features/splash/controllers/splash_controller.dart';

class DateConverterHelper {
  /// تهيئة بيانات التواريخ حسب لغة التطبيق
  static Future<void> initLocaleDateFormatting() async {
    final locale = Get.locale?.languageCode ?? 'en';
    await initializeDateFormatting(locale);
  }

  /// تحويل DateTime إلى نص كامل مع الوقت
  static String dateTimeToString(DateTime dateTime) {
    final locale = Get.locale?.languageCode ?? 'en';
    return DateFormat('dd MMM yyyy ${_timeFormatter()}', locale)
        .format(dateTime);
  }

  /// فرق الوقت بالنسبة للآن بشكل إنساني
static String timeAgo(String createdAt) {
  final DateTime createdDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(createdAt);
  final DateTime now = DateTime.now();
  final Duration diff = now.difference(createdDate);

  if (diff.inSeconds < 60) {
    return 'now'.tr; // الآن
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} ${'mins_ago'.tr}';
  } else if (diff.inHours < 24) {
    return '${diff.inHours} ${'hours_ago'.tr}';
  } else if (diff.inDays == 1) {
    return 'yesterday'.tr;
  } else if (diff.inDays < 7) {
    return '${diff.inDays} ${'days_ago'.tr}';
  } else {
    // أكثر من أسبوع: عرض التاريخ الكامل
    return dateTimeStringToDateOnly(createdAt);
  }
}


  /// تحويل DateTime إلى نص بصيغة yyyy-MM-dd (مثال: للاستخدام في الكوبونات)
  static String dateTimeForCoupon(DateTime dateTime) {
    // عادة هذه صيغة ثابتة لا تتأثر باللغة
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// تحويل نص بصيغة "yyyy-MM-dd HH:mm:ss" إلى نص للتفويض/الصرف
  static String dateTimeStringForDisbursement(String time) {
    final locale = Get.locale?.languageCode ?? 'en';
    // نأخذ التاريخ + الوقت من النص
    var newTime = '${time.substring(0, 10)} ${time.substring(11, 23)}';
    return DateFormat('dd MMM, yyyy', locale)
        .format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(newTime));
  }

  /// الوقت المحلي فقط
  static String localTimeOnly(DateTime dateTime) {
    final locale = Get.locale?.languageCode ?? 'en';
    return DateFormat(_timeFormatter(), locale).format(dateTime.toLocal());
  }

  /// تحويل نص بصيغة yyyy-MM-dd HH:mm:ss إلى نص بالتاريخ المحلي
  static String dateTimeStringToDateTime(String dateTime) {
    final locale = Get.locale?.languageCode ?? 'en';
    return DateFormat('dd MMM yyyy ${_timeFormatter()}', locale)
        .format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  /// تحويل نص بصيغة yyyy-MM-dd HH:mm:ss إلى تاريخ فقط
  static String dateTimeStringToDateOnly(String dateTime) {
    final locale = Get.locale?.languageCode ?? 'en';
    return DateFormat('dd MMM yyyy', locale)
        .format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  /// تحويل نص بصيغة yyyy-MM-dd HH:mm:ss إلى DateTime
  static DateTime dateTimeStringToDate(String dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime);
  }

  /// تحويل نص ISO إلى DateTime محلي
  static DateTime isoStringToLocalDate(String dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime);
  }

  /// تحويل ISO إلى وقت محلي
  static String isoStringToLocalTimeOnly(String dateTime) {
    final locale = Get.locale?.languageCode ?? 'en';
    return DateFormat(_timeFormatter(), locale)
        .format(isoStringToLocalDate(dateTime));
  }

  /// تحويل ISO إلى تاريخ فقط
  static String isoStringToLocalDateOnly(String dateTime) {
    final locale = Get.locale?.languageCode ?? 'en';
    return DateFormat('dd MMM yyyy', locale)
        .format(isoStringToLocalDate(dateTime));
  }

  /// تحويل ISO إلى تاريخ ووقت
  static String isoStringToLocalDateAndTime(String dateTime) {
    final locale = Get.locale?.languageCode ?? 'en';
    return DateFormat('dd MMM yyyy ${_timeFormatter()}', locale)
        .format(isoStringToLocalDate(dateTime));
  }

  /// تحويل نص UTC إلى تاريخ ووقت محلي
  static String utcToDateTime(String dateTime) {
    final locale = Get.locale?.languageCode ?? 'en';
    return DateFormat('dd MMM, yyyy ${_timeFormatter()}', locale)
        .format(DateTime.parse(dateTime).toLocal());
  }

  /// تحويل DateTime إلى نص ISO
  static String localDateToIsoString(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTime);
  }

  /// تحويل DateTime إلى نص ISO + AM/PM
  static String localDateToIsoStringAMPM(DateTime dateTime) {
    final locale = Get.locale?.languageCode ?? 'en';
    return DateFormat('${_timeFormatter()} | d-MMM-yyyy', locale)
        .format(dateTime.toLocal());
  }

  /// دالة الوقت بصيغة 12/24 ساعة
  static String _timeFormatter() {
    return Get.find<SplashController>().configModel?.timeformat == '24'
        ? 'HH:mm'
        : 'hh:mm a';
  }

  /// تحويل الوقت النصي hh:mm:ss إلى الوقت المهيأ
  static String convertTimeToTime(String time) {
    return DateFormat(_timeFormatter())
        .format(DateFormat('HH:mm:ss').parse(time));
  }

  /// حساب فرق الوقت بالدقائق
  static int timeDistanceInMin(String time) {
    DateTime currentTime = Get.find<SplashController>().currentTime.toLocal();
    DateTime rangeTime = dateTimeStringToDate(time).toLocal();
    return currentTime.difference(rangeTime).inMinutes;
  }

  /// عرض اليوم/أمس أو التاريخ مع دعم العربية
  static String convertTodayYesterdayDate(String createdAt,
      {bool showDate = false}) {
    final DateTime createdDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(createdAt);
    final DateTime now = DateTime.now();
    final locale = Get.locale?.languageCode ?? 'en';
    final formatter = DateFormat('d MMMM yyyy', locale);

    if (createdDate.year == now.year &&
        createdDate.month == now.month &&
        createdDate.day == now.day) {
      return showDate
          ? '${'today'.tr}, ${formatter.format(createdDate)}'
          : 'today'.tr;
    }

    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (createdDate.year == yesterday.year &&
        createdDate.month == yesterday.month &&
        createdDate.day == yesterday.day) {
      return showDate
          ? '${'yesterday'.tr}, ${formatter.format(createdDate)}'
          : 'yesterday'.tr;
    }

    return formatter.format(createdDate);
  }

  /// فرق الوقت بالنسبة للآن
  static String convertTimeDifference(String createdAt) {
    final DateTime createdDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(createdAt);
    final DateTime now = DateTime.now();
    final difference = now.difference(createdDate);
    final locale = Get.locale?.languageCode ?? 'en';

    if (difference.inMinutes <= 0) return 'now'.tr;
    if (difference.inMinutes < 60) return '${difference.inMinutes} ${'m'.tr}';
    if (difference.inHours < 24) return '${difference.inHours} ${'h'.tr}';

    return DateFormat('h:mm a', locale).format(createdDate);
  }

  /// دالة لتنسيق التاريخ بشكل محلي حسب اللغة
  static String formatDateLocalized(DateTime date) {
    final locale = Get.locale?.languageCode ?? 'en';
    return DateFormat('d MMMM yyyy', locale).format(date);
  }
}
