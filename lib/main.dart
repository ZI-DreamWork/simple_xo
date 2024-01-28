import 'package:flutter/material.dart';

class BoxValue {
  String player;
  String number;
  BoxValue({
    required this.player,
    required this.number,
  });
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GScreen(),
    );
  }
}

class GScreen extends StatefulWidget {
  const GScreen({super.key});

  @override
  State<GScreen> createState() => _GScreenState();
}

class _GScreenState extends State<GScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isXPlayer = false;
  bool isOPlayer = true;

  List<BoxValue> boxValues =
      List.generate(9, (index) => BoxValue(player: '', number: '$index'));
  List<bool> boxDisabled = List.generate(9, (index) => false);

  // PLayer win
  // 0 1 2
  // 3 4 5
  // 6 7 8
  // boxValues[0].player == boxValues[1].player == boxValues[2].player
  // boxValues[3].player == boxValues[4].player == boxValues[5].player
  // boxValues[6].player == boxValues[7].player == boxValues[8].player
  // boxValues[0].player == boxValues[3].player == boxValues[6].player
  // boxValues[1].player == boxValues[4].player == boxValues[7].player
  // boxValues[0].player == boxValues[4].player == boxValues[9].player
  // boxValues[2].player == boxValues[5].player == boxValues[8].player

  void checkForWin(BuildContext context) {
    final List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    // Iterate through winning combinations
    for (final List<int> combination in winningCombinations) {
      final String player = boxValues[combination[0]].player;
      if (player.isNotEmpty &&
          player == boxValues[combination[1]].player &&
          player == boxValues[combination[2]].player) {
        showCustomDialog(context);
        return;
      }
    }
  }

  void resetXO() {
    setState(() {
      for (var box in boxValues) {
        box.player = '';
      }
      boxDisabled = List.generate(9, (index) => false);
    });
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Winner'),
          content: Text(
            isOPlayer ? 'Player X' : 'Player O',
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog
                resetXO();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void play(BoxValue boxvalue) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildPlayerText(),
              const SizedBox(
                height: 2,
              ),
              buildGameGrid(),
              const SizedBox(
                height: 20,
              ),
              buildRestartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlayerText() {
    return Text(
      isOPlayer ? 'Player O' : 'Player X',
      style: const TextStyle(fontSize: 30, letterSpacing: 2),
    );
  }

  Widget buildGameGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 430,
      decoration: BoxDecoration(
        // color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        children: List.generate(
          9,
          (index) => customBox(
            boxValue: boxValues[index],
            func: () {
              if (!boxDisabled[index]) {
                setState(() {
                  boxValues[index].player = isOPlayer ? 'O' : 'X';
                  isOPlayer = !isOPlayer;
                  boxDisabled[index] = true; // Disable the InkWell
                  checkForWin(context);
                });
              }
            },
            // disabled: boxDisabled[index],
          ),
        ),
      ),
    );
  }

  Widget buildRestartButton() {
    return GestureDetector(
      onTap: resetXO,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(10)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restart_alt,
              color: Colors.grey,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Restart',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget customBox({required BoxValue boxValue, required Function() func}) {
    return InkWell(
      onTap: func,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 5,
                  spreadRadius: 2,
                  offset: const Offset(-3, -3)),
            ]),
        child: Center(
          child: Text(
            boxValue.player,
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w300),
          ),
        ),
      ),
    );
  }
}
