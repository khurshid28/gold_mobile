import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String iconPath;
  final int itemCount;

  const Category({
    required this.id,
    required this.name,
    required this.iconPath,
    this.itemCount = 0,
  });

  @override
  List<Object?> get props => [id, name, iconPath, itemCount];
}
