import 'package:flutter/material.dart';
import 'db/data_initializer.dart';
import 'db/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 데이터 초기화
  //await DataInitializer.initializeData();

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
    {'name': '서울역', 'x': 589.5, 'y': 464.0},
    {'name': '강남역', 'x': 670.0, 'y': 570.0},
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
            maxScale: 8.0,
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
                      // 역 클릭 시 CongestionScreen으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CongestionScreen(stationName: station['name']),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.circle_rounded,
                      color: Colors.pinkAccent,
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

class CongestionScreen extends StatelessWidget {
  final String stationName;

  CongestionScreen({required this.stationName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$stationName 혼잡도')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getCongestionData(stationName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('혼잡도 데이터가 없습니다.'));
          }

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final row = data[index];
              return ListTile(
                title: Text('${row['time']}'),
                subtitle: Text('혼잡도: ${row['congestion']}'),
              );
            },
          );
        },
      ),
    );
  }
}

