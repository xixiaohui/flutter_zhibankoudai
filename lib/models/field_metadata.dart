import 'package:flutter/material.dart';

/// 字段标签/图标映射 — module_detail_page / poster_page 共享
abstract class FieldMetadata {
  FieldMetadata._();

  static const fieldLabels = {
    'author': '作者',
    'artist': '歌手',
    'director': '导演',
    'source': '出处',
    'era': '年代',
    'region': '地区',
    'location': '位置',
    'album': '专辑',
    'luckyDirection': '吉利方位',
    'luckyNumber': '吉利数字',
    'luckyColor': '吉利颜色',
    'keyPoint': '核心金句',
  };

  static const fieldIcons = {
    'author': Icons.person,
    'artist': Icons.mic,
    'director': Icons.movie,
    'source': Icons.menu_book,
    'era': Icons.history,
    'region': Icons.public,
    'location': Icons.location_on,
    'album': Icons.album,
    'luckyDirection': Icons.explore,
    'luckyNumber': Icons.tag,
    'luckyColor': Icons.palette,
    'keyPoint': Icons.format_quote,
  };

  static const skipInMetadata = {
    'content',
    'title',
    'subtitle',
    'category',
    'categoryIcon',
  };

  static String label(String key) => fieldLabels[key] ?? key;
  static IconData icon(String key) => fieldIcons[key] ?? Icons.info_outline;
  static bool skip(String key) => skipInMetadata.contains(key);
}
