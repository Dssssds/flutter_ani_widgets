import 'package:flutter/material.dart';

import '../models/session_model.dart';
import '../utils/constants.dart';
import '../widgets/circular_timer.dart';
import '../widgets/goal_card.dart';
import '../widgets/progress_bar.dart';
import '../widgets/session_card.dart';
import '../widgets/user_avatar.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  // 会话状态
  bool _isTimerRunning = false;
  bool _isTimerReset = false;
  Duration _currentDuration = Duration.zero;
  late Session _currentSession;
  late List<Session> _previousSessions;
  late User _currentUser;
  
  // 当前选中的历史会话ID，默认选中第二个会话（索引为1）
  String _selectedSessionId = '';

  @override
  void initState() {
    super.initState();
    // 初始化数据
    _currentSession = SessionService.getCurrentSession();
    _previousSessions = SessionService.getPreviousSessions();
    _currentUser = SessionService.currentUser;
    _currentDuration = _currentSession.duration;
    
    // 默认选中第二个会话（索引为1）
    if (_previousSessions.isNotEmpty && _previousSessions.length > 1) {
      _selectedSessionId = _previousSessions[1].id;
    }
  }

  // 播放/继续计时器
  void _playTimer() {
    if (!_isTimerRunning) {
      setState(() {
        _isTimerRunning = true;
        _isTimerReset = false;
        // 如果是从重置状态开始，重新初始化当前持续时间
        if (_currentDuration == Duration.zero) {
          _currentDuration = _currentSession.duration;
        }
      });
    }
  }
  
  // 暂停计时器
  void _pauseTimer() {
    if (_isTimerRunning) {
      setState(() {
        _isTimerRunning = false;
      });
    }
  }
  
  // 停止并重置计时器
  void _stopTimer() {
    setState(() {
      _isTimerRunning = false;
      _isTimerReset = true;
      // 重置回初始持续时间
      _currentDuration = Duration.zero;
      
      // 延迟一帧后再重新设置为会话的初始时间，确保UI已经响应重置状态
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _currentDuration = _currentSession.duration;
          });
        }
      });
    });
  }
  
  // 计时器完成回调
  void _onTimerComplete() {
    setState(() {
      _isTimerRunning = false;
      // 这里可以添加计时器完成后的逻辑
      // 例如显示祝贺消息、保存会话结果等
    });
  }
  
  // 更新当前持续时间（用于在CircularTimer中回传当前时间）
  void _updateCurrentDuration(Duration duration) {
    setState(() {
      _currentDuration = duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 禁用自动添加返回按钮
        titleSpacing: 0, // 移除标题左侧的默认间距
        title: Row(
          children: [
            // 自定义返回按钮
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            // 标题内容
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set 1',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currentSession.title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        // 确保AppBar内容靠左对齐
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息
            _buildUserInfo(),
            const SizedBox(height: 8),

            // 进度条
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SessionProgressBar(
                progress: _currentSession.progress,
                label:
                    'Session Outcome: ${(_currentSession.progress * 100).toInt()}%',
              ),
            ),
            const SizedBox(height: 24),

            // 计时器和控制按钮区域
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    // 计时器
                    Center(
                      child: CircularTimer(
                        key: ValueKey<bool>(_isTimerReset), // 添加key以确保重置时重建组件
                        duration: _currentDuration,
                        targetDuration: _currentSession.targetDuration,
                        isRunning: _isTimerRunning,
                        onComplete: _onTimerComplete,
                        onDurationChange: _updateCurrentDuration,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isTimerRunning ? 'Timer is running' : 'Timer is paused',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 控制按钮
                    _buildControlButtons(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 会话目标
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSessionGoals(),
            ),
            const SizedBox(height: 16),

            // 会话笔记
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSessionNotes(),
            ),
            const SizedBox(height: 16),

            // 历史会话
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildPreviousSessions(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 构建用户信息
  Widget _buildUserInfo() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 用户头像
            const UserAvatar(
              initials: 'OJ',
              size: 40,
            ),
            const SizedBox(width: 16),
            // 用户信息
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _currentSession.timeOfDay,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

    // 构建控制按钮
  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 播放按钮
          Expanded(
            child: Opacity(
              opacity: _isTimerRunning ? 0.6 : 1.0, // 运行时降低不可用按钮的透明度
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isTimerRunning ? null : _playTimer, // 运行时禁用播放按钮
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow,
                            color: AppColors.green,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 停止按钮
          Expanded(
            child: Opacity(
              opacity: _isTimerRunning ? 1.0 : 0.6, // 未运行时降低不可用按钮的透明度
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isTimerRunning ? _stopTimer : null, // 未运行时禁用停止按钮
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.stop,
                            color: AppColors.orange,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建会话目标
  Widget _buildSessionGoals() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Goal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GoalCard(
                icon: Icons.flash_on,
                title: 'Target',
                value: '8 minutes',
                backgroundColor: AppColors.primaryBlue,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GoalCard(
                icon: Icons.check_circle,
                title: 'Current',
                value: '5:23 / 8:00',
                backgroundColor: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 构建会话笔记
  Widget _buildSessionNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Session Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _currentSession.notes,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // 构建历史会话
  Widget _buildPreviousSessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Previous Sessions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // 使用 Padding 而不是 ListView.builder 以匹配截图样式
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: List.generate(_previousSessions.length, (index) {
              final session = _previousSessions[index];
              
              return SessionCard(
                session: session,
                isSelected: session.id == _selectedSessionId,
                onTap: () {
                  // 处理会话点击
                  setState(() {
                    // 更新选中的会话ID
                    _selectedSessionId = session.id;
                  });
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
