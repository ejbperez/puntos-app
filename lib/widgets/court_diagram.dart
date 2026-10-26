import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';

class CourtDiagram extends StatelessWidget {
  const CourtDiagram({super.key, required this.match, this.height = 190, this.onTap});

  final Match match;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final players = [...match.teamAPlayers, ...match.teamBPlayers];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardDarkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardDarkBorder, width: 1.2),
        ),
        child: Column(
          children: [
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(size: Size.infinite, painter: _CourtPainter(match)),
            )),
            const SizedBox(height: 6),
            Row(
              children: players.map((p) => Expanded(
                child: Text(
                  '${p.label} · ${p.name}${p.id == match.currentServerId ? '  •' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.id == match.currentServerId
                        ? AppColors.servingGreen
                        : AppColors.textMutedDark,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourtPainter extends CustomPainter {
  const _CourtPainter(this.match);
  final Match match;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF1E7E4E);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(8)), bg);
    final rect = Rect.fromLTWH(size.width * .04, size.height * .08,
        size.width * .92, size.height * .84);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final net = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawRect(rect, line);
    final centerX = rect.center.dx;
    canvas.drawLine(Offset(centerX, rect.top), Offset(centerX, rect.bottom), net);

    switch (match.sport.id) {
      case 'pickleball':
        _drawPickleball(canvas, rect, line);
        break;
      case 'tennis':
        _drawTennis(canvas, rect, line);
        break;
      default:
        _drawBadminton(canvas, rect, line);
    }
    _drawServiceHighlight(canvas, rect, line);
    _drawPlayers(canvas, rect);
  }

  void _drawBadminton(Canvas canvas, Rect rect, Paint line) {
    final short = rect.width * .16;
    final long = rect.width * .08;
    final leftShort = rect.center.dx - rect.width * .16;
    final rightShort = rect.center.dx + rect.width * .16;
    canvas.drawLine(Offset(leftShort, rect.top), Offset(leftShort, rect.bottom), line);
    canvas.drawLine(Offset(rightShort, rect.top), Offset(rightShort, rect.bottom), line);
    canvas.drawLine(Offset(rect.left + long, rect.top), Offset(rect.left + long, rect.bottom), line);
    canvas.drawLine(Offset(rect.right - long, rect.top), Offset(rect.right - long, rect.bottom), line);
    canvas.drawLine(Offset(rect.left, rect.center.dy), Offset(leftShort, rect.center.dy), line);
    canvas.drawLine(Offset(rightShort, rect.center.dy), Offset(rect.right, rect.center.dy), line);
    // Singles sidelines are inset from the doubles sidelines.
    canvas.drawLine(Offset(rect.left + short, rect.top), Offset(rect.left + short, rect.bottom), line);
    canvas.drawLine(Offset(rect.right - short, rect.top), Offset(rect.right - short, rect.bottom), line);
  }

  void _drawPickleball(Canvas canvas, Rect rect, Paint line) {
    final zone = rect.width * .18;
    canvas.drawLine(Offset(rect.center.dx - zone, rect.top),
        Offset(rect.center.dx - zone, rect.bottom), line);
    canvas.drawLine(Offset(rect.center.dx + zone, rect.top),
        Offset(rect.center.dx + zone, rect.bottom), line);
    canvas.drawLine(Offset(rect.left, rect.center.dy),
        Offset(rect.right, rect.center.dy), line);
  }

  void _drawTennis(Canvas canvas, Rect rect, Paint line) {
    final service = rect.width * .22;
    final left = rect.center.dx - service;
    final right = rect.center.dx + service;
    canvas.drawLine(Offset(left, rect.top), Offset(left, rect.bottom), line);
    canvas.drawLine(Offset(right, rect.top), Offset(right, rect.bottom), line);
    canvas.drawLine(Offset(left, rect.center.dy), Offset(right, rect.center.dy), line);
    final singles = rect.height * .12;
    canvas.drawLine(Offset(rect.left, rect.top + singles),
        Offset(rect.right, rect.top + singles), line);
    canvas.drawLine(Offset(rect.left, rect.bottom - singles),
        Offset(rect.right, rect.bottom - singles), line);
  }

  void _drawServiceHighlight(Canvas canvas, Rect rect, Paint line) {
    final right = match.serviceCourtSide == CourtSide.right;
    final servingA = match.servingTeam == TeamSide.teamA;
    final start = servingA ? rect.left : rect.center.dx;
    final end = servingA ? rect.center.dx : rect.right;
    final top = right ? rect.center.dy : rect.top;
    final bottom = right ? rect.bottom : rect.center.dy;
    final box = Rect.fromLTRB(start, top, end, bottom);
    final fill = Paint()..color = AppColors.servingGreen.withValues(alpha: .25);
    final border = Paint()
      ..color = AppColors.servingGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(box, fill);
    canvas.drawRect(box, border);
  }

  void _drawPlayers(Canvas canvas, Rect rect) {
    final all = [...match.teamAPlayers, ...match.teamBPlayers];
    for (final player in all) {
      final teamIsA = player.team == TeamSide.teamA;
      final teamRect = teamIsA
          ? Rect.fromLTRB(rect.left, rect.top, rect.center.dx, rect.bottom)
          : Rect.fromLTRB(rect.center.dx, rect.top, rect.right, rect.bottom);
      final vertical = player.currentCourtSide == CourtSide.right ? .67 : .33;
      final sameSide = all.where((p) => p.team == player.team &&
          p.currentCourtSide == player.currentCourtSide).toList();
      final offset = sameSide.indexOf(player) * 22.0 -
          ((sameSide.length - 1) * 11.0);
      final center = Offset(teamRect.center.dx + offset,
          teamRect.top + teamRect.height * vertical);
      final server = player.id == match.currentServerId;
      final receiver = player.id == match.currentReceiverId;
      if (receiver && !server) {
        canvas.drawCircle(center, 16, Paint()
          ..color = Colors.white.withValues(alpha: .9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
      }
      final marker = Paint()
        ..color = server
            ? AppColors.servingGreen
            : (teamIsA ? AppColors.teamA : AppColors.teamB);
      canvas.drawCircle(center, 13, marker);
      canvas.drawCircle(center, 13, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1);
      final text = TextPainter(
        text: TextSpan(text: player.label, style: TextStyle(
            color: server ? AppColors.darkBackground : Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800)),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, center - Offset(text.width / 2, text.height / 2));
    }
  }

  @override
  bool shouldRepaint(_CourtPainter oldDelegate) => oldDelegate.match != match ||
      oldDelegate.match.currentServerId != match.currentServerId;
}
