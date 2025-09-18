import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _apagarUltimo() {
    setState(() {
      if (_display.isNotEmpty && _display != '0' && _display != 'Erro') {
        _display = _display.substring(0, _display.length - 1);
        if (_display.isEmpty) _display = '0';
      }
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

  void _abrirHistorico() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistoricoScreen(historico: _historico)),
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
            icon: Icon(Icons.history),
            onPressed: _abrirHistorico,
            tooltip: 'Ver histórico',
          ),
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
              CalculatorDisplay(display: _display, historico: _historico),
              Spacer(),
              CalculatorKeyboard(
                onAdicionar: _adicionarValor,
                onLimpar: _limpar,
                onApagar: _apagarUltimo,
                onCalcular: _calcular,
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class CalculatorDisplay extends StatelessWidget {
  final String display;
  final List<String> historico;

  const CalculatorDisplay({
    super.key,
    required this.display,
    required this.historico,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (historico.isNotEmpty)
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  historico
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
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            display,
            style: TextStyle(fontSize: 48, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class CalculatorKeyboard extends StatelessWidget {
  final void Function(String) onAdicionar;
  final VoidCallback onLimpar;
  final VoidCallback onApagar;
  final VoidCallback onCalcular;

  const CalculatorKeyboard({
    super.key,
    required this.onAdicionar,
    required this.onLimpar,
    required this.onApagar,
    required this.onCalcular,
  });

  Widget _buildBotao(
    BuildContext context,
    String texto, {
    Color? cor,
    VoidCallback? onPressed,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          if (onPressed != null) {
            onPressed();
          } else {
            onAdicionar(texto);
          }
        },
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
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        _buildBotao(context, 'C', cor: Colors.red, onPressed: onLimpar),
        _buildBotao(context, '⌫', cor: Colors.orange, onPressed: onApagar),
        _buildBotao(context, '7'),
        _buildBotao(context, '8'),
        _buildBotao(context, '9'),
        _buildBotao(context, '÷'),
        _buildBotao(context, '4'),
        _buildBotao(context, '5'),
        _buildBotao(context, '6'),
        _buildBotao(context, '×'),
        _buildBotao(context, '1'),
        _buildBotao(context, '2'),
        _buildBotao(context, '3'),
        _buildBotao(context, '-'),
        _buildBotao(context, '0'),
        _buildBotao(context, '.'),
        _buildBotao(context, '=', cor: Colors.green, onPressed: onCalcular),
        _buildBotao(context, '+'),
      ],
    );
  }
}

class HistoricoScreen extends StatelessWidget {
  final List<String> historico;

  const HistoricoScreen({super.key, required this.historico});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Histórico')),
      body: ListView.builder(
        itemCount: historico.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(historico[index]));
        },
      ),
    );
  }
}
