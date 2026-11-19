/// Outcomes of the rider order actions (D-04). Decided only from the HTTP
/// status and `errors[0].code`, never from message text
/// (backend docs Doghri-App-Screens R3 and R4).
library;

import 'package:doghree_rider/features/order/domain/models/order_details_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';

/// accept-order (R3 step 2).
enum AcceptOutcome {
  /// 200: the order is now this rider's.
  accepted,

  /// 404 `order` or 409 `order_already_taken`: another rider has it.
  taken,

  /// 404 `active_status`: the rider is offline.
  offline,

  /// 405 (max orders, vehicle range, store transfer, deposit codes): keep
  /// the card and show the server message.
  refused,

  /// statusCode 1 from ApiClient.
  noInternet,

  /// Anything else. The card is kept.
  failed,
}

AcceptOutcome classifyAccept(int? status, String? code) {
  if (status == 200) return AcceptOutcome.accepted;
  if (status == 404 && code == 'active_status') return AcceptOutcome.offline;
  if (status == 404 && code == 'order') return AcceptOutcome.taken;
  if (status == 409 && code == 'order_already_taken') {
    return AcceptOutcome.taken;
  }
  if (status == 405) return AcceptOutcome.refused;
  if (status == 1) return AcceptOutcome.noInternet;
  return AcceptOutcome.failed;
}

/// update-order-status (R4 step 1).
enum StatusOutcome {
  /// 200.
  updated,

  /// 403 `invalid_status_transition` / `not_found`, or 404 `order`: the
  /// order changed on the server. Refresh it.
  orderChanged,

  /// 406 `error` on delivered: the order was NOT delivered. Retry is allowed.
  notDelivered,

  /// 406 `otp`.
  otpMismatch,

  /// statusCode 1 from ApiClient. The request may or may not have arrived.
  noInternet,

  /// Anything else.
  failed,
}

StatusOutcome classifyStatus(int? status, String? code) {
  if (status == 200) return StatusOutcome.updated;
  if (status == 403 &&
      (code == 'invalid_status_transition' || code == 'not_found')) {
    return StatusOutcome.orderChanged;
  }
  if (status == 404 && code == 'order') return StatusOutcome.orderChanged;
  if (status == 406 && code == 'error') return StatusOutcome.notDelivered;
  if (status == 406 && code == 'otp') return StatusOutcome.otpMismatch;
  if (status == 1) return StatusOutcome.noInternet;
  return StatusOutcome.failed;
}

/// GET delivery-man/order (R4 step 4).
enum OrderFetch { found, notFound, failed }

/// 404 is not found. 204 is treated as not found too (R4 step 4).
/// A 200 is found only when the body is a Map; the caller still has to parse.
OrderFetch classifyFetch(int? status, dynamic body) {
  if (status == 200) return body is Map ? OrderFetch.found : OrderFetch.failed;
  if (status == 404 || status == 204) return OrderFetch.notFound;
  return OrderFetch.failed;
}

/// The rider transition map from R4 (`riderMayMoveTo()` on the server).
/// A null [from] means the local status is unknown: the server decides.
bool riderMayMoveTo(String? from, String to, {required bool isParcel}) {
  if (from == null) return true;
  switch (to) {
    case 'picked_up':
      return const ['accepted', 'confirmed', 'processing', 'handover']
          .contains(from);
    case 'delivered':
      return from == 'picked_up';
    case 'handover':
      return isParcel &&
          const ['pending', 'accepted', 'confirmed', 'processing']
              .contains(from);
    case 'canceled':
      return const ['pending', 'accepted', 'confirmed'].contains(from);
    case 'confirmed':
      return from == 'pending';
    default:
      return false;
  }
}

/// What a repository returns for an order action.
class OrderActionResult<T> {
  final T outcome;
  final String? message;
  final int? statusCode;
  const OrderActionResult(this.outcome, this.message, this.statusCode);
}

/// GET order result: the outcome, the parsed order when found, and the
/// HTTP status (1 = no internet).
class OrderFetchResult {
  final OrderFetch outcome;
  final OrderModel? order;
  final int? statusCode;
  const OrderFetchResult(this.outcome, this.order, this.statusCode);
}

/// order-details result: the lines when loaded, else null with the status.
class OrderDetailsResult {
  final List<OrderDetailsModel>? details;
  final int? statusCode;
  const OrderDetailsResult(this.details, this.statusCode);
}
