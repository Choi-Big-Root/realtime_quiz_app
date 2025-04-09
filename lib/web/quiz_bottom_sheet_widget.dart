import 'package:flutter/material.dart';
import 'package:realtime_quiz_app/model/problem.dart';
import 'package:realtime_quiz_app/model/quiz.dart';

class QuizBottomSheetWidget extends StatefulWidget {
  const QuizBottomSheetWidget({super.key});

  @override
  State<QuizBottomSheetWidget> createState() => _QuizBottomSheetWidgetState();
}

class _QuizBottomSheetWidgetState extends State<QuizBottomSheetWidget> {
  ProblemManager? selectedAnswer;

  TextEditingController titleTextEditingController = TextEditingController();

  List<ProblemManager> problems = [
    ProblemManager(index: 0, textEditingController: TextEditingController()),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    titleTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('퀴즈내기'),
          TextField(
            controller: titleTextEditingController,
            decoration: const InputDecoration(hintText: '문제를 입력 해 주세요'),
          ),
          const SizedBox(height: 12),
          const Text('선택지 제출'),
          Expanded(
            child: ListView.builder(
              itemCount: problems.length,
              itemBuilder: (context, index) {
                return TextField(
                  controller: problems[index].textEditingController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '선택지 입력',
                    suffixIcon: GestureDetector(
                      child: const Icon(Icons.cancel_outlined),
                      onTap: () {
                        if (problems.length == 1) return;
                        problems.removeAt(index);
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const Text('정답선택'),
          DropdownButton<ProblemManager>(
            hint: const Text('선택하세요'),
            value: selectedAnswer,
            items:
                problems
                    .map(
                      (e) => DropdownMenuItem<ProblemManager>(
                        value: e,
                        child: Text(e.textEditingController!.text),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                selectedAnswer = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  problems.add(
                    ProblemManager(
                      index: (problems.last.index ?? 0) + 1,
                      textEditingController: TextEditingController(),
                    ),
                  );
                  setState(() {});
                },
                child: const Text('선택지추가'),
              ),
              TextButton(
                onPressed: () {
                  if (titleTextEditingController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('퀴즈를 작성 해 주세요.')),
                    );
                    return;
                  }

                  if (problems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('선택지를 작성 해 주세요.')),
                    );
                    return;
                  }

                  if (selectedAnswer == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('답을 선택 해 주세요.')),
                    );
                    return;
                  }

                  final quiz = QuizManager(
                    problems: problems,
                    title: titleTextEditingController.text.trim(),
                    answer: selectedAnswer,
                  );

                  Navigator.of(context).pop<QuizManager>(quiz);
                },
                child: const Text('완료'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
