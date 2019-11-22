import 'package:flutter/widgets.dart';

/// Returns the [EdgeInsets] defining the safe area for `context`.
EdgeInsets getSafeArea(BuildContext context, {bool maintainBottomViewPadding = false}) {
  assert(debugCheckHasMediaQuery(context), 'The context must have a MediaQuery.');
  final MediaQueryData data = MediaQuery.of(context);
  EdgeInsets padding = data.padding;
  // Bottom padding has been consumed - i.e. by the keyboard
  if (data.padding.bottom == 0.0 && data.viewInsets.bottom != 0.0 && maintainBottomViewPadding) padding = padding.copyWith(bottom: data.viewPadding.bottom);

  return padding;
}

/// A ternary value denoting `True`, `False` or `Neutral`,
class Ternary {
  const Ternary._(this.value, this.equivalent, this.label, this._strings);

  /// Returns a Ternary `dynamic` [from]
  factory Ternary.parse(dynamic from) => from is Ternary ? Ternary : from is bool ? (from ? True : from == false ? False : Neutral) : from is int ? (from == 1 ? True : from == -1 ? False : Neutral) : from is String ? (True._strings.contains(from.toLowerCase()) ? True : False._strings.contains(from.toLowerCase()) ? False : Neutral) : Neutral;

  /// An integer representation of this ternary value
  final int value;

  /// A boolean equivalent of this ternary value
  final bool equivalent;

  /// This ternary value's English label.
  final String label;

  /// A `List` of valid values when parsing a `String`.
  final List<String> _strings;

  @override
  bool operator ==(dynamic other) => other is Ternary && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => label.toLowerCase();

  /// A ternary value denoting `true`.
  static const True = Ternary._(1, true, 'True', ['true', 'positive', '+', '1', 'agree']);
  /// A ternary value equal to `True` denoting "agreement".
  static const Agree = True;
  
  /// A ternary value denoting "neutral".
  static const Neutral = Ternary._(0, null, 'Neutral', null);

  /// A ternary value denoting `false`.
  static const False = Ternary._(-1, false, 'False', ['false', 'negative', '-', '-1', 'disagree']);
  /// A ternary value equal to `False` denoting "disagreement".
  static const Disagree = False;
}
