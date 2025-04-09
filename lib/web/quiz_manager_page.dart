import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realtime_quiz_app/main.dart';
import 'package:realtime_quiz_app/model/problem.dart';
import 'package:realtime_quiz_app/model/quiz.dart';
import 'package:realtime_quiz_app/web/quiz_bottom_sheet_widget.dart';

class QuizManagerPage extends StatefulWidget {
  const QuizManagerPage({super.key});

  @override
  State<QuizManagerPage> createState() => _QuizManagerPageState();
}

class _QuizManagerPageState extends State<QuizManagerPage> {
  String? uid;

  // 문제 목록
  /*List<QuizManager> quizItems = [
    QuizManager(
      problems: [
        ProblemManager(
          index: 0,
          textEditingController: TextEditingController(text: "test1"),
        ),
        ProblemManager(
          index: 1,
          textEditingController: TextEditingController(text: "test2"),
        ),
        ProblemManager(
          index: 2,
          textEditingController: TextEditingController(text: "test3"),
        ),
        ProblemManager(
          index: 3,
          textEditingController: TextEditingController(text: "test4"),
        ),
      ],
      title: 'TEST 문제1',
      answer: ProblemManager(
        index: 0,
        textEditingController: TextEditingController(text: 'test3'),
      ),
    ),
    QuizManager(
      problems: [
        ProblemManager(
          index: 0,
          textEditingController: TextEditingController(text: "test21"),
        ),
        ProblemManager(
          index: 1,
          textEditingController: TextEditingController(text: "test22"),
        ),
        ProblemManager(
          index: 2,
          textEditingController: TextEditingController(text: "test23"),
        ),
        ProblemManager(
          index: 3,
          textEditingController: TextEditingController(text: "test24"),
        ),
      ],
      title: 'TEST 문제2',
      answer: ProblemManager(
        index: 0,
        textEditingController: TextEditingController(text: 'test3'),
      ),
    ),
    QuizManager(
      problems: [
        ProblemManager(
          index: 0,
          textEditingController: TextEditingController(text: "test31"),
        ),
        ProblemManager(
          index: 1,
          textEditingController: TextEditingController(text: "test32"),
        ),
        ProblemManager(
          index: 2,
          textEditingController: TextEditingController(text: "test33"),
        ),
        ProblemManager(
          index: 3,
          textEditingController: TextEditingController(text: "test34"),
        ),
      ],
      title: 'TEST 문제3',
      answer: ProblemManager(
        index: 0,
        textEditingController: TextEditingController(text: 'test3'),
      ),
    ),
  ];*/

  List<QuizManager> quizItems = [
    QuizManager(
      problems: [
        ProblemManager(
          index: 0,
          textEditingController: TextEditingController(text: 'Spiring'),
        ),
        ProblemManager(
          index: 1,
          textEditingController: TextEditingController(text: 'Flutter'),
        ),
        ProblemManager(
          index: 2,
          textEditingController: TextEditingController(text: 'Node'),
        ),
      ],
      title: '내가 가장 좋아하는 프레임워크는?',
      answer: ProblemManager(
        index: 1,
        textEditingController: TextEditingController(text: 'Flutter'),
      ),
    ),
  ];

  List<Quiz> quizList = [];

  // 익명 로그인 정보. uid에 저장.
  signInAnonymously() {
    FirebaseAuth.instance
        .signInAnonymously()
        .then((value) {
          uid = value.user!.uid;
        })
        .catchError((e) {
          debugPrint(e.toString());
        });
  }

  generateQuiz() async {
    if (quizItems.isEmpty) {
      return;
    }
    final pinCode = Random().nextInt(999999).toString().padLeft(6);
    final quizRef = database!.ref('quiz');
    final quizDetailRef = database!.ref('quizDetail');
    final quizStatusRef = database!.ref('quizStatus');

    // 문제 set
    final newQuizDetailRef = quizDetailRef.push(); //고유키 생성.
    await newQuizDetailRef.set({
      "pinCode": pinCode,
      "problems":
          quizItems
              .map(
                (element) => {
                  "title": element.title,
                  "options": element.problems?.map(
                    (problem) => problem.textEditingController?.text.trim(),
                  ),
                  "answerIndex": element.answer?.index,
                  "answer": element.answer?.textEditingController?.text.trim(),
                },
              )
              .toList(),
    });

    // 문제 상태 set * 빈값은 생성이 되지 않지만 연습하기위해 모델을 생성안해놨으니 앞으로 사용할 필드들을 알 수 있게 정리한다고 생각.
    await quizStatusRef.child('${newQuizDetailRef.key}').set({
      "quizDetailRef": newQuizDetailRef.key,
      "user": [],
      "state": false,
      "score": [],
      "solve": [{}],
    });

    final newQuizRef = quizRef.push();
    await newQuizRef.set({
      "pinCode": pinCode,
      "uid": uid,
      "generateTime": DateTime.now().toString(),
      "timeStamp": DateTime.now().millisecondsSinceEpoch,
      "quizDetailRef": newQuizDetailRef.key,
    });
  }

  //문제 추가시 반영.
  streamQuizzes() {
    database!.ref('quiz').onValue.listen((event) {
      if (event.snapshot.value == null) return;
      quizList.clear();
      final datas = event.snapshot.children;
      for (var data in datas) {
        final item = jsonDecode(jsonEncode(data.value));
        quizList.add(Quiz.fromJson(item));
      }
      setState(() {});
      //debugPrint(event.snapshot.children.map((e) => e.value));
    });
  }

  startQuiz(Quiz item) async {
    final stateRef =
        await database?.ref('quizStatus/${item.quizDetailRef}/state').get();
    final currentState = stateRef?.value as bool;
    if (currentState) {
      return;
    }

    // 문제의 개수.
    final detailRef =
        await database?.ref('quizDetail/${item.quizDetailRef}').get();
    final problemCount = detailRef?.child('problems').children.length ?? 0;

    DateTime nowDateTime = DateTime.now();
    List<Map> triggerTimes = [];

    int solveTime = 5; //문제별 푸는 시간.

    for (var i = 0; i < problemCount; i++) {
      final startTime = nowDateTime.add(Duration(seconds: 5 + (i * solveTime)));
      final endTime = startTime.add(const Duration(seconds: 5));
      triggerTimes.add({
        "startTime": startTime.millisecondsSinceEpoch,
        "endTime": endTime.millisecondsSinceEpoch,
      });
      nowDateTime = endTime;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: const Text('퀴즈를 시작할까요?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  await database
                      ?.ref('quizStatus/${item.quizDetailRef}')
                      .update({
                        "state": true,
                        "current": 0,
                        "triggers": triggerTimes,
                      });

                  if (!context.mounted) return;

                  Navigator.of(context).pop();
                },
                child: const Text('Yes'),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    signInAnonymously();
    streamQuizzes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('퀴즈 출제하기(출제자용)')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(tabs: [Tab(text: '출제하기'), Tab(text: '퀴즈목록')]),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: quizItems.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ExpansionTile(
                              title: Text(quizItems[index].title ?? '문제없음'),
                              children:
                                  quizItems[index].problems
                                      ?.map(
                                        (e) => ListTile(
                                          title: Text(
                                            e.textEditingController?.text ??
                                                '문제 없음',
                                          ),
                                        ),
                                      )
                                      .toList() ??
                                  [],
                            );
                          },
                        ),
                      ),
                      MaterialButton(
                        height: 72,
                        onPressed: () {
                          generateQuiz();
                        },
                        color: Colors.indigo,
                        child: const Text(
                          '제출 및 핀코드 생성',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: quizList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text('code: ${quizList[index].pinCode}'),
                        subtitle: Text('${quizList[index].quizDetailRef}'),
                        onTap: () {
                          startQuiz(quizList[index]);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 문제 출제를 위한 모달 띄우기.
          final quiz = await showModalBottomSheet(
            context: context,
            builder: (context) => const QuizBottomSheetWidget(),
          );

          setState(() {
            quizItems.add(quiz);
          });
        },
        backgroundColor: Colors.indigoAccent[100],
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
