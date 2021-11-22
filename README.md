Lets dart evaluate dart expressions!

Hi, sometimes someone need to evaluate expressions, often are math expressions but can be useful to evaluate string or conditional expressions too.

This little package do the task. The big work was done by:
https://stackoverflow.com/questions/13585082/how-do-i-execute-dynamically-like-eval-in-dart
and: https://iiro.dev/how-to-eval-in-dart/

I only organized it in a class with some useful facilities.

Before use it be aware of this note:

**(NOTE: This only works in JIT mode. It’s a viable solution only if you’re building a Dart app that runs with Dart VM and which isn’t a AOT compiled. You can’t use this approach with Flutter. Or you can, but it stops working in release mode.)**


## Minimum Requirements

The package should work on most dart and flutter versions but was tested on:

- Dart SDK: 2.14.3
- Flutter: 2.5.3

## Installation

You may install this package adding `string_eval` to the dependencies list
of the `pubspec.yaml` file of your dart or flutter project as follow:

```yaml
dependencies:
  string_eval:
```
Then don't forget to run the command `dart pub get` or `flutter pub get` on
the console.

## Usage

Before starting you have to import the library with:

```dart
import 'package:string_eval/string_eval.dart';
```

Then you can use it like this:

```dart
void main() async {
  StringEval eval = StringEval();
  print(await eval.calc("3*2 + (5+2)/3"));
  print(await eval.calc("'Hello '+'dart!'"));
  print(await eval.calc("2==1+1 ? '2 is equal to 1+1' : 'never' "));
}
```

This evaluate 3 expressions. The first is a math expression, the second is a
string concatenation and the third is a conditional expression.

If your expression has errors, an exception is thrown

```dart
  print(await eval.calc("3*2 + (5+2/3"));
```
In this case a closing round bracket is missing.

With some limitations you can pass data to the eval object in this way:

```dart
  Map<String, dynamic> data = {'myDouble': 123.5, 'myInt': 12, 'myString': 'no', 'myBool': true, 'myList': [1,2,'Hello "dart"!']};
  eval.buildVars(data);
  print(await eval.calc("myDouble+myInt"));
  print(await eval.calc("myList[0]+myList[1]"));
```
The `buildVars` method transform the Map keys into the names of variables.

You can also use functions from dart packages:

```dart
  var imports = [
    'dart:math',
    'package:path/path.dart',
  ];
  eval.buildImports(imports);
  print(await eval.calc("sqrt(myDouble+myInt)"));
  print(await eval.calc("join('path', 'name')"));
```

The method `buildImports` imports the packages into eval.

To be visible, packages must be imported in your `pubspec.yaml` project.

## Limitations

The system is easy and powerful, not because of me but because of dart, but it
has some limitations:

- The Map used to pass variables can contain only simple variables and Lists, but lists can't be nested.
- The imports must be packages and not files within your project.

That's all.

Enjoy.
