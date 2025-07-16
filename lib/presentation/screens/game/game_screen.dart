import 'package:flutter/material.dart';
import 'package:al_quran/core/constant/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilihan Game'),
        centerTitle: true,
        backgroundColor: AppColors.primaryCream,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryCream, AppColors.secondaryCream],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryCream, AppColors.secondaryCream],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxHeight < 600;
              
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12.w : 16.w, 
                  vertical: isSmallScreen ? 8.h : 16.h
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pilih Jenis Game',
                      style: TextStyle(
                        color: AppColors.darkBrown,
                        fontSize: isSmallScreen ? 20.sp : 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20.h : 40.h),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildGameCard(
                              context: context,
                              icon: Icons.quiz,
                              title: 'Kuis Al-Quran',
                              description: 'Uji pengetahuan Anda tentang Al-Quran dengan pertanyaan-pertanyaan menarik',
                              route: '/quiz',
                              color: AppColors.primaryBrown,
                              isSmallScreen: isSmallScreen,
                            ),
                            
                            SizedBox(height: isSmallScreen ? 20.h : 30.h),
                            
                            _buildGameCard(
                              context: context,
                              icon: Icons.grid_on,
                              title: 'Teka-Teki Silang',
                              description: 'Isi kotak kosong dengan jawaban yang tepat berdasarkan petunjuk tentang Al-Quran',
                              route: '/crossword',
                              color: AppColors.secondaryBrown,
                              isSmallScreen: isSmallScreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String route,
    required Color color,
    required bool isSmallScreen,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12.r : 15.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8.w : 16.w),
        child: InkWell(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12.r : 15.r),
          onTap: () => Navigator.pushNamed(context, route),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 12.w : 20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isSmallScreen ? 12.r : 15.r),
              color: AppColors.lightCream,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon, 
                  size: isSmallScreen ? 30.w : 40.w, 
                  color: color
                ),
                SizedBox(height: isSmallScreen ? 8.h : 15.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: isSmallScreen ? 16.sp : 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6.h : 10.h),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.darkBrown,
                    fontSize: isSmallScreen ? 12.sp : 14.sp,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8.h : 15.h),
                Icon(
                  Icons.arrow_forward, 
                  color: color,
                  size: isSmallScreen ? 16.w : 20.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}