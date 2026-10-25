/// 素材路径集中管理，页面不直接拼 assets 字符串。
abstract final class PipAssets {
  static const pip = 'assets/images/15/pip.svg';
  static const birdWave = 'assets/images/15/bird_wave.svg';
  static const birdThink = 'assets/images/15/bird_think.svg';
  static const birdCelebrate = 'assets/images/15/bird_celebrate.svg';

  static const chime = 'assets/audio/15/chime.wav';

  static String icon(String name) => 'assets/images/15/icons/$name.svg';

  static String option(String name) => 'assets/images/15/option_$name.svg';

  static String audio(String name) => 'assets/audio/15/$name.wav';
}
