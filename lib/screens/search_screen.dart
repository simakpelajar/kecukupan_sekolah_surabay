import 'package:flutter/material.dart';
import '../models/school.dart';
import '../widgets/school_item.dart';
import '../theme/app_colors.dart';
import 'school_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final List<School> schools;

  SearchScreen({required this.schools});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  List<School> _filteredSchools = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredSchools = widget.schools;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSchools(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSchools = widget.schools;
      });
    } else {
      setState(() {
        _filteredSchools = widget.schools
            .where((school) =>
                school.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(
        title: Text(
          'Cari Sekolah', 
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.schoolIconColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppColors.schoolIconColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterSchools,
                autofocus: true,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  hintText: 'Cari sekolah...',
                  hintStyle: TextStyle(color: AppColors.textSecondaryColor),
                  prefixIcon: Icon(Icons.search, color: AppColors.schoolIconColor),
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredSchools.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.schoolIconColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search_off,
                            size: 48,
                            color: AppColors.schoolIconColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada sekolah yang ditemukan',
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
                    itemCount: _filteredSchools.length,
                    itemBuilder: (context, index) {
                      final school = _filteredSchools[index];                      return SchoolItem(
                        school: school,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SchoolDetailScreen(
                                school: school,
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
}