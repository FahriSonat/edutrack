// ==============================================================================
// 📌 DOSYA: lib/core/widgets/bouncy_card.dart
// 📌 AÇIKLAMA: Mikro-etkileşimli basma hissiyatı sunan modern kart bileşeni.
//              Kullanıcı dokunduğunda kartı hafifçe küçültür (scale down: 0.975),
//              isteğe bağlı sol vurgu şeridi (accent ribbon) ve gölge animasyonu sunar.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// [BouncyCard], standart `Card` veya `Container` yerine dokunsal geri bildirim
/// sağlayan animasyonlu bir kart bileşenidir.
class BouncyCard extends StatefulWidget {
  /// Kartın içerisindeki ana widget
  final Widget child;

  /// Tıklama olayı (null ise kart sadece statik gösterim yapar)
  final VoidCallback? onTap;

  /// İç dolgu
  final EdgeInsetsGeometry padding;

  /// Dış kenar boşluğu
  final EdgeInsetsGeometry margin;

  /// Zemin rengi (varsayılan: [AppColors.surfaceContainer])
  final Color? color;

  /// Kenar yuvarlaklığı (varsayılan: 22px)
  final double borderRadius;

  /// İsteğe bağlı özel kenarlık
  final Border? border;

  /// Sol dikey renk şeridi rengi (Accent Ribbon)
  final Color? accentColor;

  /// Sol şerit kalınlığı (varsayılan: 5.0 px)
  final double accentWidth;

  const BouncyCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.color,
    this.borderRadius = 22,
    this.border,
    this.accentColor,
    this.accentWidth = 5.0,
  });

  @override
  State<BouncyCard> createState() => _BouncyCardState();
}

class _BouncyCardState extends State<BouncyCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  // ==========================================================================
  // 🔄 YAŞAM DÖNGÜSÜ (LIFECYCLE)
  // ==========================================================================
  @override
  void initState() {
    super.initState();
    // 120 ms süreli hızlı ve akıcı basma animasyonu
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.975).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ==========================================================================
  // 👆 JEST VE DOKUNMA YÖNETİMİ
  // ==========================================================================
  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  // ==========================================================================
  // 🎨 ARAYÜZ İNŞASI (BUILD)
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final effectiveBorder = widget.border ??
        Border.all(
          color: _isPressed
              ? (widget.accentColor ?? AppColors.primary).withValues(alpha: 0.6)
              : AppColors.outlineSoft,
          width: _isPressed ? 1.2 : 0.8,
        );

    return Padding(
      padding: widget.margin,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: widget.onTap != null ? _handleTapDown : null,
        onTapUp: widget.onTap != null ? _handleTapUp : null,
        onTapCancel: widget.onTap != null ? _handleTapCancel : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: widget.color ?? AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: effectiveBorder,
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: (widget.accentColor ?? AppColors.primary).withValues(alpha: 0.16),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: widget.accentColor == null
                  ? Padding(
                      padding: widget.padding,
                      child: widget.child,
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sol Renk Şeridi (Accent Ribbon)
                          Container(
                            width: widget.accentWidth,
                            decoration: BoxDecoration(
                              color: widget.accentColor,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accentColor!.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                  offset: const Offset(2, 0),
                                ),
                              ],
                            ),
                          ),
                          // Kart İçeriği
                          Expanded(
                            child: Padding(
                              padding: widget.padding,
                              child: widget.child,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
