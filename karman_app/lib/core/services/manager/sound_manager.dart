import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SoundManager {
  final AudioPlayer backgroundPlayer = AudioPlayer();

  final List<Map<String, dynamic>> sounds = [
    {
      'name': 'None',
      'icon': CupertinoIcons.speaker_slash_fill,
      'file': null,
      'color': CupertinoColors.systemGrey
    },
    {
      'name': 'Rain',
      'icon': CupertinoIcons.cloud_heavyrain_fill,
      'file': 'lib/assets/audio/rain.mp3',
      'color': CupertinoColors.systemCyan
    },
    {
      'name': 'Night',
      'icon': CupertinoIcons.moon_fill,
      'file': 'lib/assets/audio/night.mp3',
      'color': CupertinoColors.systemPurple
    },
    {
      'name': 'Ocean',
      'icon': Icons.waves,
      'file': 'lib/assets/audio/ocean.mp3',
      'color': CupertinoColors.activeBlue
    },
    {
      'name': 'Forest',
      'icon': Icons.forest,
      'file': 'lib/assets/audio/forest.mp3',
      'color': CupertinoColors.systemGreen
    },
    {
      'name': 'Airplane',
      'icon': CupertinoIcons.airplane,
      'file': 'lib/assets/audio/airplane.mp3',
      'color': CupertinoColors.systemIndigo
    },
  ];

  String? currentSound;

  Future<void> playSelectedSound() async {
    if (currentSound != null) {
      await backgroundPlayer.setAsset(currentSound!);
      await backgroundPlayer.setLoopMode(LoopMode.one);
      backgroundPlayer.play();
    }
  }

  Future<void> stopBackgroundSound() async {
    await backgroundPlayer.stop();
  }

  void dispose() {
    backgroundPlayer.dispose();
  }

  IconData get currentIcon {
    if (currentSound == null) {
      return CupertinoIcons.speaker_slash;
    }
    return sounds.firstWhere((sound) => sound['file'] == currentSound)['icon'];
  }
}
