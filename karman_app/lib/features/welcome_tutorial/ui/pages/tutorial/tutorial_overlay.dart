import 'package:flutter/cupertino.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TutorialOverlay extends StatefulWidget {
  final List<TutorialPage> pages;
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.pages,
    required this.onComplete,
  });

  @override
  _TutorialOverlayState createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < widget.pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5),
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray.withOpacity(0.97),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            widget.pages[index].instruction,
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Image.asset(
                              widget.pages[index].imageAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _currentPage > 0
                        ? CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _previousPage,
                            child: Icon(CupertinoIcons.chevron_left,
                                color: CupertinoColors.white),
                          )
                        : SizedBox(width: 44),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: widget.pages.length,
                      effect: WormEffect(
                        dotColor: CupertinoColors.systemGrey,
                        activeDotColor: CupertinoColors.white,
                        dotHeight: 10,
                        dotWidth: 10,
                      ),
                    ),
                    _currentPage < widget.pages.length - 1
                        ? CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _nextPage,
                            child: Icon(CupertinoIcons.chevron_right,
                                color: CupertinoColors.white),
                          )
                        : CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: widget.onComplete,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: CupertinoColors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                CupertinoIcons.chevron_right,
                                color: CupertinoColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialPage {
  final String instruction;
  final String imageAsset;

  TutorialPage({
    required this.instruction,
    required this.imageAsset,
  });
}
