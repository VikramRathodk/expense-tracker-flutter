import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../onboarding/onboarding_service.dart';
import '../../../../routes/app_routes.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

class _Feature {
  const _Feature(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _PageData {
  const _PageData({
    required this.gradStart,
    required this.gradEnd,
    required this.illustration,
    required this.title,
    required this.subtitle,
    required this.features,
  });

  final Color gradStart;
  final Color gradEnd;
  final Widget illustration;
  final String title;
  final String subtitle;
  final List<_Feature> features;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  double _pageFraction = 0.0;

  static final _pages = <_PageData>[
    _PageData(
      gradStart: const Color(0xFF6366F1),
      gradEnd: const Color(0xFF312E81),
      illustration: const _ExpenseIllustration(),
      title: 'Know Where Your\nMoney Goes',
      subtitle:
          'Track every expense with categories, tags and notes. Get a clear picture of your spending instantly.',
      features: const [
        _Feature(Icons.category_rounded, '40+ Categories'),
        _Feature(Icons.photo_camera_rounded, 'Receipt Photos'),
        _Feature(Icons.currency_exchange_rounded, 'Multi-Currency'),
      ],
    ),
    _PageData(
      gradStart: const Color(0xFF059669),
      gradEnd: const Color(0xFF064E3B),
      illustration: const _BudgetIllustration(),
      title: 'Budget With\nConfidence',
      subtitle:
          'Set monthly limits per category. Get alerts before you overspend so your finances stay on track.',
      features: const [
        _Feature(Icons.notifications_active_rounded, 'Budget Alerts'),
        _Feature(Icons.pie_chart_rounded, 'Category Limits'),
        _Feature(Icons.shield_rounded, 'Overspend Guard'),
      ],
    ),
    _PageData(
      gradStart: const Color(0xFFEC4899),
      gradEnd: const Color(0xFF831843),
      illustration: const _RecurringIllustration(),
      title: 'Automate\nRecurring Bills',
      subtitle:
          'Set up rent, subscriptions and utilities once. We track them every cycle automatically — no manual entry.',
      features: const [
        _Feature(Icons.repeat_rounded, 'Auto-Tracking'),
        _Feature(Icons.calendar_month_rounded, 'Flexible Cycles'),
        _Feature(Icons.pause_circle_rounded, 'Pause Anytime'),
      ],
    ),
    _PageData(
      gradStart: const Color(0xFFF59E0B),
      gradEnd: const Color(0xFF78350F),
      illustration: const _InsightsIllustration(),
      title: 'Insights That\nInspire Action',
      subtitle:
          'Visualise spending trends, compare months and discover habits that help you reach your financial goals faster.',
      features: const [
        _Feature(Icons.bar_chart_rounded, 'Trend Reports'),
        _Feature(Icons.download_rounded, 'CSV / PDF Export'),
        _Feature(Icons.lightbulb_rounded, 'Smart Insights'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    final p = _pageController.page;
    if (p != null) setState(() => _pageFraction = p);
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await OnboardingService.markComplete();
    if (mounted) context.go(AppRoutes.login);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Color _lerp(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  @override
  Widget build(BuildContext context) {
    final idx = _pageFraction.floor().clamp(0, _pages.length - 1);
    final nextIdx = (idx + 1).clamp(0, _pages.length - 1);
    final t = _pageFraction - idx;

    final topColor = _lerp(_pages[idx].gradStart, _pages[nextIdx].gradStart, t);
    final botColor = _lerp(_pages[idx].gradEnd, _pages[nextIdx].gradEnd, t);
    final accent = _pages[_currentPage].gradStart;

    return Scaffold(
      body: Stack(
        children: [
          // ── Animated gradient ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [topColor, botColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Decorative blobs ───────────────────────────────────────────────
          ..._buildBlobs(t, idx),

          // ── Content ────────────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar: logo + skip
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                  child: Row(
                    children: [
                      // Mini brand
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ExpenseTracker',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        opacity: _currentPage < _pages.length - 1 ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: TextButton(
                          onPressed:
                              _currentPage < _pages.length - 1 ? _finish : null,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page counter
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_currentPage + 1} of ${_pages.length}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => _PageContent(page: _pages[i]),
                  ),
                ),

                // ── Bottom card ───────────────────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(36)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 32,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    MediaQuery.of(context).padding.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dot indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => _DotIndicator(
                              active: i == _currentPage, color: accent),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Navigation row
                      Row(
                        children: [
                          // Back button
                          AnimatedOpacity(
                            opacity: _currentPage > 0 ? 1 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: SizedBox(
                              width: 52,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _currentPage > 0 ? _back : null,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: accent,
                                  side: BorderSide(color: accent, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 20),
                              ),
                            ),
                          ),
                          if (_currentPage > 0) const SizedBox(width: 12),

                          // Continue / Get Started
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: SizedBox(
                                key: ValueKey(
                                    _currentPage == _pages.length - 1),
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _next,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentPage == _pages.length - 1
                                            ? 'Get Started'
                                            : 'Continue',
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        _currentPage == _pages.length - 1
                                            ? Icons.rocket_launch_rounded
                                            : Icons.arrow_forward_rounded,
                                        size: 17,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBlobs(double t, int idx) {
    // Blob positions shift slightly as the user swipes, giving parallax depth
    final shift = _pageFraction * 40;
    return [
      Positioned(
        top: -60,
        right: -50 + shift,
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      Positioned(
        bottom: 180,
        left: -80 + shift * 0.6,
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ),
      Positioned(
        top: 120,
        left: -30 - shift * 0.4,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
      ),
    ];
  }
}

// ─── Page content with entry animation ───────────────────────────────────────

class _PageContent extends StatefulWidget {
  const _PageContent({required this.page});
  final _PageData page;

  @override
  State<_PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<_PageContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Small delay so the page transition completes before content enters
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 16),
          child: Column(
            children: [
              widget.page.illustration,
              const SizedBox(height: 24),

              // Title
              Text(
                widget.page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                widget.page.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 14.5,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),

              // Feature chips
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: widget.page.features
                    .map((f) => _FeatureChip(feature: f))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Feature chip ─────────────────────────────────────────────────────────────

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(feature.icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            feature.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dot indicator ────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.active, required this.color});
  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? color : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Illustration 1 — Expense Tracking ───────────────────────────────────────

class _ExpenseIllustration extends StatefulWidget {
  const _ExpenseIllustration();

  @override
  State<_ExpenseIllustration> createState() => _ExpenseIllustrationState();
}

class _ExpenseIllustrationState extends State<_ExpenseIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final floatY = sin(_ctrl.value * pi) * 7;
        return SizedBox(
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Outer ring
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
              ),
              // Inner ring
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              // Floating wallet icon
              Transform.translate(
                offset: Offset(0, floatY),
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 42,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              // Floating cards
              Positioned(
                top: 10,
                right: 0,
                child: Transform.translate(
                  offset: Offset(0, floatY * 0.6),
                  child: _FloatingCard(
                    icon: Icons.restaurant_rounded,
                    label: 'Food',
                    amount: '₹450',
                    iconColor: const Color(0xFFEF4444),
                  ),
                ),
              ),
              Positioned(
                bottom: 22,
                left: 0,
                child: Transform.translate(
                  offset: Offset(0, -floatY * 0.4),
                  child: _FloatingCard(
                    icon: Icons.directions_car_rounded,
                    label: 'Transport',
                    amount: '₹200',
                    iconColor: const Color(0xFFF59E0B),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Transform.translate(
                  offset: Offset(0, floatY * 0.8),
                  child: _FloatingCard(
                    icon: Icons.shopping_bag_rounded,
                    label: 'Shopping',
                    amount: '₹820',
                    iconColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({
    required this.icon,
    required this.label,
    required this.amount,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String amount;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Illustration 2 — Budgets ─────────────────────────────────────────────────

class _BudgetIllustration extends StatefulWidget {
  const _BudgetIllustration();

  @override
  State<_BudgetIllustration> createState() => _BudgetIllustrationState();
}

class _BudgetIllustrationState extends State<_BudgetIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, child) {
        final p = _progress.value;
        return SizedBox(
          height: 230,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Donut with animated progress
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(110, 110),
                      painter: _DonutPainter(
                        progress: 0.72 * p,
                        foreground: Colors.white,
                        background: Colors.white24,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(72 * p).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'on track',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _AnimBudgetBar(
                  label: 'Food', target: 0.60, progress: p, amount: '₹1,200'),
              const SizedBox(height: 8),
              _AnimBudgetBar(
                  label: 'Shopping',
                  target: 0.35,
                  progress: p,
                  amount: '₹700'),
              const SizedBox(height: 8),
              _AnimBudgetBar(
                  label: 'Transport',
                  target: 0.88,
                  progress: p,
                  amount: '₹880',
                  color: Colors.orangeAccent),
            ],
          ),
        );
      },
    );
  }
}

class _AnimBudgetBar extends StatelessWidget {
  const _AnimBudgetBar({
    required this.label,
    required this.target,
    required this.progress,
    required this.amount,
    this.color = Colors.white,
  });

  final String label;
  final double target;
  final double progress;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: target * progress,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.progress,
    required this.foreground,
    required this.background,
  });

  final double progress;
  final Color foreground;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 13.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - stroke / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = background
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = foreground
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => progress != old.progress;
}

// ─── Illustration 3 — Recurring ──────────────────────────────────────────────

class _RecurringIllustration extends StatefulWidget {
  const _RecurringIllustration();

  @override
  State<_RecurringIllustration> createState() =>
      _RecurringIllustrationState();
}

class _RecurringIllustrationState extends State<_RecurringIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final floatY = sin(_ctrl.value * pi * 2) * 6;
        return SizedBox(
          height: 230,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating dashed ring
                  Transform.rotate(
                    angle: _ctrl.value * 2 * pi,
                    child: CustomPaint(
                      size: const Size(120, 120),
                      painter: _DashedCirclePainter(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // Center calendar icon
                  Transform.translate(
                    offset: Offset(0, floatY),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.repeat_rounded,
                        size: 38,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Subscription cards row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SubCard(
                      label: 'Netflix',
                      amount: '₹649',
                      icon: Icons.play_circle_rounded,
                      color: const Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  _SubCard(
                      label: 'Spotify',
                      amount: '₹119',
                      icon: Icons.music_note_rounded,
                      color: const Color(0xFF22C55E)),
                  const SizedBox(width: 8),
                  _SubCard(
                      label: 'Rent',
                      amount: '₹8K',
                      icon: Icons.home_rounded,
                      color: const Color(0xFF3B82F6)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SubCard extends StatelessWidget {
  const _SubCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashCount = 16;
    const dashAngle = 2 * pi / dashCount;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle * 0.45,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => color != old.color;
}

// ─── Illustration 4 — Insights ────────────────────────────────────────────────

class _InsightsIllustration extends StatefulWidget {
  const _InsightsIllustration();

  @override
  State<_InsightsIllustration> createState() => _InsightsIllustrationState();
}

class _InsightsIllustrationState extends State<_InsightsIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _enter;

  static const _bars = [0.35, 0.60, 0.45, 0.75, 0.55, 0.70, 0.90];
  static const _months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _enter = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (_, child) {
        final p = _enter.value;
        return SizedBox(
          height: 230,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trend badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved ${(28 * p).toStringAsFixed(0)}% more',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'compared to last month',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bar chart
              Container(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 72,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_bars.length, (i) {
                          final isLast = i == _bars.length - 1;
                          final h = 72 * _bars[i] * p;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isLast)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    '↑',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              AnimatedContainer(
                                duration: Duration.zero,
                                width: 24,
                                height: h,
                                decoration: BoxDecoration(
                                  color: isLast
                                      ? Colors.white
                                      : Colors.white
                                          .withValues(alpha: 0.3),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        _months.length,
                        (i) => Text(
                          _months[i],
                          style: TextStyle(
                            color: Colors.white.withValues(
                                alpha: i == _months.length - 1 ? 1.0 : 0.5),
                            fontSize: 9,
                            fontWeight: i == _months.length - 1
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
