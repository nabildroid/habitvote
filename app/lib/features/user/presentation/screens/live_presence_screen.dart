import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habitvote/features/user/utils/dicebear_picture.dart';

class LivePresenceScreen extends StatelessWidget {
  const LivePresenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final communityMembers = [
      {'name': 'Igor', 'seed': 'Igor'},
      {'name': 'Hersh', 'seed': 'Hersh'},
      {'name': 'Sravan', 'seed': 'Sravan'},
      {'name': 'Anna', 'seed': 'Anna'},
      {'name': 'John', 'seed': 'John'},
      {'name': 'Zoe', 'seed': 'Zoe'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/world.svg',
            height: 340,
            fit: BoxFit.fitHeight,
            alignment: Alignment(0, -0.9),
            colorFilter: ColorFilter.mode(
              Colors.grey.shade200.withAlpha(170),
              BlendMode.srcIn,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFFD9D9D9),
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 60,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -15),
                    child: const _DayBadge(),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '10k people are here now with\nyou',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'serif',
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black87,
                    ),
                    label: const Text(
                      'Add to Instagram',
                      style: TextStyle(color: Colors.black87),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'COMMUNITY',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: communityMembers.length,
                    itemBuilder: (context, index) {
                      final member = communityMembers[index];
                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.black.withOpacity(0.1),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                DicebearPicture.lorelei(member['seed']!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            member['name']!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  const _DayBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 40,
      child: CustomPaint(
        painter: _BadgePainter(),
        child: const Center(
          child: Text(
            '1 DAY',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1ABC9C);

    final mainPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.7)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height * 0.7)
      ..close();

    final leftRibbon = Path()
      ..moveTo(0, 0)
      ..lineTo(-15, 10)
      ..lineTo(0, 20)
      ..close();

    final rightRibbon = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width + 15, 10)
      ..lineTo(size.width, 20)
      ..close();

    canvas.drawPath(mainPath, paint);
    canvas.drawPath(leftRibbon, paint);
    canvas.drawPath(rightRibbon, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
