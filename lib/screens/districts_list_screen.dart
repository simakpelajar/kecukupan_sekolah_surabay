import 'package:flutter/material.dart';
import '../models/district.dart';
import '../models/school.dart';
import '../widgets/district_item.dart';
import '../theme/app_colors.dart';
import 'district_detail_screen.dart';

class DistrictsListScreen extends StatefulWidget {
  final List<District> districts;
  final List<School> schools;

  const DistrictsListScreen({
    Key? key,
    required this.districts,
    required this.schools,
  }) : super(key: key);

  @override
  _DistrictsListScreenState createState() => _DistrictsListScreenState();
}

class _DistrictsListScreenState extends State<DistrictsListScreen> {
  late List<District> _filteredDistricts;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredDistricts = List.from(widget.districts);
  }

  void _filterDistricts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredDistricts = List.from(widget.districts);
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredDistricts = widget.districts.where((district) {
        return district.name.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
        title: Text(
          'Daftar Kecamatan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Column(
        children: [          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterDistricts,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  hintText: 'Cari kecamatan...',
                  hintStyle: TextStyle(color: AppColors.textSecondaryColor),
                  icon: Icon(Icons.search, color: AppColors.primaryColor),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Districts List
          Expanded(
            child: _filteredDistricts.isEmpty
                ? Center(                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search_off,
                            color: AppColors.primaryColor,
                            size: 48,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada kecamatan yang ditemukan',
                          style: TextStyle(
                            color: AppColors.textSecondaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredDistricts.length,
                    itemBuilder: (context, index) {
                      final district = _filteredDistricts[index];
                      return DistrictItem(
                        district: district,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DistrictDetailScreen(
                                district: district,
                                schools: widget.schools,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
