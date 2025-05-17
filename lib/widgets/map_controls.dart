import 'package:flutter/material.dart';

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
              SizedBox(height: 8),
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
            right: 16,
            child: Container(
              width: 200,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
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
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildFilterSwitch(
                    label: 'Tampilkan Sekolah',
                    value: showSchools,
                    onChanged: onShowSchoolsChanged,
                  ),
                  SizedBox(height: 8),
                  _buildFilterSwitch(
                    label: 'Tampilkan Kecamatan',
                    value: showDistricts,
                    onChanged: onShowDistrictsChanged,
                  ),
                  SizedBox(height: 8),
                  _buildFilterSwitch(
                    label: 'Tampilkan Legenda',
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
        color: Color(0xFF1E293B).withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFF334155)),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
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
        Text(label),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFF06B6D4),
        ),
      ],
    );
  }
}