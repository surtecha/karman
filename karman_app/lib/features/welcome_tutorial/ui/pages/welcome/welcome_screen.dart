import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karman_app/app_shell.dart';
import 'package:karman_app/features/welcome_tutorial/ui/pages/welcome/welcome_content.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _chevronOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  bool _isLastPage = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _widthAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _chevronOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1, curve: Curves.easeInCubic),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _isLastPage = index == welcomePages.length + 1;
                        if (_isLastPage) {
                          _animationController.forward();
                        } else {
                          _animationController.reverse();
                        }
                      });
                    },
                    children: [
                      _buildWelcomePage(constraints),
                      ...welcomePages.map(
                          (content) => _buildFeaturePage(content, constraints)),
                      _buildFinalPage(constraints),
                    ],
                  ),
                ),
                SizedBox(
                  height: constraints.maxHeight * 0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return SizedBox(
                            width: 60 + (140 * _widthAnimation.value),
                            height: 60,
                            child: CupertinoButton(
                              onPressed: _isLastPage
                                  ? _finishOnboarding
                                  : () {
                                      _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                              padding: EdgeInsets.zero,
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(30),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Opacity(
                                    opacity: _chevronOpacityAnimation.value,
                                    child: const Icon(
                                      Icons.chevron_right_rounded,
                                      color: CupertinoColors.black,
                                      size: 40,
                                    ),
                                  ),
                                  Opacity(
                                    opacity: _textOpacityAnimation.value,
                                    child: const Text(
                                      "Let's rock!",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: welcomePages.length + 2,
                        effect: const WormEffect(
                          dotColor: CupertinoColors.systemGrey,
                          activeDotColor: CupertinoColors.white,
                          dotHeight: 10,
                          dotWidth: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BoxConstraints constraints) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: constraints.maxHeight * 0.1),
        Image.asset('lib/assets/images/icon/iOS/icon.png',
            height: constraints.maxHeight * 0.2),
        SizedBox(height: constraints.maxHeight * 0.05),
        const Text(
          'Welcome to karman',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white),
        ),
      ],
    );
  }

  Widget _buildFeaturePage(
      WelcomePageContent content, BoxConstraints constraints) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: constraints.maxHeight * 0.1),
        Text(
          content.title,
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: constraints.maxHeight * 0.05),
        SizedBox(
          height: constraints.maxHeight * 0.4,
          child: Lottie.asset(
            content.lottieAsset,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.05),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            content.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: CupertinoColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalPage(BoxConstraints constraints) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: constraints.maxHeight * 0.1),
        const Text(
          'Open Source',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white),
        ),
        SizedBox(height: constraints.maxHeight * 0.05),
        SizedBox(
          height: constraints.maxHeight * 0.4,
          child: Lottie.asset(
            'lib/assets/lottie/github.json',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.05),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'karman is an open-source productivity app. Contribute and make it better!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: CupertinoColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    final lastUsedTabIndex = prefs.getInt('lastUsedTabIndex') ?? 1;

    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (context) => AppShell(
          key: AppShell.globalKey,
          initialTabIndex: lastUsedTabIndex,
        ),
      ),
    );
  }
}
