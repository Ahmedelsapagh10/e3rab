// import 'dart:developer';

// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:new_strucuture/core/preferences/flutter_secure_storage.dart';

// class AnalyticsService {
//   static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
//   static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
//     analytics: analytics,
//   );

//   Future<void> sendAnalyticsEvent({
//     required String eventName,
//     String policyNumber = '',
//     String role = '',
//     String action = '',
//     String otp = '',
//   }) async {
//     String userName = await MySecureStorage.getName();
//     String userId = await MySecureStorage.getUserID();
//     await analytics
//         .logEvent(
//           name: eventName,
//           parameters: <String, Object>{
//             'user_id': userId,
//             'user_name': userName,
//             if (policyNumber.isNotEmpty) 'ref_nom': policyNumber,
//             if (role.isNotEmpty) 'role': role,
//             if (otp.isNotEmpty) 'otp': otp,
//             if (action.isNotEmpty) 'action': action,
//           },
//         )
//         .then(
//           (e) =>
//               log('Event Sent $eventName $userId $userName AnalyticsService'),
//         );
//   }
// }
