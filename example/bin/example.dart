import 'dart:io';
import 'package:string_eval/string_eval.dart';

void main() async {
  Map<String, dynamic> data = {};
  StringEval eval = StringEval();

  print("Some constants...");
  print(await evalIt(eval, "3*2 + (5+2)/3"));
  print(await evalIt(eval, "'Hello '+'dart!'"));
  print('');
  print('Formula error...');
  print(await evalIt(eval, "3*2 + (5+2/3"));
  print('');
  print('Conditions...');
  print(await evalIt(eval, "2==1+1 ? '2 is equal to 1+1' : 'never' "));
  print(await evalIt(eval, "2!=1+1 ?  'never' : '2 not different from 1+1' "));

  print('');
  print('Add variables...');
  data = {
    'myDouble': 123.5,
    'myInt': 12,
    'myString': 'no',
    'myBool': true,
    'myList': [
      1,
      2,
      'Hello "dart"!',
      ["You", "cannot", "access", "to", "nested", "lists"]
    ],
  };
  eval.buildVars(data);
  print(await evalIt(eval, "myDouble+myInt"));
  print(await evalIt(eval, "myList[2]"));
  print(await evalIt(eval, "myList[3]"));

  print('');
  print('No access to elements of nested list...');
  print(await evalIt(eval, "myList[3][0]"));

  print('');
  print('Import packages...');
  var imports = [
    'dart:math',
    'package:path/path.dart',
    'package:example/mylib.dart',
  ];
  eval.buildImports(imports);
  print(await evalIt(eval, "sqrt(myDouble+myInt)"));
  print(await evalIt(eval, "join('path', 'name')"));
  print(await evalIt(eval, "sumValues(myDouble, myInt)"));

  print('');
  print('cannot import dart files, only packages...');
  imports = [
    '../lib/mylib.dart',
  ];
  eval.buildImports(imports);
  print(await evalIt(eval, "sumValues(myDouble, myInt)"));

  exit(0);
}

Future<dynamic> evalIt(StringEval eval, String formula) async {
  dynamic result;
  try {
    result = await eval.calc(formula);
  } catch (e) {
    result = "Some errors in your formula: $formula";
  }
  return result;
}
