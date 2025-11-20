import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5F0);

    return Container(
      color: backgroundColor,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {
              // 如果是 Tab 页可能不需要返回，这里保留 UI 还原
            },
          ),
          centerTitle: true,
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          children: [
            // 1. Subscription Section
            const _SectionTitle('Subscription'),
            const SizedBox(height: 12),
            _PremiumCard(
              title: 'Walkie Talkie Plus',
              subtitle: 'Talk longer, Ad free, themes\nand more!',
              icon: Icons.verified, // 临时用 Verified 图标代替皇冠
              iconColor: const Color(0xFFFFD200),
              iconBgColor: const Color(0xFF00D68F), // 绿色背景
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _SettingItem(title: 'Redeem code', onTap: () {}),

            const SizedBox(height: 24),

            // 2. Content & display
            const _SectionTitle('Content & display'),
            const SizedBox(height: 12),
            _SettingItem(
              title: 'Frequency language',
              trailingText: '中文 & other langua...',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _SettingItem(title: 'Notifications', onTap: () {}),

            const SizedBox(height: 24),

            // 3. Account
            const _SectionTitle('Account'),
            const SizedBox(height: 12),
            _SettingItem(title: 'Account', onTap: () {}),
            const SizedBox(height: 12),
            _SettingItem(title: 'Safety & Privacy', onTap: () {}),

            const SizedBox(height: 24),

            // 4. Support & about
            const _SectionTitle('Support & about'),
            const SizedBox(height: 12),
            _SettingItem(title: 'Read our rule book', onTap: () {}),
            const SizedBox(height: 12),
            _SettingItem(title: 'Contact our support', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

/// 列表小标题
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 普通设置项
class _SettingItem extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const _SettingItem({
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800, // 较粗的字体
                    color: Colors.black,
                  ),
                ),
              ),
              if (trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    trailingText!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const Icon(Icons.chevron_right, color: Colors.black, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// 带有图标的高级卡片 (Walkie Talkie Plus)
class _PremiumCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _PremiumCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 图标容器
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events_outlined, // 皇冠形状的图标
                  color: iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // 文本区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
