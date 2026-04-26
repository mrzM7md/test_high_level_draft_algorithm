import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;

  const CategoryModel({required this.id, required this.name});

  // نخبر Equatable أن التطابق يعتمد فقط على الـ id
  @override
  List<Object?> get props => [id];
}