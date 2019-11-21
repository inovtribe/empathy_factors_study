import 'package:factors_empathy_survey/src/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

enum When { Agree, Distraction, Disagree }

class Response {
  const Response(this.label);

  final String label;

  static const StronglyAgree = Response('Strongly Agree');
  static const SlightlyAgree = Response('Slightly Agree');
  static const SlightlyDisagree = Response('Slightly Disagree');
  static const StronglyDisagree = Response('Strongly Disagree');

  /// A set of responses for how much a person agrees with something.
  static const Map<Response, String> agreementSet = {
    StronglyAgree: 'Strongly Agree',
    SlightlyAgree: 'Slightly Agree',
    SlightlyDisagree: 'Slightly Disagree',
    StronglyDisagree: 'Strongly Disagree',
  };
}

abstract class QuestionClass {}

abstract class EQQuestionClass extends QuestionClass {}

abstract class InputQuestionClass extends QuestionClass {}

@optionalTypeArgs
class QuestionRegistrar<Q extends Question> {
  /// Makes a new [QuestionRegistry].
  QuestionRegistrar() : registry = [];

  /// Makes a new (optionally constant) [QuestionRegistry] containing
  /// [registry] questions.
  const QuestionRegistrar.of(this.registry);

  final List<Q> registry;

  /// Adds a question to the registry. If the registry is constant, this will be ignored.
  void add(Q question) {
    try {
      registry.add(question);
    } on UnsupportedError {
      print('[WARNING]: Unsupported operation on constant registry: add');
    }
  }

  /// The question in the registry at [index]
  Q operator [](int index) {
    return registry[index];
  }

  /**
   * Returns the number of elements in [this].
   *
   * Counting all elements may involve iterating through all elements and can
   * therefore be slow.
   * Some iterables have a more efficient way to find the number of elements.
   */
  int get length => registry.length;

  /**
   * Returns the [index]th element.
   *
   * The [index] must be non-negative and less than [length].
   * Index zero represents the first element (so `iterable.elementAt(0)` is
   * equivalent to `iterable.first`).
   *
   * May iterate through the elements in iteration order, ignoring the
   * first [index] elements and then returning the next.
   * Some iterables may have more a efficient way to find the element.
   */
  Q elementAt(int index) => registry.elementAt(index);

  /**
   * Returns the first element.
   *
   * Throws a [StateError] if `this` is empty.
   * Otherwise returns the first element in the iteration order,
   * equivalent to `this.elementAt(0)`.
   */
  Q get first => registry.first;

  /**
   * Returns the first element that satisfies the given predicate [test].
   *
   * Iterates through elements and returns the first to satisfy [test].
   *
   * If no element satisfies [test], the result of invoking the [orElse]
   * function is returned.
   * If [orElse] is omitted, it defaults to throwing a [StateError].
   */
  Q firstWhere(bool Function(Q element) test, {Q Function() orElse}) => registry.firstWhere(test, orElse: orElse);

  /**
   * Applies the function [f] to each element of this collection in iteration
   * order.
   */
  void forEach(void Function(Q element) f) => registry.forEach(f);

  /**
   * Returns an [Iterable] that iterates over the objects in the range
   * [start] inclusive to [end] exclusive.
   *
   * The provided range, given by [start] and [end], must be valid at the time
   * of the call.
   *
   * A range from [start] to [end] is valid if `0 <= start <= end <= len`, where
   * `len` is this list's `length`. The range starts at `start` and has length
   * `end - start`. An empty range (with `end == start`) is valid.
   *
   * The returned [Iterable] behaves like `skip(start).take(end - start)`.
   * That is, it does *not* throw if this list changes size.
   *
   *     List<String> colors = ['red', 'green', 'blue', 'orange', 'pink'];
   *     Iterable<String> range = colors.getRange(1, 4);
   *     range.join(', ');  // 'green, blue, orange'
   *     colors.length = 3;
   *     range.join(', ');  // 'green, blue'
   */
  Iterable<Q> getRange(int start, int end) => registry.getRange(start, end);

  /**
   * Returns `true` if there are no elements in this collection.
   *
   * May be computed by checking if `iterator.moveNext()` returns `false`.
   */
  bool get isEmpty => registry.isEmpty;

  /**
   * Returns true if there is at least one element in this collection.
   *
   * May be computed by checking if `iterator.moveNext()` returns `true`.
   */
  bool get isNotEmpty => registry.isNotEmpty;

  /**
   * Returns a new `Iterator` that allows iterating the elements of this
   * `Iterable`.
   *
   * Iterable classes may specify the iteration order of their elements
   * (for example [List] always iterate in index order),
   * or they may leave it unspecified (for example a hash-based [Set]
   * may iterate in any order).
   *
   * Each time `iterator` is read, it returns a new iterator,
   * which can be used to iterate through all the elements again.
   * The iterators of the same iterable can be stepped through independently,
   * but should return the same elements in the same order,
   * as long as the underlying collection isn't changed.
   *
   * Modifying the collection may cause new iterators to produce
   * different elements, and may change the order of existing elements.
   * A [List] specifies its iteration order precisely,
   * so modifying the list changes the iteration order predictably.
   * A hash-based [Set] may change its iteration order completely
   * when adding a new element to the set.
   *
   * Modifying the underlying collection after creating the new iterator
   * may cause an error the next time [Iterator.moveNext] is called
   * on that iterator.
   * Any *modifiable* iterable class should specify which operations will
   * break iteration.
   */
  Iterator<Q> get iterator => registry.iterator;

  /**
   * Returns the last element.
   *
   * Throws a [StateError] if `this` is empty.
   * Otherwise may iterate through the elements and returns the last one
   * seen.
   * Some iterables may have more efficient ways to find the last element
   * (for example a list can directly access the last element,
   * without iterating through the previous ones).
   */
  Q get last => registry.last;

  /**
   * Returns a new lazy [Iterable] with elements that are created by
   * calling `f` on each element of this `Iterable` in iteration order.
   *
   * This method returns a view of the mapped elements. As long as the
   * returned [Iterable] is not iterated over, the supplied function [f] will
   * not be invoked. The transformed elements will not be cached. Iterating
   * multiple times over the returned [Iterable] will invoke the supplied
   * function [f] multiple times on the same element.
   *
   * Methods on the returned iterable are allowed to omit calling `f`
   * on any element where the result isn't needed.
   * For example, [elementAt] may call `f` only once.
   */
  Iterable<T> map<T>(T Function(Q e) f) => registry.map<T>(f);

  /**
   * Returns an [Iterable] that provides all but the first [count] elements.
   *
   * When the returned iterable is iterated, it starts iterating over `this`,
   * first skipping past the initial [count] elements.
   * If `this` has fewer than `count` elements, then the resulting Iterable is
   * empty.
   * After that, the remaining elements are iterated in the same order as
   * in this iterable.
   *
   * Some iterables may be able to find later elements without first iterating
   * through earlier elements, for example when iterating a [List].
   * Such iterables are allowed to ignore the initial skipped elements.
   *
   * The [count] must not be negative.
   */
  Iterable<Q> skip(int count) => registry.skip(count);

  /**
   * Returns an `Iterable` that skips leading elements while [test] is satisfied.
   *
   * The filtering happens lazily. Every new [Iterator] of the returned
   * iterable iterates over all elements of `this`.
   *
   * The returned iterable provides elements by iterating this iterable,
   * but skipping over all initial elements where `test(element)` returns
   * true. If all elements satisfy `test` the resulting iterable is empty,
   * otherwise it iterates the remaining elements in their original order,
   * starting with the first element for which `test(element)` returns `false`.
   */
  Iterable<Q> skipWhile(bool Function(Q value) test) => registry.skipWhile(test);

  /**
   * Returns a lazy iterable of the [count] first elements of this iterable.
   *
   * The returned `Iterable` may contain fewer than `count` elements, if `this`
   * contains fewer than `count` elements.
   *
   * The elements can be computed by stepping through [iterator] until [count]
   * elements have been seen.
   *
   * The `count` must not be negative.
   */
  Iterable<Q> take(int count) => registry.take(count);

  /**
   * Returns a lazy iterable of the leading elements satisfying [test].
   *
   * The filtering happens lazily. Every new iterator of the returned
   * iterable starts iterating over the elements of `this`.
   *
   * The elements can be computed by stepping through [iterator] until an
   * element is found where `test(element)` is false. At that point,
   * the returned iterable stops (its `moveNext()` returns false).
   */
  Iterable<Q> takeWhile(bool Function(Q value) test) => registry.takeWhile(test);

  /**
   * Returns a new lazy [Iterable] with all elements that satisfy the
   * predicate [test].
   *
   * The matching elements have the same order in the returned iterable
   * as they have in [iterator].
   *
   * This method returns a view of the mapped elements.
   * As long as the returned [Iterable] is not iterated over,
   * the supplied function [test] will not be invoked.
   * Iterating will not cache results, and thus iterating multiple times over
   * the returned [Iterable] may invoke the supplied
   * function [test] multiple times on the same element.
   */
  Iterable<Q> where(bool Function(Q element) test) => registry.where(test);

  /**
   * Returns a new lazy [Iterable] with all elements that have type [T].
   *
   * The matching elements have the same order in the returned iterable
   * as they have in [iterator].
   *
   * This method returns a view of the mapped elements.
   * Iterating will not cache results, and thus iterating multiple times over
   * the returned [Iterable] may yield different results,
   * if the underlying elements change between iterations.
   */
  Iterable<T> whereType<T>() => registry.whereType<T>();
}

const empathyQuotientRegistrar = QuestionRegistrar<EQQuestion>.of([
  EQQuestion(1, 'I can easily tell if someone else wants to enter a conversation.', When.Agree),
  EQQuestion(2, 'I prefer animals to humans.', When.Distraction),
  EQQuestion(3, 'I try to keep up with the current trends and fashions.', When.Distraction),
  EQQuestion(4, 'I find it difficult to explain to others things that I understand easily, when they don’t understand it the first time.', When.Disagree),
  EQQuestion(5, 'I dream most nights.', When.Distraction),
  EQQuestion(6, 'I really enjoy caring for other people.', When.Agree),
  EQQuestion(7, 'I try to solve my own problems rather than discussing them with others.', When.Distraction),
  EQQuestion(8, 'I find it hard to know what to do in a social situation.', When.Disagree),
  EQQuestion(9, 'I am at my best first thing in the morning.', When.Distraction),
  EQQuestion(10, 'People often tell me that I went too far in driving my point home in a discussion.', When.Disagree),
  EQQuestion(11, 'It doesn’t bother me too much if I am late meeting a friend.', When.Disagree),
  EQQuestion(12, 'Friendships and relationships are just too difficult, so I tend not to bother with them.', When.Disagree),
  EQQuestion(13, 'I would never break a law, no matter how minor.', When.Distraction),
  EQQuestion(14, 'I often find it difficult to judge if something is rude or polite.', When.Disagree),
  EQQuestion(15, 'In a conversation, I tend to focus on my own thoughts rather than on what my listener might be thinking.', When.Disagree),
  EQQuestion(16, 'I prefer practical jokes to verbal humor.', When.Distraction),
  EQQuestion(17, 'I live life for today rather than the future.', When.Distraction),
  EQQuestion(18, 'When I was a child, I enjoyed cutting up worms to see what would happen.', When.Disagree),
  EQQuestion(19, 'I can pick up quickly if someone says one thing but means another.', When.Agree),
  EQQuestion(20, 'I tend to have very strong opinions about morality.', When.Distraction),
  EQQuestion(21, 'It is hard for me to see why some things upset people so much.', When.Disagree),
  EQQuestion(22, 'I find it easy to put myself in somebody else’s shoes.', When.Agree),
  EQQuestion(23, 'I think that good manners are the most important thing a parent can teach their child.', When.Distraction),
  EQQuestion(24, 'I like to do things on the spur of the moment.', When.Distraction),
  EQQuestion(25, 'I am good at predicting how someone will feel.', When.Agree),
  EQQuestion(26, 'I am quick to spot when someone in a group is feeling awkward or uncomfortable.', When.Agree),
  EQQuestion(27, 'If I say something that someone else is offended by, I think that that’s their problem, not mine.', When.Disagree),
  EQQuestion(28, 'If anyone asked me if I liked their haircut, I would reply truthfully, even if I didn’t like it.', When.Disagree),
  EQQuestion(29, 'I can’t always see why someone should have felt offended by a remark.', When.Disagree),
  EQQuestion(30, 'People often tell me that I am very unpredictable.', When.Distraction),
  EQQuestion(31, 'I enjoy being the center of attention at any social gathering.', When.Distraction),
  EQQuestion(32, 'Seeing people cry doesn’t really upset me.', When.Disagree),
  EQQuestion(33, 'I enjoy having discussions about politics.', When.Distraction),
  EQQuestion(34, 'I am very blunt, which some people take to be rudeness, even though this is unintentional.', When.Disagree),
  EQQuestion(35, 'I don’t find social situations confusing.', When.Agree),
  EQQuestion(36, 'Other people tell me I am good at understanding how they are feeling and what they are thinking.', When.Agree),
  EQQuestion(37, 'When I talk to people, I tend to talk about their experiences rather than my own.', When.Agree),
  EQQuestion(38, 'It upsets me to see an animal in pain.', When.Agree),
  EQQuestion(39, 'I am able to make decisions without being influenced by people’s feelings.', When.Disagree),
  EQQuestion(40, 'I can’t relax until I have done everything I had planned to do that day.', When.Distraction),
  EQQuestion(41, 'I can easily tell if someone else is interested or bored with what I am saying.', When.Agree),
  EQQuestion(42, 'I get upset if I see people suffering on news programs.', When.Agree),
  EQQuestion(43, 'Friends usually talk to me about their problems as they say that I am very understanding.', When.Agree),
  EQQuestion(44, 'I can sense if I am intruding, even if the other person doesn’t tell me.', When.Agree),
  EQQuestion(45, 'I often start new hobbies, but quickly become bored with them and move on to something else.', When.Distraction),
  EQQuestion(46, 'People sometimes tell me that I have gone too far with teasing.', When.Disagree),
  EQQuestion(47, 'I would be too nervous to go on a big rollercoaster.', When.Distraction),
  EQQuestion(48, 'Other people often say that I am insensitive, though I don’t always see why.', When.Disagree),
  EQQuestion(49, 'If I see a stranger in a group, I think that it is up to them to make an effort to join in.', When.Disagree),
  EQQuestion(50, 'I usually stay emotionally detached when watching a film.', When.Disagree),
  EQQuestion(51, 'I like to be very organized in day-to-day life and often makes lists of the chores I have to do.', When.Distraction),
  EQQuestion(52, 'I can tune into how someone else feels rapidly and intuitively.', When.Agree),
  EQQuestion(53, 'I don’t like to take risks.', When.Distraction),
  EQQuestion(54, 'I can easily work out what another person might want to talk about.', When.Agree),
  EQQuestion(55, 'I can tell if someone is masking their true emotion.', When.Agree),
  EQQuestion(56, 'Before making a decision, I always weigh up the pros and cons.', When.Distraction),
  EQQuestion(57, 'I don’t consciously work out the rules of social situations.', When.Agree),
  EQQuestion(58, 'I am good at predicting what someone will do.', When.Agree),
  EQQuestion(59, 'I tend to get emotionally involved with a friend’s problems.', When.Agree),
  EQQuestion(60, 'I can usually appreciate the other person’s viewpoint, even if I don’t agree with it.', When.Agree),
]);

enum InputType {
  String,
  Int,
  Double,
  Boolean,
}

String nullTest(dynamic value) => value == null ? 'Must not be null.' : null;

const otherQuotientRegistrar = QuestionRegistrar<InputQuestion>.of([
  InputQuestion(1, 'On average, how much time each day do you play video games?', InputType.Double, Store.HOURS_VG, nullTest),
  InputQuestion(2, 'On average, how much time each day do you play violent video games?', InputType.Double, Store.HOURS_VG_V, nullTest),
]);

QuestionRegistrar<Question> get mixedRegistrar => QuestionRegistrar.of([...empathyQuotientRegistrar.registry..shuffle(), ...otherQuotientRegistrar.registry]);

class QuestionnaireState<Q extends Question> {
  /// Instantiates a [QuestionnaireState]
  ///
  /// `registrar` must not be empty.
  QuestionnaireState(this.registrar) : assert(registrar.isNotEmpty);
  factory QuestionnaireState.of(BuildContext context) => Provider.of<QuestionnaireState<Q>>(context);

  final QuestionRegistrar<Q> registrar;

  bool get debug => debugCount >= 9;

  int _debugCount = 0;

  int get debugCount => _debugCount;
  void set debugCount(int newDebugCount) {
    _debugCount = newDebugCount;
    if (_debugCount < 9)
      print('${9 - debugCount} taps until debug mode is enabled.');
    else
      print('Debug mode is enabled! 🥳');
  }

  /// The current question index
  int currentIndex = 0;

  /// The current question
  Question get current => registrar[currentIndex];

  /// The previous question
  ///
  /// null if currently on the first question
  Question get previous => currentIndex == 0 ? null : registrar[currentIndex - 1];

  /// Changes `currentIndex` to that of the previous question if it exists, otherwise does nothing and returns null.
  Question get toPrevious {
    final p = previous;
    if (p != null) {
      currentIndex--;
    }
    return p;
  }

  /// The next question
  ///
  /// null if currently on the last question
  Question get next => currentIndex == registrar.length - 1 ? null : registrar[currentIndex + 1];

  /// Changes `currentIndex` to that of the next question if it exists, otherwise does nothing and returns null.
  Question get toNext {
    final n = next;
    if (n != null) {
      currentIndex++;
    }
    return n;
  }
}

typedef String ValueTest(dynamic value);

abstract class Question {
  const Question(this.number, this.question, this.test);

  final int number;
  final String question;
  final ValueTest test;

  @override
  String toString() => question;
}

class EQQuestion extends Question {
  const EQQuestion(int number, String question, this.when) : super(number, question, _test);

  final When when;

  static String _test(dynamic value) => value == null ? 'Please choose an option.' : null;
}

class InputQuestion extends Question {
  const InputQuestion(int number, String question, this.type, this.key, ValueTest test) : super(number, question, test);

  final InputType type;

  final int key;
}
