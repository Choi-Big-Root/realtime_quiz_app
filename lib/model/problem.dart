import 'package:flutter/material.dart';

class ProblemManager {
  int? index;
  TextEditingController? textEditingController;

  ProblemManager({required this.index, required this.textEditingController});

  @override
  String toString() {
    // TODO: implement toString
    return "index : $index, Text : ${textEditingController?.text}";
  }
}
