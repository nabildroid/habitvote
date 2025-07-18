import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habitvote/features/onboarding/presentration/widgets/brilliant_ok_button.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          i = (i + 1) % 4;
        });
      },
      child: Card(
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            )),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: i == 0
                  ? ViewVotingResult()
                  : i == 1
                      ? VoteOnPeople()
                      : i == 2
                          ? OpenWindowCheckIn()
                          : ClosedWindowCheckIn()),
        ),
      ),
    );
  }
}

class ViewVotingResult extends StatelessWidget {
  const ViewVotingResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VoterResults(
          blur: false,
        ),
        SizedBox(height: 8),
        BrilliantOkButton(
          text: "Predict People Decipline",
          onPressed: () {},
        )
      ],
    );
  }
}

class VoteOnPeople extends StatelessWidget {
  const VoteOnPeople({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VoterResults(
          blur: true,
        ),
        SizedBox(height: 8),
        BrilliantOkButton(
          text: "Vote on 3 People to see Yours",
          onPressed: () {},
        )
      ],
    );
  }
}

class VoterResults extends StatelessWidget {
  final bool blur;
  const VoterResults({
    super.key,
    this.blur = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            ImageFiltered(
              enabled: blur,
              imageFilter: ImageFilter.compose(
                outer: ImageFilter.erode(
                  radiusX: .1,
                  radiusY: 0.3,
                ),
                inner: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              ),
              child: Text(
                "15",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 2),
            Text(
              "Believers",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
        Text("30 Votes"),
        Column(
          children: [
            ImageFiltered(
              enabled: blur,
              imageFilter: ImageFilter.compose(
                outer: ImageFilter.erode(
                  radiusX: .1,
                  radiusY: 0.3,
                ),
                inner: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              ),
              child: Text(
                "15",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 2),
            Text(
              "Challengers",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}

class OpenWindowCheckIn extends StatelessWidget {
  const OpenWindowCheckIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "30 Voters are waiting for your Response",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 16),
        CheckInActions(),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment(-0.8, 0),
          child: Text(
            "If you just showed up that counts",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
          ),
        )
      ],
    );
  }
}

class ClosedWindowCheckIn extends StatelessWidget {
  const ClosedWindowCheckIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckInTimer(),
        const SizedBox(height: 16),
        CheckInActions(
          locked: true,
        ),
        const SizedBox(height: 8),
        SkipWaiting(),
      ],
    );
  }
}

class CheckInActions extends StatelessWidget {
  final bool locked;
  const CheckInActions({
    super.key,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ImageFiltered(
          enabled: locked,
          imageFilter: ImageFilter.blur(
            sigmaX: 1,
            sigmaY: 1,
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    // Handle complete
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: locked
                          ? Color(0xFFB2C8B2)
                          : Color.fromARGB(255, 34, 134, 34),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    // Handle cancel
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: locked
                          ? Color(0xFFC8B2B2)
                          : Color.fromARGB(255, 146, 39, 39),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.airline_seat_flat_angled_sharp,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Failed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (locked) ...[
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const Icon(Icons.lock, color: Colors.black, size: 32),
        ]
      ],
    );
  }
}

class CheckInTimer extends StatelessWidget {
  const CheckInTimer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Checkout',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              '16:00 - 23:00',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          "05:12:00",
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace'),
        ),
      ],
    );
  }
}

class SkipWaiting extends StatelessWidget {
  const SkipWaiting({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Skip'),
        const SizedBox(width: 4),
        const CircleAvatar(
          backgroundColor: Colors.black,
          radius: 10,
          child: Text(
            '3',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
