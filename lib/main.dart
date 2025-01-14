import 'package:flutter/material.dart';

void main() {
  runApp(const SubwayMapApp());
}

class SubwayMapApp extends StatelessWidget {
  const SubwayMapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SubwayMapScreen(),
    );
  }
}

class SubwayMapScreen extends StatefulWidget {
  @override
  State<SubwayMapScreen> createState() => _SubwayMapScreenState();
}

class _SubwayMapScreenState extends State<SubwayMapScreen> {
  final List<Map<String, dynamic>> stations = [
    {'name': '서울역', 'x': 100.0, 'y': 150.0},
    {'name': '강남역', 'x': 200.0, 'y': 300.0},
  ];

  final TransformationController _transformationController =
  TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('지하철 노선도')),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 3.0,
            child: Image.asset(
              'assets/subway_map.svg',
              fit: BoxFit.contain,
            ),
          ),
          ...stations.map((station) {
            return AnimatedBuilder(
              animation: _transformationController,
              builder: (context, child) {
                // 현재 변환 매트릭스를 가져옵니다.
                final Matrix4 matrix = _transformationController.value;
                // 위치 변환 계산
                final Offset transformedPosition = MatrixUtils.transformPoint(
                  matrix,
                  Offset(station['x'], station['y']),
                );

                return Positioned(
                  left: transformedPosition.dx,
                  top: transformedPosition.dy,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(station['name']),
                            content: const Text('역 정보를 여기에 표시하세요!'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('닫기'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 24.0,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
