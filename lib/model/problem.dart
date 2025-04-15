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

class Problems {
  String? title;
  List<String>? options;
  int? answerIndex;
  String? answer;

  Problems({
    required this.title,
    required this.options,
    required this.answerIndex,
    required this.answer,
  });

  factory Problems.fromJson(Map<String, dynamic> json) => Problems(
    title: json['title'] as String?,
    options:
        (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
    answerIndex: json['answerIndex'] as int?,
    answer: json['answer'] as String?,
  );

  Map<String, dynamic> toJson(Problems problems) => <String, dynamic>{
    'title': problems.title,
    'options': problems.options,
    'answerIndex': problems.answerIndex,
    'answer': problems.answer,
  };
}
