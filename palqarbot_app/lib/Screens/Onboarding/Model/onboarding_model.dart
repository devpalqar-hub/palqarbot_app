class OnboardingModel {
  final String requestId;
  final String status;
  final int step;
  final int maxSteps;
  final bool done;
  final String question;
  final String questionKey;
  final List<String> options;
  final bool nullable;

  const OnboardingModel({
    required this.requestId,
    required this.status,
    required this.step,
    required this.maxSteps,
    required this.done,
    required this.question,
    required this.questionKey,
    required this.options,
    required this.nullable,
  });

  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      requestId: json['requestId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      step: (json['step'] as num?)?.toInt() ?? 0,
      maxSteps: (json['maxSteps'] as num?)?.toInt() ?? 10,
      done: json['done'] == true,
      question: json['question']?.toString() ?? '',
      questionKey: json['questionKey']?.toString() ?? '',
      options: (json['options'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      nullable: json['nullable'] == true,
    );
  }

  bool get isReadyToFinalise {
    final normalized = status
        .toUpperCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    return normalized == 'READY_TO_FINALISE' ||
        normalized == 'READY_TO_FINALIZE';
  }
}
