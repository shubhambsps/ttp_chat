import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

const COLORS = [
  Color(0xffff6767),
  Color(0xff66e0da),
  Color(0xfff5a2d9),
  Color(0xfff0c722),
  Color(0xff6a85e5),
  Color(0xfffd9a6f),
  Color(0xff92db6e),
  Color(0xff73b8e5),
  Color(0xfffd7590),
  Color(0xffc78ae5),
];

Color getUserAvatarNameColor(types.User user) {
  final index = user.id.hashCode % COLORS.length;
  return COLORS[index];
}

String getUserName(types.User user) =>
    '${user.firstName == null ? '' : user.firstName} ${user.lastName == null ? '' : user.lastName} / ${user.id == null ? '' : user.id}'.trim();

Color getRoomAvatarNameColor(types.Room user) {
  final index = user.id.hashCode % COLORS.length;
  return COLORS[index];
}

String getRoomName(types.Room user) =>
    (user.name ?? '').trim();
