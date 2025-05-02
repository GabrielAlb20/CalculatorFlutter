import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Calculadora(toggleTheme: toggleTheme),
    );
  }
}

class Calculadora extends StatefulWidget {
  final VoidCallback toggleTheme;

  const Calculadora({required this.toggleTheme});

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  String _display = '0';
  List<String> _historico = [];

  void _adicionarValor(String valor) {
    setState(() {
      if (_display == '0' || _display == 'Erro') {
        _display = valor;
      } else {
        _display += valor;
      }
    });
  }

  void _limpar() {
    setState(() {
      _display = '0';
    });
  }

  void _calcular() {
    try {
      String expressao = _display.replaceAll('×', '*').replaceAll('÷', '/');
      Parser parser = Parser();
      Expression exp = parser.parse(expressao);
      ContextModel cm = ContextModel();
      double resultado = exp.evaluate(EvaluationType.REAL, cm);

      String resultadoStr =
          resultado.toString().endsWith('.0')
              ? resultado.toStringAsFixed(0)
              : resultado.toString();

      setState(() {
        _historico.insert(0, "$_display = $resultadoStr");
        _display = resultadoStr;
      });
    } catch (e) {
      setState(() {
        _display = 'Erro';
      });
    }
  }

  Widget _buildBotao(String texto, {Color? cor, VoidCallback? onPressed}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: onPressed ?? () => _adicionarValor(texto),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              cor ?? (isDark ? Colors.blueGrey.shade800 : Colors.grey.shade200),
          foregroundColor: isDark ? Colors.white : Colors.black,
          minimumSize: Size(70, 70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
        ),
        child: Text(
          texto,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Calculadora'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
            tooltip: 'Alternar tema',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900.withAlpha((0.8 * 255).round()),
              Colors.black,
              Colors.blueAccent.withAlpha((0.5 * 255).round()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Histórico
              if (_historico.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:
                        _historico
                            .take(3)
                            .map(
                              (item) => Text(
                                item,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),

              // Display
              Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  _display,
                  style: TextStyle(fontSize: 48, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Spacer(),

              // Botões
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: [
                  _buildBotao('C', cor: Colors.red, onPressed: _limpar),
                  _buildBotao('7'),
                  _buildBotao('8'),
                  _buildBotao('9'),
                  _buildBotao('/'),
                  _buildBotao('4'),
                  _buildBotao('5'),
                  _buildBotao('6'),
                  _buildBotao('*'),
                  _buildBotao('1'),
                  _buildBotao('2'),
                  _buildBotao('3'),
                  _buildBotao('-'),
                  _buildBotao('0'),
                  _buildBotao('.'),
                  _buildBotao('=', cor: Colors.green, onPressed: _calcular),
                  _buildBotao('+'),
                ],
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
