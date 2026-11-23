
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vehicle_model.dart';

class VehicleCard extends StatefulWidget {
  final Vehicle vehicle;
  final VoidCallback? onDelete;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onDelete,
  });

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );

    _pressAnim = _pressCtrl;
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final h = dt.hour > 12
        ? dt.hour - 12
        : (dt.hour == 0 ? 12 : dt.hour);

    final min = dt.minute.toString().padLeft(2, '0');
    final pm = dt.hour >= 12 ? 'PM' : 'AM';

    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$min $pm';
  }

  // ── Copy Action ────────────────────────────────────────

  Future<void> _copy() async {
    await Clipboard.setData(
      ClipboardData(text: widget.vehicle.vehicleNumber),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.greenAccent,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Copied: ${widget.vehicle.vehicleNumber}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A2A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Image Preview ──────────────────────────────────────

  void _showPreview(File file) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                file,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2535),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF2A3A4A),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete Confirmation ────────────────────────────────

  void _confirmDelete() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2A3A4A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.delete_forever_rounded,
              color: Colors.redAccent,
              size: 36,
            ),
            const SizedBox(height: 12),
            const Text(
              'Delete Record?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.vehicle.vehicleNumber,
              style: const TextStyle(
                color: Color(0xFF1E88E5),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(
                        color: Color(0xFF2A3A4A),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onDelete?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7F1D1D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Build Card ────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final imageFile = File(widget.vehicle.imagePath);
    final hasImage = imageFile.existsSync();

    final plate = widget.vehicle.vehicleNumber.isNotEmpty
        ? widget.vehicle.vehicleNumber
        : 'UNKNOWN';

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      child: ScaleTransition(
        scale: _pressAnim,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF1E2D3D),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x28000000),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ── Thumbnail ──────────────────────────────
                GestureDetector(
                  onTap: hasImage
                      ? () => _showPreview(imageFile)
                      : null,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF1E2D3D),
                            width: 1,
                          ),
                          color: const Color(0xFF0D1520),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: hasImage
                              ? Image.file(
                            imageFile,
                            fit: BoxFit.cover,
                          )
                              : const Icon(
                            Icons.directions_car_rounded,
                            color: Color(0xFF2A3A4A),
                            size: 34,
                          ),
                        ),
                      ),
                      if (hasImage)
                        Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xCC000000),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.zoom_in_rounded,
                            color: Colors.white70,
                            size: 13,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ── Info (Responsive) ──────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Number Plate
                      _PlateBadge(plateNumber: plate),

                      const SizedBox(height: 10),

                      // Date and Time
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Color(0xFF4A6080),
                          ),
                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              _formatDate(
                                widget.vehicle.scannedAt,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF4A6080),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // ── Action Buttons ─────────────────────────
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CircleAction(
                      icon: Icons.copy_rounded,
                      color: const Color(0xFF1E88E5),
                      bgColor: const Color(0xFF0D2040),
                      onTap: _copy,
                      tooltip: 'Copy',
                    ),
                    if (widget.onDelete != null) ...[
                      const SizedBox(height: 8),
                      _CircleAction(
                        icon: Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        bgColor: const Color(0xFF2A0D0D),
                        onTap: _confirmDelete,
                        tooltip: 'Delete',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Plate Badge (Responsive) ─────────────────────────────────

class _PlateBadge extends StatelessWidget {
  final String plateNumber;

  const _PlateBadge({
    required this.plateNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // IND Strip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF003399),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF003399),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'IND',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          // Plate number now gets only available width
          Expanded(
            child: Text(
              plateNumber,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1,
                color: Colors.black,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Circle Action Button ────────────────────────────────────

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  final String tooltip;

  const _CircleAction({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 17,
          ),
        ),
      ),
    );
  }
}
