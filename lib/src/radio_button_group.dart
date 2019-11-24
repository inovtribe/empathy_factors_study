import 'package:flutter/material.dart';

typedef OnRadioButtonSelected<T> = void Function(T value, String label);
typedef RadioButtonBuilder<T> = Widget Function(BuildContext context, T value, String label, bool disabled, OnRadioButtonSelected<T> onSelected);

class RadioButtonGroup<T> extends StatelessWidget {
  /// A map of values to labels that describe each Radio button. Each value must be distinct.
  final Map<T, String> options;

  /// Specifies which buttons should be disabled.
  /// If this is non-null, no buttons will be disabled.
  /// The strings passed to this must match the labels.
  final List<T> disabled;

  /// Called when the value of the RadioButtonGroup changes.
  final OnRadioButtonSelected<T> onSelected;

  /// Specifies the orientation to display elements.
  final Axis orientation;

  /// Called when needed to build a RadioButtonGroup element.
  final RadioButtonBuilder<T> itemBuilder;

  //SPACING STUFF
  /// Empty space in which to inset the RadioButtonGroup.
  final EdgeInsetsGeometry padding;

  /// Empty space surrounding the RadioButtonGroup.
  final EdgeInsetsGeometry margin;

  RadioButtonGroup({
    @required this.options,
    @required this.onSelected,
    @required this.itemBuilder,
    this.disabled,
    this.orientation = Axis.vertical,
    this.padding = const EdgeInsets.all(0.0),
    this.margin = const EdgeInsets.all(0.0),
    Key key,
  })  : assert(itemBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [];

    options.forEach((value, label) => content.add(itemBuilder(context, value, label, disabled?.contains(value) ?? false, onSelected)));

    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: padding,
      margin: margin,
      width: mediaQuery.size.width - padding.horizontal,
      child: orientation == Axis.vertical ? Column(children: content, mainAxisAlignment: MainAxisAlignment.center) : Row(children: content, mainAxisAlignment: MainAxisAlignment.center),
      // child: Wrap(
      //   direction: orientation == GroupedButtonsOrientation.VERTICAL ? Axis.vertical : Axis.horizontal,
      //   children: content,
      // ),
    );
  }
}

class RadioBoxButton<T> extends StatelessWidget {
  final OnRadioButtonSelected<T> onSelected;

  const RadioBoxButton({
    @required this.value,
    @required this.label,
    @required this.isSelected,
    @required this.onSelected,
    Key key,
  })  : assert(label != null, 'label must not be null'),
        assert(value != null, 'value must not be null'),
        super(key: key);

  final T value;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => onSelected(value, label),
        enableFeedback: true,
        splashColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.orangeAccent : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
          ),
          child: Text(
            label,
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0,
            ),
          ),
        ),
      ),
    );
  }
}

