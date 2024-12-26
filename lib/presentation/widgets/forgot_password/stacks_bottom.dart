import 'package:socialapp/utils/import.dart';

class StacksBottom extends StatelessWidget {
  final double stackWidth = 500;
  final double containerSize = 450 * 0.2;
  final double distanceBetweenContainers = 450 * 0.025;

  const StacksBottom({super.key});

  double calculateHorizontalDisplacement(
      double containerWidth, double rotationAngle) {
    double displacement = (containerWidth / 2) * (1 - cos(rotationAngle));
    return displacement;
  }

  @override
  Widget build(BuildContext context) {
    final leftRotatedWidth =
        calculateHorizontalDisplacement(containerSize, 0.8);
    final totalContainersWidth =
        containerSize * 3 - distanceBetweenContainers * 2;

    // Offset to center the containers horizontally
    final horizontalOffset = (stackWidth - totalContainersWidth) / 2 + leftRotatedWidth;

    return SizedBox(
      width: stackWidth,
      height: containerSize,
      child: Stack(
        children: [
          Positioned(
            left: horizontalOffset,
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
            left: (containerSize - distanceBetweenContainers)  + horizontalOffset,
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
            left: (containerSize - distanceBetweenContainers) * 2 + horizontalOffset,
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
      ),
    );
  }
}
