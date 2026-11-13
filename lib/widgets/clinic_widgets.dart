import 'package:flutter/material.dart';

import '../app/clinic_models.dart';
import '../app/clinic_theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.centered = false, this.large = false});

  final bool centered;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final markSize = large ? 68.0 : 46.0;
    return Row(
      mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: centered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Container(
          width: markSize,
          height: markSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ClinicColors.blue, ClinicColors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(large ? 22 : 15),
            boxShadow: [
              BoxShadow(
                color: ClinicColors.blue.withValues(alpha: .2),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.medical_services_rounded,
            color: Colors.white,
            size: large ? 36 : 25,
          ),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SmartClinic',
              style: TextStyle(
                color: ClinicColors.navy,
                fontSize: large ? 22 : 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 1),
            const Text(
              'Klinik dalam genggaman',
              style: TextStyle(color: ClinicColors.muted, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}

class ClinicCard extends StatelessWidget {
  const ClinicCard({super.key, required this.child, this.padding = 18});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ClinicColors.line.withValues(alpha: .8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF234B43).withValues(alpha: .045),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: ClinicColors.blue,
              padding: EdgeInsets.zero,
            ),
            child: Text(action!),
          ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: ClinicColors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        child: busy
            ? const SizedBox.square(
                dimension: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label),
                  const SizedBox(width: 9),
                  Icon(icon, size: 19),
                ],
              ),
      ),
    );
  }
}

class PatientAvatar extends StatelessWidget {
  const PatientAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.color,
  });

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: (color ?? ClinicColors.blue).withValues(alpha: .12),
        borderRadius: BorderRadius.circular(size * .36),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: color ?? ClinicColors.blue,
          fontSize: size * .4,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class VisitStatusChip extends StatelessWidget {
  const VisitStatusChip({super.key, required this.status});

  final VisitStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      VisitStatus.scheduled => ('Terjadwal', ClinicColors.green),
      VisitStatus.cancelled => ('Dibatalkan', ClinicColors.red),
      VisitStatus.completed => ('Selesai', ClinicColors.blue),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String clinicDate(DateTime date, {bool withWeekday = false}) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  const weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  final dateLabel = '${date.day} ${months[date.month - 1]} ${date.year}';
  return withWeekday ? '${weekdays[date.weekday - 1]}, $dateLabel' : dateLabel;
}

String timeAgo(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} menit lalu';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} jam lalu';
  }
  if (difference.inDays == 1) {
    return 'Kemarin';
  }
  return '${difference.inDays} hari lalu';
}
