import 'package:calc/base/base_model.dart';

final class CalcModel extends BaseModel {
  const CalcModel({
    required this.isCalc,
    required this.value,
  });

  factory CalcModel.empty() => _empty;

  final bool isCalc;
  final String value;

  static const CalcModel _empty = CalcModel(
    isCalc: false,
    value: '',
  );

  @override
  CalcModel copyWith({
    bool? isCalc,
    String? value,
  }) =>
      CalcModel(
        isCalc: isCalc ?? this.isCalc,
        value: value ?? this.value,
      );

  @override
  bool get isEmpty => this == _empty;

  @override
  List<Object?> get props => [isCalc, value];
}
