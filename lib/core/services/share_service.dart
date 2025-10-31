// ignore_for_file: public_member_api_docs

import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
