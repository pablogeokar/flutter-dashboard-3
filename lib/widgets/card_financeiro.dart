import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/widgets/custom_card.dart';

class CardFinanceiro extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;

  const CardFinanceiro({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      variant: CardVariant.default_,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine if we should use vertical or horizontal layout
            bool useVerticalLayout = constraints.maxWidth < 200;

            if (useVerticalLayout) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icone, color: cor, size: 24),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    titulo,
                    style: AppTheme.caption.copyWith(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      valor,
                      style: AppTheme.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icone, color: cor, size: 24),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          titulo,
                          style: AppTheme.body2.copyWith(
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            valor,
                            style: AppTheme.headline4.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class CardFinanceiro extends StatelessWidget {
//   final String titulo;
//   final String valor;
//   final IconData icone;
//   final Color cor;
//   final bool multiLinha;

//   const CardFinanceiro({
//     super.key,
//     required this.titulo,
//     required this.valor,
//     required this.icone,
//     required this.cor,
//     this.multiLinha = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Card(
//       elevation: 2,
//       color: isDark ? const Color(0xFF2A2A2A) : theme.colorScheme.surface,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(
//           color: isDark ? const Color(0xFF424242) : theme.colorScheme.outline,
//           width: 1,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   titulo,
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     color: theme.colorScheme.onSurface.withOpacity(0.7),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: cor.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(icone, color: cor, size: 20),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if (multiLinha && valor.contains('\n'))
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: valor.split('\n').map((linha) {
//                   return Text(
//                     linha,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   );
//                 }).toList(),
//               )
//             else
//               Text(
//                 valor,
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
