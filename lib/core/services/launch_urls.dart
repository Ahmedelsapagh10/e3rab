import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchUrlsService {
  void launchWhatsApp({
    required String phone,
    required BuildContext context,
  }) async {
    String phoneNumber = phone.replaceAll('+', '');
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }
    String whatsappUrl = "https://wa.me/+966$phoneNumber";
    Uri uri = Uri.parse(whatsappUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void launchCall({required String phone}) async {
    Uri phoneNumber = Uri.parse('tel:0$phone');
    log(phoneNumber.toString());
    await launchUrl(phoneNumber, mode: LaunchMode.externalApplication);
  }

  void launchEmail(String email, String subject) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': subject},
    );

    if (await canLaunchUrl(Uri.parse(emailLaunchUri.toString()))) {
      await launchUrl(Uri.parse(emailLaunchUri.toString()));
    } else {}
  }

  void launchFileDownload(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: mode);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> launchBrowesr({
    required String uri,
    required BuildContext context,
  }) async {
    Uri url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> openMap(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    final Uri appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?q=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch map';
    }
  }
}
