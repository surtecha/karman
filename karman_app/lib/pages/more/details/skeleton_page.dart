import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class SkeletonPage extends StatelessWidget {
  final String title;
  final String animationAsset;
  final String linkText;
  final String linkUrl;
  final List<String> paragraphs;

  const SkeletonPage({
    super.key,
    required this.title,
    required this.animationAsset,
    required this.linkText,
    required this.linkUrl,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final animationHeight = screenSize.height * 0.25; // 25% of screen height

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
        middle: Text(title, style: _textStyle.copyWith(fontSize: 18)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Lottie.asset(
                  animationAsset,
                  height: animationHeight,
                ),
                const SizedBox(height: 24),
                ...paragraphs.map((paragraph) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        paragraph,
                        style: _textStyle,
                        textAlign: TextAlign.justify,
                      ),
                    )),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: CupertinoButton(
                    color: CupertinoColors.white,
                    onPressed: () => _launchURL(linkUrl),
                    child: Text(
                      linkText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const TextStyle _textStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: CupertinoColors.white,
  );

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }
}
