/// 稳定的菜单身份；未交付的游戏没有可用路由。
class GameDefinition {
  final String id;
  final String title;
  final String subtitle;
  final String? route;

  const GameDefinition(this.id, this.title, this.subtitle, {this.route});

  bool get isAvailable => route != null;
}

const partyGames = [
  GameDefinition('headbands', 'Headbands', '举手机猜词'),
  GameDefinition('truth-dare', 'Truth or Dare', '真心话大冒险'),
  GameDefinition('bottle', 'Spin the Bottle', '转瓶子'),
  GameDefinition('charades', 'Charades', '你演我猜'),
  GameDefinition('would-rather', 'Would You Rather', '二选一'),
  GameDefinition('dice', 'Roll the Dice', '掷骰子'),
  GameDefinition('coin', 'Coin Toss', '抛硬币', route: '/coin'),
  GameDefinition('pick', 'Pick One', '随机选人'),
  GameDefinition('elimination', 'Elimination', '淘汰游戏'),
  GameDefinition('teams', 'Build Teams', '随机分组'),
];
