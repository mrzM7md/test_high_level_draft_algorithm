// --- dropdown_range.dart ---
import 'package:equatable/equatable.dart';

class DropdownRange<T> extends Equatable {
  final T? fromValue;
  final T? toValue;

  const DropdownRange({this.fromValue, this.toValue});

  @override
  List<Object?> get props => [fromValue, toValue];
}