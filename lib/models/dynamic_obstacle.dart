enum ObstacleType { staticWall, laserGate, movingDrone, slidingBarrier }

class DynamicObstacle {
  final ObstacleType type;
  int lane; // 0: Left, 1: Center, 2: Right
  double positionZ;
  bool isActive;
  int moveDirection; // 1 for right, -1 for left

  DynamicObstacle({
    required this.type,
    required this.lane,
    required this.positionZ,
    this.isActive = true,
    this.moveDirection = 1,
  });

  void update(double speed, double dt) {
    positionZ -= speed * dt;

    // حركة طائرات الدرون بين الحارات أفقياً
    if (type == ObstacleType.movingDrone) {
      if (lane == 0) moveDirection = 1;
      if (lane == 2) moveDirection = -1;
      
      // تغيير الحارة بشكل دوري
      if (positionZ % 50 < 1) {
        lane += moveDirection;
      }
    }
  }
}
