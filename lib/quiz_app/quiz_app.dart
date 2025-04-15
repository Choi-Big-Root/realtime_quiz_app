import 'dart:async';
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
    debugPrint(problemsSets.toString());
    //debugPrint(problemsTriggers.toString());
  }

  @override
  void initState() {
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
                    Expanded(
                      child: StreamBuilder(
                        stream: quizStateRef?.child('state').onValue,
                        builder: (
                          context,
                          AsyncSnapshot<DatabaseEvent> snapShot,
                        ) {
                          if (!snapShot.hasData) {
                            return const Center(child: Text('상태 불러오는중...'));
                          }
                          final data = snapShot.data!.snapshot.value as bool;
                          return Center(
                            child: Text(
                              switch (data) {
                                true => '시작!',
                                false => '대기중..',
                              },
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: StreamBuilder(
                stream: quizStateRef?.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapShot) {
                  if (snapShot.hasData) {
                    int currentIndex = 0; //현재 문제 번호
                    Map snapshotData = snapShot.data?.snapshot.value as Map;
                    final state = snapshotData["state"] as bool;
                    if (snapshotData.containsKey("current")) {
                      currentIndex = snapshotData["current"] as int;
                    }

                    problemsTriggers.clear();

                    if (snapshotData.containsKey("triggers")) {
                      for (var element in snapshotData["triggers"]) {
                        problemsTriggers.add({
                          "startTime": element['startTime'],
                          "endTime": element['endTime'],
                        });
                      }
                    }
                    //debugPrint(snapshotData.toString());
                    //debugPrint(currentIndex.toString());
                    //debugPrint(problemsTriggers.toString());
                    debugPrint('확인 $state');
                    if (state) {
                      if (currentIndex < problemsTriggers.length) {
                        // 문제 풀이중.
                        return Container(
                          color: Colors.white,
                          child: _ProblemSolveWidget(
                            ref: quizStateRef!,
                            problems: problemsSets![currentIndex],
                            uid: widget.uid,
                            name: widget.name,
                            startTime:
                                problemsTriggers[currentIndex]["startTime"] ??
                                0,
                            endTime:
                                problemsTriggers[currentIndex]["endTime"] ?? 0,
                            index: currentIndex,
                          ),
                        );
                      } else {
                        // 문제 풀이 완료 후 순위 표시 화면.
                        return Container();
                      }
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProblemSolveWidget extends StatefulWidget {
  final DatabaseReference ref;
  final Problems problems;
  final String uid;
  final String name;
  final int startTime;
  final int endTime;
  final int index;
  const _ProblemSolveWidget({
    required this.ref,
    required this.problems,
    required this.uid,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.index,
  });

  @override
  State<_ProblemSolveWidget> createState() => _ProblemSolveWidgetState();
}

class _ProblemSolveWidgetState extends State<_ProblemSolveWidget> {
  Timer? timer; // 1초마다 타임 계산을 위해

  int leftTime = 0; // 남은 시간
  int readyTime = 0; // 준비 시간

  bool isStart = false; // 문제 시작 했는지
  bool isSubmit = false; // 문제 제출 했는지

  @override
  void dispose() {
    timer?.cancel(); // 타이머 사용후 해제.
    super.dispose();
  }

  // 새로고침.
  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future periodicTask() async {
    final startTime = DateTime.fromMillisecondsSinceEpoch(widget.startTime);
    final endTime = DateTime.fromMillisecondsSinceEpoch(widget.endTime);

    timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
      DateTime nowDateTime = DateTime.now();
      // 참가자들이 입장하고 문제 출제자가 문제를 출제하면 현재 시간에서 시작시간 뺀것으로 시작 count
      final sDiff = nowDateTime.difference(startTime); // 현재 시간에서 시작시간 뺀것.
      // 문제 시작 시간에서  endTime(limit) 으로 한문제당 count
      final eDiff = endTime.difference(nowDateTime);

      print(sDiff);
      print(eDiff);

      readyTime = sDiff.inSeconds;
      leftTime = eDiff.inSeconds;

      print(readyTime);
      print(leftTime);

      //문제풀이가 시작이 되면
      if (sDiff.inSeconds >= 0) {
        isStart = true;
      }

      if (eDiff.inSeconds <= 0) {
        int nextIndex = widget.index + 1;
        widget.ref.child('current').set(nextIndex);
        timer?.cancel();
        timer = null;
        isStart = false;
        isSubmit = false;
      }
      refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    periodicTask();
    return switch (isStart) {
      true => Column(
        children: [
          Text('문제', style: Theme.of(context).textTheme.headlineLarge),
          Text(
            widget.problems.title!,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Expanded(
            child:
                isSubmit
                    ? Text(
                      '제출완료',
                      style: Theme.of(context).textTheme.headlineMedium,
                    )
                    : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                      itemCount: widget.problems.options!.length,
                      itemBuilder: (context, index) {
                        final item = widget.problems.options![index];
                        return GestureDetector(
                          onTap: () {},
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${index + 1} 번',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Text(
            '$leftTime 초',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 42),
          ),
        ],
      ),
      false => Container(),
    };
  }
}
