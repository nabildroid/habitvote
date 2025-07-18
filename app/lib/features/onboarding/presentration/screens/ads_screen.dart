import 'package:flutter/material.dart';
import 'package:habitvote/features/onboarding/presentration/screens/onboarding_screen.dart';
import 'package:habitvote/shared/widgets/brilliant_ok_button.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  final cards = [
    [
      "Learning new Words is easy, Actually",
      "this is proven technique to learn new words in real life context",
      "https://github.com/nabildroid.png"
    ],
    [
      "2Learning new Words is easy, Actually",
      "this is proven technique to learn new words in real life context",
      "https://github.com/next1.png"
    ],
  ];

  int page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor: .45,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  image: DecorationImage(
                    image: NetworkImage(cards[page][2]),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: .6,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: PageView(
                        onPageChanged: (i) => setState(() {
                          page = i;
                        }),
                        children: cards
                            .map(
                              (card) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 20),
                                  Text(
                                    card[0],
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    card[1],
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: cards
                                .map((e) => CircleAvatar(
                                      radius: 5,
                                      backgroundColor: page == cards.indexOf(e)
                                          ? Colors.black
                                          : Colors.grey,
                                    ))
                                .toList()),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      persistentFooterButtons: [
        BrilliantOkButton(
          tag: "continue",
          text: "Next",
          onPressed: () => Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  OnboardingScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var begin = Offset(1.0, 0.0); // Start from right
                var end = Offset.zero;
                var curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 300),
            ),
          ),
        )
      ],
    );
  }
}
