import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'gradient_button.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RatingScreen extends StatefulWidget {
  final int userId;

  RatingScreen({required this.userId});

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen>
    with SingleTickerProviderStateMixin {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  late AnimationController controladorAnimacion;

  @override
  void initState() {
    super.initState();
    controladorAnimacion = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    controladorAnimacion.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    try {
      String fecha = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      await DatabaseHelper().insertRating(
        _rating.toInt(),
        fecha,
        _commentController.text,
        widget.userId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calificación registrada correctamente')),
      );
      _commentController.clear();
      setState(() {
        _rating = 0.0;
      });
    } catch (e) {
      print('Error registering rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registrando calificación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alturaPantalla = MediaQuery.of(context).size.height;
    final anchuraPantalla = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: Color(0xFF40329F), // Colors.indigo[900]
        child: Stack(
          children: [
            CapaOla(
              animacion: controladorAnimacion,
              proporcionAltura: 0.1,
              velocidad: 1.0,
              desfase: pi,
              color: Color(0xFF19294B).withOpacity(0.7), // Colors.amber[100]
              inicioY: alturaPantalla * 0.3,
            ),
            CapaOla(
              animacion: controladorAnimacion,
              proporcionAltura: 0.15,
              velocidad: 1.1,
              desfase: pi / 2,
              color:
                  Color(0xFF12295B).withOpacity(0.7), // Colors.deepPurple[800]
              inicioY: alturaPantalla * 0.1,
            ),
            CapaOla(
              animacion: controladorAnimacion,
              proporcionAltura: 0.1,
              velocidad: 1.0,
              desfase: pi / 3,
              color: Color(0xFF241C45).withOpacity(0.7), // Colors.amber[300]
              inicioY: alturaPantalla * 0.6,
            ),
            CapaOla(
              animacion: controladorAnimacion,
              proporcionAltura: 0.1,
              velocidad: 1.3,
              desfase: pi / 3,
              color:
                  Color(0xFFD79323).withOpacity(0.7), // Colors.lightBlue[300]
              inicioY: alturaPantalla * 0.8,
            ),
            Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                width: anchuraPantalla * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                    SizedBox(height: 20),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Dejanos algún comentario:',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Comentario',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GradientButton(
                      onPressed: _submitRating,
                      splashColor: Colors.orange,
                      colors: [
                        Colors.red,
                        Colors.orange,
                      ],
                      title: 'Confirmar',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CapaOla extends StatelessWidget {
  final Animation<double> animacion;
  final double proporcionAltura;
  final double velocidad;
  final double desfase;
  final Color color;
  final double inicioY;

  const CapaOla({
    Key? key,
    required this.animacion,
    required this.proporcionAltura,
    required this.velocidad,
    required this.desfase,
    required this.color,
    required this.inicioY,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animacion,
      builder: (context, child) {
        return CustomPaint(
          painter: PintorOla(
            valorAnimacion: animacion.value,
            proporcionAltura: proporcionAltura,
            velocidad: velocidad,
            desfase: desfase,
            color: color,
            inicioY: inicioY,
          ),
          size: Size(double.infinity, double.infinity),
        );
      },
    );
  }
}

class PintorOla extends CustomPainter {
  final double valorAnimacion;
  final double proporcionAltura;
  final double velocidad;
  final double desfase;
  final Color color;
  final double inicioY;

  PintorOla({
    required this.valorAnimacion,
    required this.proporcionAltura,
    required this.velocidad,
    required this.desfase,
    required this.color,
    required this.inicioY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    final alturaOla = size.height * proporcionAltura;
    final frecuenciaOla = 2 * pi / size.width;
    final desplazamientoTotalOla =
        2 * pi * valorAnimacion * velocidad + desfase;

    path.moveTo(0, inicioY);
    for (double x = 0; x <= size.width; x++) {
      final y =
          inicioY + alturaOla * sin(frecuenciaOla * x + desplazamientoTotalOla);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
