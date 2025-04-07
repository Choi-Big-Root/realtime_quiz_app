import 'package:flutter/material.dart';
import 'package:realtime_quiz_app/model/problem.dart';
import 'package:realtime_quiz_app/model/quiz.dart';

class QuizManagerPage extends StatefulWidget {
  const QuizManagerPage({super.key});

  @override
  State<QuizManagerPage> createState() => _QuizManagerPageState();
}

class _QuizManagerPageState extends State<QuizManagerPage> {
  String? uid;

  // 문제 목록
  List<QuizManager> quizItems = [
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
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
                        onPressed: () {},
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
                    itemCount: 2,
                    itemBuilder: (BuildContext context, int index) {
                      return const ExpansionTile(title: Text('뭔디2'));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.indigoAccent[100],
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
