import 'package:flutter/material.dart';
import 'package:kecukupan_sekolah_surabaya/theme/app_colors.dart';

class MapControls extends StatelessWidget {
  final bool showFilterPanel;
  final VoidCallback onFilterToggle;
  final VoidCallback onSearchTap;
  final bool showSchools;
  final bool showDistricts;
  final bool showLegend;
  final ValueChanged<bool> onShowSchoolsChanged;
  final ValueChanged<bool> onShowDistrictsChanged;
  final ValueChanged<bool> onShowLegendChanged;

  const MapControls({
    Key? key,
    required this.showFilterPanel,
    required this.onFilterToggle,
    required this.onSearchTap,
    required this.showSchools,
    required this.showDistricts,
    this.showLegend = true,
    required this.onShowSchoolsChanged,
    required this.onShowDistrictsChanged,
    required this.onShowLegendChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map Controls
        Positioned(
          top: 40,
          right: 16,
          child: Column(
            children: [
              _buildMapControlButton(
                icon: Icons.info,
                onPressed: onFilterToggle,
              ),
              SizedBox(height: 16),
              _buildMapControlButton(
                icon: Icons.search,
                onPressed: onSearchTap,
              ),
            ],
          ),
        ),

        // Filter Panel
        if (showFilterPanel)
          Positioned(
            top: 100,
            right: 8,
            child: Container(
              width: 180,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Tampilan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildFilterSwitch(
                    label: 'Sekolah',
                    value: showSchools,
                    onChanged: onShowSchoolsChanged,
                  ),
                  SizedBox(height: 8),
                  _buildFilterSwitch(
                    label: 'Kecamatan',
                    value: showDistricts,
                    onChanged: onShowDistrictsChanged,
                  ),
                  SizedBox(height: 8),
                  _buildFilterSwitch(
                    label: 'Legenda',
                    value: showLegend,
                    onChanged: onShowLegendChanged,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color.fromARGB(255, 91, 91, 91)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFilterSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textColor)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFF06B6D4),
        ),
      ],
    );
  }
}
