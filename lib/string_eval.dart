import 'dart:isolate';

/// Lets dart evaluate dart expressions
///
/// I found the way to evaluate dart expressions on:
///
/// https://stackoverflow.com/questions/13585082/how-do-i-execute-dynamically-like-eval-in-dart
/// https://iiro.dev/how-to-eval-in-dart/
///
/// This class only organize it a little bit.
///
/// The usage is simple: instantiate the class, then evaluate expressions with
/// the [calc] method. You can pass variables as maps with the [buildVars]
/// method, and you can import packages with the [buildImports] method.
///
/// Try:
///
/// ```dart
/// void main() async {
///   Map<String, dynamic> data = {'n1':123.5, 'n2':12, 's1':'Hello','l1': [1, 2]};
///   List<String> imports = ['dart:math', 'package:path/path.dart'];
///   StringEval eval = StringEval(data: data, imports: imports);
///   print(await eval.calc("n2+l1[0] + (5+2)/3"));
///   print(await eval.calc("s1 + ' dart!'"));
///   print(await eval.calc("2==1+1 ? '2 is equal to 1+1' : 'never' "));
///   print(await eval.calc("sqrt(n1+n2)"));
///   print(await eval.calc("join('path', 'name')"));
/// }
/// ```
///
class StringEval {
  String vars = "";
  String imports = "";

  /// Constructor
  ///
  /// Optional parameters are [data] and [imports] but they can be passed as
  /// many times as you need with methods [buildVars] and [buildImports]
  ///
  StringEval({
    Map<String, dynamic> data = const {},
    List<String> imports = const [],
  }) {
    buildVars(data);
    buildImports(imports);
  }

  /// Returns the result of a dart expression evaluation
  ///
  /// the [formula] parameter must be a valid dart expression, if not an
  /// exception is thrown.
  ///
  Future<dynamic> calc(String formula) async {
    String script = '''
import "dart:isolate";
$imports

  void main(_, SendPort port) {
$vars
  port.send($formula);
}
  ''';

    var uri = Uri.dataFromString(script, mimeType: 'application/dart');
    final port = ReceivePort();
    await Isolate.spawnUri(uri, [], port.sendPort);
    return await port.first;
  }

  /// pass variables that can be evaluated as Maps.
  ///
  /// The parameter [data] must be a Map where keys are the name of variables
  /// which follow the dart rules for variable naming. and values are the
  /// actual values for variables.
  ///
  /// Remember to recall this method every time data values changes
  ///
  /// The parameter [indent] is not required.
  ///
  void buildVars(Map<String, dynamic> data, {indent = '  '}) {
    vars = "";
    for (String v in data.keys) {
      var val = data[v];
      if (val is String) {
        val = '"$val"';
      }
      if (val is List) {
        _quoteStrings(val);
      }
      vars += '$indent${val.runtimeType.toString()} $v = $val;\n';
    }
  }

  void _quoteStrings(List<dynamic> list) {
    for (var i = 0; i < list.length; i++) {
      if (list[i] is String) {
        list[i] = list[i].replaceAll('"', '\\"');
        list[i] = '"${list[i]}"';
      }
      if (list[i] is List) {
        _quoteStrings(list[i]);
      }
    }
  }

  /// pass the imports which contains functions used in formulas.
  ///
  /// the [importList] parameter is the list of strings with valid package
  /// names.
  ///
  /// The packages must be imported into the project in the `pubspec.yaml`
  /// file.
  ///
  void buildImports(List<String> importList) {
    imports = "";
    for (String v in importList) {
      imports += "import '$v';\n";
    }
  }
}
