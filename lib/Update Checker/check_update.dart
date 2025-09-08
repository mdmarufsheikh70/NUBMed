import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  final BuildContext context;
  UpdateChecker(this.context);

  Future<bool> checkForUpdate() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('app_update')
          .doc('latest')
          .get();

      if (snapshot.exists) {
        String latestVersion = snapshot['version'];
        String apkUrl = snapshot['url'];

        if (currentVersion != latestVersion) {
          bool? updated = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Update Available'),
              content: Text('A new version $latestVersion is available. Please update your app.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Later'),
                ),
                TextButton(
                  onPressed: () {
                    launchUrl(Uri.parse(apkUrl), mode: LaunchMode.externalApplication);
                    Navigator.pop(context, true);
                  },
                  child: Text('Update Now'),
                ),
              ],
            ),
          );

          return updated ?? false;
        }
      } else {
        print('Document "latest" not found in "app_update" collection.');
      }
    } catch (e) {
      print('Update check failed: $e');
    }
    return false;
  }


}
