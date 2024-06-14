import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'database_helper.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Map<String, dynamic>>> _ratingsFuture;

  @override
  void initState() {
    super.initState();
    _ratingsFuture = _fetchRatings();
  }

  Future<List<Map<String, dynamic>>> _fetchRatings() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> ratings = await db!.rawQuery(
      'SELECT r.rating, r.fecha, r.descrip, u.email FROM rating r JOIN users u ON r.id_user = u.id'
    );
    return ratings;
  }

  double _calculateAverageRating(List<Map<String, dynamic>> ratings) {
    if (ratings.isEmpty) return 0.0;
    double sum = 0.0;
    for (var rating in ratings) {
      sum += rating['rating'];
    }
    return sum / ratings.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Administrador'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ratingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final ratings = snapshot.data!;
            final ratingData = _getChartData(ratings);
            final trendData = _getTrendData(ratings);
            final averageRating = _calculateAverageRating(ratings);
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Distribución de Calificaciones',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 300,
                    child: charts.BarChart(
                      [
                        charts.Series<Map<String, dynamic>, String>(
                          id: 'Ratings',
                          domainFn: (Map<String, dynamic> rating, _) =>
                              rating['rating'].toString(),
                          measureFn: (Map<String, dynamic> rating, _) =>
                              rating['count'],
                          data: ratingData,
                          labelAccessorFn: (Map<String, dynamic> rating, _) =>
                              '${rating['count']}',
                          colorFn: (_, __) =>
                              charts.ColorUtil.fromDartColor(Color(0xFFD48600)),
                        )
                      ],
                      animate: true,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120, // Ajusta el ancho según sea necesario
                        child: Card(
                          color: Colors.white,
                          margin: EdgeInsets.all(16),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  averageRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'Average Rating',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 180, // Ajusta el ancho según sea necesario
                        child: Card(
                          color: Colors.white,
                          margin: EdgeInsets.all(16),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                RatingBarIndicator(
                                  rating: averageRating,
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 30, // Ajusta el tamaño de las estrellas según sea necesario
                                  direction: Axis.horizontal,
                                ),
                                Text(
                                  'Average Rating',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Card(
                    color: Color(0xFFB7D8E6),
                    margin: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Rating')),
                            DataColumn(label: Text('Fecha')),
                          ],
                          rows: ratings.map((rating) {
                            return DataRow(
                              cells: [
                                DataCell(Container(width: 100, child: Text(rating['email']))),
                                DataCell(Text(rating['rating'].toString())),
                                DataCell(Container(width: 150, child: Text(rating['fecha']))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    color: Color(0xFFB7D8E6),
                    margin: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Comentario')),
                          ],
                          rows: ratings.map((rating) {
                            return DataRow(
                              cells: [
                                DataCell(Container(width: 100, child: Text(rating['email']))),
                                DataCell(Container(width: 200, child: Text(rating['descrip'] ?? ''))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tendencia de Calificaciones',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 300,
                    child: charts.TimeSeriesChart(
                      [
                        charts.Series<Map<String, dynamic>, DateTime>(
                          id: 'Trend',
                          domainFn: (Map<String, dynamic> rating, _) =>
                              DateTime.parse(rating['fecha']),
                          measureFn: (Map<String, dynamic> rating, _) =>
                              rating['average'],
                          data: trendData,
                          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                        )
                      ],
                      animate: true,
                      dateTimeFactory: const charts.LocalDateTimeFactory(),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getChartData(List<Map<String, dynamic>> ratings) {
    final Map<int, int> ratingCounts = {};
    for (var rating in ratings) {
      ratingCounts[rating['rating']] = (ratingCounts[rating['rating']] ?? 0) + 1;
    }
    return ratingCounts.entries
        .map((entry) => {'rating': entry.key, 'count': entry.value})
        .toList();
  }

  List<Map<String, dynamic>> _getTrendData(List<Map<String, dynamic>> ratings) {
    final Map<DateTime, List<int>> dateRatings = {};
    for (var rating in ratings) {
      final date = DateTime.parse(rating['fecha']).toLocal();
      final dateOnly = DateTime(date.year, date.month, date.day);
      if (!dateRatings.containsKey(dateOnly)) {
        dateRatings[dateOnly] = [];
      }
      dateRatings[dateOnly]!.add(rating['rating']);
    }

    final List<Map<String, dynamic>> trendData = [];
    dateRatings.forEach((date, ratings) {
      final average = ratings.reduce((a, b) => a + b) / ratings.length;
      trendData.add({'fecha': date.toIso8601String(), 'average': average});
    });

    return trendData;
  }
}
