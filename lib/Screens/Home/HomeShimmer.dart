import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildShimmerTopSection(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30.0,
                      right: 30,
                      bottom: 20,
                      top: 40,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 30, 123, 179),
                              ),
                            ),
                            _buildShimmerTopSection(),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 30, 123, 179),
                              ),
                            ),
                            _buildShimmerTopSection(),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Emergency help Needed?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildShimmerEmergencyButton(),
                        const SizedBox(height: 30),
                        _buildShimmerText(width: 200),
                        const SizedBox(height: 20),
                        _buildShimmerGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerTopSection() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 20,
        width: 100,
        color: Colors.white,
      ),
    );
  }

  Widget _buildShimmerText({double width = 250}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 20,
        width: width,
        color: Colors.white,
      ),
    );
  }

  Widget _buildShimmerEmergencyButton() {
    return Shimmer.fromColors(
      baseColor: Colors.red.withOpacity(0.5),
      highlightColor: Colors.red.withOpacity(0.2),
      child: Container(
        height: 120,
        width: 120,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: Image.asset(
          'assets/img/wifi.png',
          height: 60,
          width: 60,
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }
}
