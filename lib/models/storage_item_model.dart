import 'package:flutter/material.dart';

class StorageItem {
  final String name;
  final String path;
  final IconData icon;
  final bool isDefault;

  StorageItem({
    required this.name,
    required this.path,
    required this.icon,
    this.isDefault = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StorageItem && other.path == path && other.name == name;
  }

  @override
  int get hashCode => path.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'StorageItem(name: $name, path: $path, isDefault: $isDefault)';
  }

  StorageItem copyWith({
    String? name,
    String? path,
    IconData? icon,
    bool? isDefault,
  }) {
    return StorageItem(
      name: name ?? this.name,
      path: path ?? this.path,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
