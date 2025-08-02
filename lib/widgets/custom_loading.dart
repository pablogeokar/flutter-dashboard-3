import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/theme.dart';

enum LoadingType { circular, linear, dots }

enum LoadingSize { small, medium, large }

class CustomLoading extends StatelessWidget {
  final LoadingType type;
  final LoadingSize size;
  final String? message;
  final Color? color;
  final bool isFullScreen;

  const CustomLoading({
    super.key,
    this.type = LoadingType.circular,
    this.size = LoadingSize.medium,
    this.message,
    this.color,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loadingColor = color ?? AppTheme.primaryColor;

    Widget loadingWidget = _buildLoadingWidget(loadingColor);

    if (message != null) {
      loadingWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingWidget,
          const SizedBox(height: AppTheme.spacingM),
          Text(
            message!,
            style: AppTheme.body2.copyWith(
              color: isDark ? Colors.grey : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (isFullScreen) {
      return Container(
        color: isDark
            ? Colors.black.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.9),
        child: Center(child: loadingWidget),
      );
    }

    return Center(child: loadingWidget);
  }

  Widget _buildLoadingWidget(Color color) {
    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: _getSize(),
          height: _getSize(),
          child: CircularProgressIndicator(
            strokeWidth: _getStrokeWidth(),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );

      case LoadingType.linear:
        return SizedBox(
          width: _getSize(),
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: color.withValues(alpha: 0.2),
          ),
        );

      case LoadingType.dots:
        return _buildDotsLoading(color);
    }
  }

  Widget _buildDotsLoading(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 200)),
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: _getDotSize(),
              height: _getDotSize(),
              decoration: BoxDecoration(
                color: color.withValues(alpha: value),
                shape: BoxShape.circle,
              ),
            );
          },
          onEnd: () {
            // Reinicia a animação
          },
        );
      }),
    );
  }

  double _getSize() {
    switch (size) {
      case LoadingSize.small:
        return 20;
      case LoadingSize.medium:
        return 32;
      case LoadingSize.large:
        return 48;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 3;
      case LoadingSize.large:
        return 4;
    }
  }

  double _getDotSize() {
    switch (size) {
      case LoadingSize.small:
        return 6;
      case LoadingSize.medium:
        return 8;
      case LoadingSize.large:
        return 12;
    }
  }
}

class CustomLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final LoadingType loadingType;
  final LoadingSize loadingSize;

  const CustomLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.loadingType = LoadingType.circular,
    this.loadingSize = LoadingSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          CustomLoading(
            type: loadingType,
            size: loadingSize,
            message: loadingMessage,
            isFullScreen: true,
          ),
      ],
    );
  }
}
