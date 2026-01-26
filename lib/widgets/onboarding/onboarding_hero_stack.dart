import 'package:flutter/material.dart';

class OnboardingHeroStack extends StatelessWidget {
  const OnboardingHeroStack({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 350,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/icons_car.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 70,
              left: 60,
              child: Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/message-1.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: 70,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/icon-star.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 140,
              right: 30,
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/message-2.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 140,
              left: 10,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/icon-fireworks.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
