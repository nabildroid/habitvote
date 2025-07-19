import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/vote/application/votes_cubit.dart';
import 'dart:math';

import 'package:habitvote/features/vote/presentation/utils/votes_context_extension.dart';
import 'package:habitvote/services/kv_service.dart';

class _VoteCandidate {
  final String id;
  final String title;
  final int reputation;
  final List<bool> streak;

  _VoteCandidate({
    required this.id,
    required this.title,
    required this.reputation,
    required this.streak,
  });
}

class CondidatsVoting extends StatefulWidget {
  const CondidatsVoting({super.key});

  static show(BuildContext context) {
    context.voteCubit.fetchCandidats();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return BlocBuilder<VotesCubit, VotesState>(
            buildWhen: (s, n) => s.todayCandidats != n.todayCandidats,
            builder: (context, s) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: s.todayCandidats.isEmpty
                    ? const FractionallySizedBox(
                        heightFactor: 0.3,
                        child: Center(
                            child: CircularProgressIndicator(
                          color: Colors.black87,
                        )),
                      )
                    : const CondidatsVoting(),
              );
            });
      },
    );
  }

  static Future<bool> _needTutorial() async {
    final maxView = 2;
    final currentView =
        (await locator.get<KvService>().getInt('vote_drag_tutorial')) ?? 0;

    if (currentView >= maxView) {
      return false;
    }

    await locator
        .get<KvService>()
        .setInt('vote_drag_tutorial', currentView + 1);
    return true;
  }

  @override
  State<CondidatsVoting> createState() => _CondidatsVotingState();
}

class _CondidatsVotingState extends State<CondidatsVoting> {
  late final PageController _pageController;
  int _currentPage = 0;
  Offset _dragPosition = Offset.zero;

  late final List<_VoteCandidate> _candidates;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    final votingState = context.voteState;

    _candidates = votingState.todayCandidats
        .where((c) => !votingState.votedOnToday.contains(c.id))
        .map((c) => _VoteCandidate(
              id: c.id,
              title: c.habitName,
              reputation: 10,
              streak: List.generate(
                  30,
                  (index) => c.checkins.contains(
                      DateTime.now().subtract(Duration(days: index)))),
            ))
        .take(3)
        .toList();
    _candidates.shuffle();

    checkNeedTutorial();
  }

  void checkNeedTutorial() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      CondidatsVoting._needTutorial().then((needTutorial) {
        if (needTutorial && mounted) {
          _runDragTutorial();
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _runDragTutorial() async {
    // Wait a bit before starting the tutorial
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Simulate a drag to the right
    setState(() {
      _dragPosition = const Offset(60, 0);
    });

    // Hold the position
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _dragPosition = const Offset(-60, 0);
    });

    // Hold the position
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Animate back to the center. The AnimatedContainer will handle this.
    setState(() {
      _dragPosition = Offset.zero;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dragThreshold = screenWidth * 0.4;

    if (_dragPosition.dx.abs() > dragThreshold) {
      // Voted
      if (_dragPosition.dx > 0) {
        debugPrint("Voted Believe on card $_currentPage");
        voteOnCurrent(true);
      } else {
        debugPrint("Voted Challenge on card $_currentPage");
        voteOnCurrent(false);
      }

      if (_currentPage < _candidates.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        // Last card, close the sheet
        if (mounted) {
          Navigator.of(context).pop();
          context.voteCubit.showVoteResults();
        }
      }
    }

    // Reset position. The PageView's listener will handle setting it to zero
    // for the new page, and this will animate the old card back if not swiped
    // far enough.
    setState(() {
      _dragPosition = Offset.zero;
    });
  }

  void voteOnCurrent(bool positive) {
    final candidateId = _candidates[_currentPage].id;
    final target = context.voteCubit.state.todayCandidats
        .firstWhere((c) => c.id == candidateId);

    context.voteCubit.voteOn(target, positive);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Column(
        children: [
          _buildTopIndicators(),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              children: [
                _buildSideIndicators(),
                PageView.builder(
                  allowImplicitScrolling: false,
                  physics: NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  itemCount: _candidates.length,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                      _dragPosition = Offset.zero;
                    });
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onHorizontalDragUpdate: _onDragUpdate,
                      onHorizontalDragEnd: _onDragEnd,
                      child: AnimatedContainer(
                        duration: _dragPosition == Offset.zero
                            ? const Duration(milliseconds: 200)
                            : Duration.zero,
                        transform:
                            Matrix4.translationValues(_dragPosition.dx, 0, 0),
                        child: _buildCard(_candidates[index]),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _candidates.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 12 : 8,
          height: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            color:
                _currentPage == index ? Colors.black87 : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildSideIndicators() {
    final screenWidth = MediaQuery.of(context).size.width;
    final dragPercent = (_dragPosition.dx / (screenWidth / 2)).clamp(-1.0, 1.0);

    return Stack(
      children: [
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 30,
                color: Colors.transparent,
                child: const Center(
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: Text(
                      'Believe',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
              Container(
                width: 30,
                color: Colors.transparent,
                child: const Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      'Challenge',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: dragPercent > 0.1 ? (dragPercent * 80).abs() : 0,
            color: Colors.green.withOpacity(0.8),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: dragPercent < -0.1 ? (dragPercent * 80).abs() : 0,
            color: Colors.red.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(_VoteCandidate candidate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCardHeader(candidate),
            const SizedBox(height: 20),
            _buildStreakGrid(candidate.streak),
            const Spacer(),
            _buildXpInfo(),
            const SizedBox(height: 8),
            Text(
              'The More XP you Collect\nthe More Exposure You Get',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(_VoteCandidate candidate) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.black,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                candidate.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: candidate.reputation / 10,
                        backgroundColor: Colors.grey[400],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.black),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${candidate.reputation}/10',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakGrid(List<bool> streak) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: streak.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: streak[index] ? Colors.black87 : Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  Widget _buildXpInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Text(
        'Good Prediction = 60 XP',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
