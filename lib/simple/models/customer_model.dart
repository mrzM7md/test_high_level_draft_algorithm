import 'package:equatable/equatable.dart';

class CustomerModel extends Equatable {
  final String id;
  final String name;
  final String phone;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  @override
  List<Object?> get props => [id];
}