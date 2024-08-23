import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: KalkulatorPage(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
      debugShowCheckedModeBanner: false, // Tidak menampilkan watermark debug
    );
  }
}

class KalkulatorPage extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const KalkulatorPage({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  State<KalkulatorPage> createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> with SingleTickerProviderStateMixin {
  String _output = '';
  String _currentNumber = '';
  String _operation = '';
  double _num1 = 0;
  double _num2 = 0;
  String _history = '';

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _colorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: Colors.red,
            end: Colors.blue,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: Colors.blue,
            end: Colors.green,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: Colors.green,
            end: Colors.yellow,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: Colors.yellow,
            end: Colors.purple,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: Colors.purple,
            end: Colors.red,
          ),
        ),
      ],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

void _buttonPressed(String buttonText) {
  setState(() {
    if (buttonText == 'C') {
      _output = '';
      _currentNumber = '';
      _operation = '';
      _num1 = 0;
      _num2 = 0;
      _history = '';
    } else if (buttonText == 'DEL') {
      if (_currentNumber.isNotEmpty) {
        _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
        _output = _currentNumber.isEmpty ? '' : _currentNumber;
      }
    } else if (buttonText == '+' || buttonText == '-' || buttonText == 'x' || buttonText == '/') {
      if (_currentNumber.isNotEmpty) {
        _num1 = double.parse(_currentNumber);
        _operation = buttonText;
        _history += '$_num1 $_operation ';
        _currentNumber = '';
      }
    } else if (buttonText == '=') {
      if (_currentNumber.isNotEmpty && _operation.isNotEmpty) {
        _num2 = double.parse(_currentNumber);
        _history += '$_num2 = ';
        double result;
        switch (_operation) {
          case '+':
            result = _num1 + _num2;
            break;
          case '-':
            result = _num1 - _num2;
            break;
          case 'x':
            result = _num1 * _num2;
            break;
          case '/':
            if (_num2 != 0) {
              result = _num1 / _num2;
            } else {
              _output = 'Error';
              result = double.nan;
            }
            break;
          default:
            result = 0;
        }
        if (!_output.contains('Error')) {
          _output = result == result.roundToDouble() ? result.toInt().toString() : result.toString();
        }
        _history += '$_output\n';
        _currentNumber = _output;
        _operation = '';
      }
    } else if (buttonText == 'HISTORY') {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('History'),
            content: Text(_history),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      if (_currentNumber == '0') {
        _currentNumber = '';
      }
      _currentNumber += buttonText;
      _output = _currentNumber;
    }
  });
}


  Widget _buildButton(String buttonText, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => _buttonPressed(buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              buttonText,
              style: TextStyle(fontSize: 20.0, color: widget.isDarkMode ? Colors.black : Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Kalkulator'),
            actions: [
              IconButton(
                icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => widget.toggleTheme(),
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => _buttonPressed('HISTORY'),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _colorAnimation.value!,
                  _colorAnimation.value!.withOpacity(0.5),
                ],
              ),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _history,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
                  child: Text(
                    _output,
                    style: const TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Container(
                  color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                        _buildButton('7', color: Colors.red),
                        _buildButton('8', color: Colors.orange),
                        _buildButton('9', color: const Color.fromARGB(255, 59, 196, 255)),
                        _buildButton('/', color: Colors.amber[700]),
                      ],
                      ),
                      Row(
                        children: [
                          _buildButton('4', color: Colors.green),
                          _buildButton('5', color: Colors.blue),
                          _buildButton('6', color: Colors.indigo),
                          _buildButton('x', color: Colors.amber[700]),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton('1', color: Colors.amber[400]),
                          _buildButton('2', color: Colors.pink),
                          _buildButton('3', color: Colors.teal),
                          _buildButton('-', color: Colors.amber[700]),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton('C', color: Colors.grey),
                          _buildButton('0', color: Colors.cyan),
                          _buildButton('DEL', color: Colors.grey),
                          _buildButton('+', color: Colors.amber[700]),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton('=', color: Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
