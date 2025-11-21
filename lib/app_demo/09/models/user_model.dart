class User {
  final String name;
  final String? iconPath;
  final List<String> friends;

  const User({required this.name, this.iconPath, this.friends = const []});
}
