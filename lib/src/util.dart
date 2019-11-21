import 'package:flutter/widgets.dart';

EdgeInsets getSafeArea(BuildContext context, {bool maintainBottomViewPadding = false}) {
  assert(debugCheckHasMediaQuery(context));
  final MediaQueryData data = MediaQuery.of(context);
  EdgeInsets padding = data.padding;
  // Bottom padding has been consumed - i.e. by the keyboard
  if (data.padding.bottom == 0.0 && data.viewInsets.bottom != 0.0 && maintainBottomViewPadding) padding = padding.copyWith(bottom: data.viewPadding.bottom);

  return padding;
}

class Ternary {
  const Ternary._(this.value, this.equivalent, this.label, this._strings);
  factory Ternary.parse(dynamic from) => from is Ternary ? Ternary : from is bool ? (from ? True : from == false ? False : Neutral) : from is int ? (from == 1 ? True : from == -1 ? False : Neutral) : from is String ? (True._strings.contains(from.toLowerCase()) ? True : False._strings.contains(from.toLowerCase()) ? False : Neutral) : Neutral;

  final int value;
  final bool equivalent;
  final String label;
  final List<String> _strings;

  @override
  bool operator ==(dynamic other) => other is Ternary && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => label.toLowerCase();

  static const True = Ternary._(1, true, 'True', ['true', 'positive', '+', '1']), Neutral = Ternary._(0, null, 'Neutral', null), False = Ternary._(-1, false, 'False', ['false', 'negative', '-', '-1']);
}
