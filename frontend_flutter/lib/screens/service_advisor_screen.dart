// =============================================================================
// NADDEFLI — service_advisor_screen.dart
// Layer: Flutter — Screen (AI FEATURE)
// Purpose: Quiz UI for AI Cleaning Planner; shows recommendation; "Use This Plan" opens custom booking.
// Connects to: POST /api/ai/service-recommendation → BookingDraft → CustomBookingScreen
// =============================================================================

import 'package:flutter/material.dart';
import '../models/booking_draft.dart';
import '../services/ai_advisor_service.dart';
import '../utils/app_styles.dart';

class _QuizStep {
  final String id;
  final String question;
  final String subtitle;
  final List<String> options;

  const _QuizStep({
    required this.id,
    required this.question,
    required this.subtitle,
    required this.options,
  });
}

class _ChatMessage {
  final bool isAssistant;
  final String text;
  final List<String>? chips;

  const _ChatMessage({
    required this.isAssistant,
    required this.text,
    this.chips,
  });
}

class ServiceAdvisorScreen extends StatefulWidget {
  const ServiceAdvisorScreen({Key? key}) : super(key: key);

  @override
  State<ServiceAdvisorScreen> createState() => _ServiceAdvisorScreenState();
}

class _ServiceAdvisorScreenState extends State<ServiceAdvisorScreen> {
  static const _steps = [
    _QuizStep(
      id: 'propertyType',
      question: 'What type of property needs cleaning?',
      subtitle: 'This helps us estimate scope and time.',
      options: ['House/Apartment', 'Villa', 'Office'],
    ),
    _QuizStep(
      id: 'bedrooms',
      question: 'How many bedrooms are there?',
      subtitle: 'Include all bedrooms that need cleaning.',
      options: ['1', '2', '3', '4+'],
    ),
    _QuizStep(
      id: 'bathrooms',
      question: 'How many bathrooms?',
      subtitle: 'Count full and half baths together.',
      options: ['1', '2', '3+'],
    ),
    _QuizStep(
      id: 'kitchens',
      question: 'How many kitchens?',
      subtitle: 'Most homes have one main kitchen.',
      options: ['1', '2'],
    ),
    _QuizStep(
      id: 'situation',
      question: 'What best describes the current condition?',
      subtitle: 'This affects normal vs deep cleaning.',
      options: [
        'Regular upkeep',
        'Needs a deep clean',
        'Moving out',
        'After renovation',
      ],
    ),
    _QuizStep(
      id: 'pets',
      question: 'Do you have pets at home?',
      subtitle: 'We add a little extra time when needed.',
      options: ['No pets', 'Yes, pets'],
    ),
  ];

  final List<_ChatMessage> _messages = [];
  final Map<String, String> _answers = {};
  int _stepIndex = 0;
  bool _loadingRecommendation = false;
  Map<String, dynamic>? _recommendation;

  @override
  void initState() {
    super.initState();
    _messages.add(const _ChatMessage(
      isAssistant: true,
      text:
          "Hi! I'm your Naddefli cleaning planner. I'll ask a few quick questions and suggest the best service for your home.",
    ));
    _pushQuestion();
  }

  String _chipToValue(String stepId, String label) {
    if (stepId == 'situation') {
      switch (label) {
        case 'Regular upkeep':
          return 'regular';
        case 'Needs a deep clean':
          return 'deep_needed';
        case 'Moving out':
          return 'moving_out';
        case 'After renovation':
          return 'post_renovation';
      }
    }
    if (stepId == 'pets') {
      return label.startsWith('Yes') ? 'yes' : 'no';
    }
    if (stepId == 'bathrooms' && label == '3+') return '3';
    return label;
  }

  void _pushQuestion() {
    if (_stepIndex >= _steps.length) return;
    final step = _steps[_stepIndex];
    setState(() {
      _messages.add(_ChatMessage(
        isAssistant: true,
        text: step.question,
        chips: step.options,
      ));
    });
  }

  Future<void> _selectChip(String label) async {
    if (_loadingRecommendation || _recommendation != null) return;
    final step = _steps[_stepIndex];
    final value = _chipToValue(step.id, label);

    setState(() {
      _answers[step.id] = value;
      _messages.add(_ChatMessage(isAssistant: false, text: label));
      _stepIndex += 1;
    });

    if (_stepIndex < _steps.length) {
      await Future.delayed(const Duration(milliseconds: 280));
      _pushQuestion();
      return;
    }

    await _fetchRecommendation();
  }

  Future<void> _fetchRecommendation() async {
    setState(() {
      _loadingRecommendation = true;
      _messages.add(const _ChatMessage(
        isAssistant: true,
        text: 'Analyzing your home details and preparing your plan...',
      ));
    });

    final apiAnswers = {
      'propertyType': _answers['propertyType'] ?? 'House/Apartment',
      'bedrooms': _answers['bedrooms'] ?? '2',
      'bathrooms': _answers['bathrooms'] ?? '1',
      'kitchens': _answers['kitchens'] ?? '1',
      'situation': _answers['situation'] ?? 'regular',
      'pets': _answers['pets'] ?? 'no',
    };

    final result = await AiAdvisorService.getRecommendation(apiAnswers);

    if (!mounted) return;

    setState(() {
      _loadingRecommendation = false;
      if (result != null) {
        _recommendation = result;
        _messages.removeLast();
        _messages.add(_ChatMessage(
          isAssistant: true,
          text: (result['summary'] ?? 'Here is your recommended cleaning plan.')
              .toString(),
        ));
      } else {
        _messages.removeLast();
        _messages.add(const _ChatMessage(
          isAssistant: true,
          text:
              'Sorry, I could not generate a plan right now. Please check that the backend is running and try again.',
        ));
      }
    });
  }

  void _usePlan() {
    if (_recommendation == null) return;
    final draft = BookingDraft.fromRecommendation(
      _recommendation!,
      answers: _answers.map((key, value) {
        if (key == 'situation') {
          return MapEntry(key, _situationLabel(value));
        }
        if (key == 'pets') {
          return MapEntry(key, value == 'yes' ? 'Pets at home' : 'No pets');
        }
        return MapEntry(key, value);
      }),
    );

    Navigator.of(context).pushReplacementNamed(
      '/custom-booking',
      arguments: draft,
    );
  }

  String _situationLabel(String value) {
    switch (value) {
      case 'deep_needed':
        return 'Needs a deep clean';
      case 'moving_out':
        return 'Moving out';
      case 'post_renovation':
        return 'After renovation';
      default:
        return 'Regular upkeep';
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _stepIndex < _steps.length ? _steps[_stepIndex] : null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          'AI Cleaning Planner',
          style: TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(
              AppStyles.marginMobile,
              0,
              AppStyles.marginMobile,
              AppStyles.paddingBase,
            ),
            padding: const EdgeInsets.all(AppStyles.paddingLarge),
            decoration: AppDecorations.gradientCard(
              colors: const [AppColors.secondary, AppColors.secondaryContainer],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Smart service quiz',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step?.subtitle ??
                            'Your personalized plan is ready below.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyles.marginMobile,
                vertical: AppStyles.paddingSmall,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, index);
              },
            ),
          ),
          if (_recommendation != null) _buildRecommendationCard(),
          if (_loadingRecommendation)
            const Padding(
              padding: EdgeInsets.all(AppStyles.paddingBase),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message, int index) {
    final isAssistant = message.isAssistant;
    final showChips = isAssistant &&
        message.chips != null &&
        index == _messages.length - 1 &&
        !_loadingRecommendation &&
        _recommendation == null;

    return Align(
      alignment: isAssistant ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Column(
          crossAxisAlignment:
              isAssistant ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isAssistant ? AppColors.white : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isAssistant ? 4 : 18),
                  bottomRight: Radius.circular(isAssistant ? 18 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isAssistant ? AppColors.onSurface : AppColors.white,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showChips) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.chips!.map((chip) {
                  return ActionChip(
                    label: Text(chip),
                    backgroundColor: AppColors.white,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: () => _selectChip(chip),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    final rec = _recommendation!;
    final cleaningLabel =
        (rec['cleaningLabel'] ?? 'Cleaning').toString();
    final duration =
        double.tryParse(rec['durationHours']?.toString() ?? '') ?? 0;
    final price =
        double.tryParse(rec['estimatedPrice']?.toString() ?? '') ?? 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppStyles.marginMobile),
      padding: const EdgeInsets.all(AppStyles.paddingLarge),
      decoration: AppDecorations.elevatedCard(radius: AppStyles.radiusXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Recommended Plan',
                  style: AppStyles.labelBold.copyWith(color: AppColors.primary),
                ),
              ),
              const Spacer(),
              if (rec['poweredByAi'] == true)
                Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      'AI',
                      style: AppStyles.labelBold
                          .copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          _planRow('Service', cleaningLabel),
          _planRow('Duration', '${duration.toStringAsFixed(1)} hours'),
          _planRow('Estimated price', '\$${price.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _usePlan,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Use This Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
