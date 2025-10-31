// ignore_for_file: public_member_api_docs

import 'package:cloud_firestore/cloud_firestore.dart';

DateTime tsToDateTime(Timestamp ts) => ts.toDate();
Timestamp dateTimeToTs(DateTime dt) => Timestamp.fromDate(dt);
