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
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
        middle: Text(title, style: _textStyle.copyWith(fontSize: 18)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16),
            Lottie.asset(animationAsset, height: 200),
            SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: paragraphs
                      .map((paragraph) => Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              paragraph,
                              style: _textStyle,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CupertinoButton(
                color: CupertinoColors.white,
                onPressed: () => _launchURL(linkUrl),
                child: Text(
                  linkText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final TextStyle _textStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
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
