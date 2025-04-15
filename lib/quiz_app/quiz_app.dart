import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:realtime_quiz_app/main.dart';
import 'package:realtime_quiz_app/model/problem.dart';
import 'package:realtime_quiz_app/model/quiz.dart';

class QuizPage extends StatefulWidget {
  final String quizRef;
  final String name;
  final String uid;
  final String code;

  const QuizPage({
    super.key,
    required this.quizRef,
    required this.name,
    required this.uid,
    required this.code,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  DatabaseReference? quizStateRef;
  List<Problems>? problemsSets = [];
  List<Map<String, int>> problemsTriggers = [];

  final String quizStatePath = "quizStatus";
  final String quizDetailPath = "quizDetail";

  Future fetchQuizInformation() async {
    quizStateRef = database.ref('$quizStatePath/${widget.quizRef}');
    final quizDetailRef = database.ref('$quizDetailPath/${widget.quizRef}');

    quizDetailRef
        .get()
        .then((value) {
          final obj = jsonDecode(jsonEncode(value.value));
          final quizDetail = QuizDetail.fromJson(obj);

          for (var element in quizDetail.problems!) {
            problemsSets?.add(element);
          }
        })
        .catchError((e) {
          debugPrint(e.toString());
        });
    quizStateRef
        ?.child('triggers')
        .get()
        .then((value) {
          for (var element in value.children) {
            final trigger = element.value as Map;
            problemsTriggers.add({
              "startTime": trigger['startTime'] as int,
              "endTime": trigger['endTime'] as int,
            });
          }
          //print(problemsTriggers.toString());
        })
        .catchError((e) {
          debugPrint(e.toString());
        });

    quizStateRef?.child('users').push().set({
      "uid": widget.uid,
      "name": widget.name,
    });

    //debugPrint(quizStateRef.toString());
    //debugPrint(problemsSets.toString());
    //debugPrint(problemsTriggers.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchQuizInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.name}(코드: ${widget.code})')),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('참가자'),
                    Expanded(
                      child: StreamBuilder(
                        stream: quizStateRef?.child('/users').onValue,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<DatabaseEvent> snapshot,
                        ) {
                          if (snapshot.hasData) {
                            final item =
                                snapshot.data!.snapshot.children.toList();

                            //print(item);
                            return ListView.builder(
                              itemCount: item.length,
                              itemBuilder: (context, index) {
                                final data = item[index].value as Map;
                                return ListTile(
                                  title: Text('${data['name']}'),
                                  subtitle: Text('${data['uid']}'),
                                );
                              },
                            );
                          }

                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                Text('참가자 확인중...'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    const Text('퀴즈 시작 상태'),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
