import 'package:flutter/material.dart';

class StacksBottom extends StatelessWidget {
  const StacksBottom({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final screenWidth = MediaQuery.of(context).size.width;

    // Tính toán vị trí và kích thước dựa trên kích thước màn hình
    final containerSize = screenWidth * 0.2; // 12.5% chiều rộng màn hình
    final distanceBetweenContainers =
        screenWidth * 0.1; // 10% chiều rộng màn hình
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: containerSize + 10,
        ),
        Positioned(
          left: screenWidth * 0.32 - containerSize / 2,
          child: Container(
            width: containerSize,
            height: containerSize,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(82, 82, 199, 0.5),
                  Color.fromRGBO(82, 82, 199, 0.1),
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            transform: Matrix4.rotationZ(0.8),
          ),
        ),
        Positioned(
          left: screenWidth * 0.23 +
              distanceBetweenContainers +
              containerSize / 2,
          child: Container(
            width: containerSize,
            height: containerSize,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(82, 82, 199, 0.5),
                  Color.fromRGBO(82, 82, 199, 0.1),
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            transform: Matrix4.rotationZ(0.8),
          ),
        ),
        Positioned(
          left: screenWidth * 0.74 - containerSize / 2,
          child: Container(
            width: containerSize,
            height: containerSize,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(82, 82, 199, 0.5),
                  Color.fromRGBO(82, 82, 199, 0.1),
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            transform: Matrix4.rotationZ(0.8),
          ),
        ),
      ],
    );
  }
}
