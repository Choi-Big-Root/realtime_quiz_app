import 'package:realtime_quiz_app/model/problem.dart';

class QuizManager {
  List<ProblemManager>? problems;
  String? title;
  ProblemManager? answer;

  QuizManager({
    required this.problems,
    required this.title,
    required this.answer,
  });
}

class QuizDetail {
  String? pinCode;
  List<Problems>? problems;

  QuizDetail({required this.pinCode, required this.problems});

  factory QuizDetail.fromJson(Map<String, dynamic> json) => QuizDetail(
    pinCode: json['pinCode'] as String?,
    problems:
        (json['problems'] as List<dynamic>?)
            ?.map((e) => Problems.fromJson(e as Map<String, dynamic>))
            .toList(),
  );

  Map<String, dynamic> toJson(QuizDetail quizDetail) => <String, dynamic>{
    'pinCode': quizDetail.pinCode,
    'problems': quizDetail.problems,
  };
}

class Quiz {
  String? pinCode;
  String? uid;
  String? generateTime;
  int? timeStamp;
  String? quizDetailRef;

  Quiz({
    required this.pinCode,
    required this.uid,
    required this.generateTime,
    required this.timeStamp,
    required this.quizDetailRef,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
    pinCode: json['pinCode'] as String?,
    uid: json['uid'] as String?,
    generateTime: json['generateTime'] as String?,
    timeStamp: json['timeStamp'] as int?,
    quizDetailRef: json['quizDetailRef'] as String?,
  );

  Map<String, dynamic> toJson(Quiz quiz) => <String, dynamic>{
    'pinCode': quiz.pinCode,
    'uid': quiz.uid,
    'generateTime': quiz.generateTime,
    'timeStamp': quiz.timeStamp,
    'quizDetailRef': quiz.quizDetailRef,
  };

  @override
  String toString() {
    return '\npinCode[$pinCode] uid[$uid] generateTime[$generateTime] timeStamp[$timeStamp] quizDetailRef[$quizDetailRef]\n';
  }
}
