import 'package:flutter/material.dart';

import 'game_logic.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSwitched = false;
  String activePlayer = 'X';
  bool gameOver = false;
  int turn = 0;
  String result = '';
  Game game = Game();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: MediaQuery.of(context).orientation == Orientation.portrait
              ? Column(
                  children: [
                    ...firstBloc(),
                    SizedBox(
                      height: 20.0,
                    ),
                    ...centerBloc(),
                    SizedBox(
                      height: 20.0,
                    ),
                    ...lastBlock(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ...firstBloc(),
                          ...lastBlock(),
                        ],
                      ),
                    ),
                    ...centerBloc(),
                  ],
                ),
        ),
      ),
    );
  }

  List<Widget> firstBloc() {
    return [
      SwitchListTile.adaptive(
        title: Text(
          'Turn on/off Two Player',
          style: TextStyle(
            fontSize: 25.0,
          ),
          textAlign: TextAlign.center,
        ),
        value: isSwitched,
        activeColor: Colors.green,
        onChanged: (newVal) {
          setState(
            () {
              isSwitched = !isSwitched;
            },
          );
        },
      ),
      Text(
        gameOver || turn == 9
            ? 'Play Again'.toUpperCase()
            : 'It\'s $activePlayer Turn'.toUpperCase(),
        style: TextStyle(
          fontSize: 52.0,
        ),
        textAlign: TextAlign.center,
      ),
    ];
  }

  List<Widget> centerBloc() {
    return [
      Expanded(
        child: GridView.count(
          physics: BouncingScrollPhysics(),
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? 0.7
                  : 1.4,
          crossAxisCount: 3,
          children: List.generate(
            9,
            (index) => InkWell(
              onTap: gameOver
                  ? null
                  : () {
                      _onTap(
                        index,
                      );
                    },
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Theme.of(context).shadowColor,
                ),
                child: Center(
                  child: Text(
                    Player.playerX.contains(index)
                        ? 'X'
                        : Player.playerO.contains(index)
                            ? 'O'
                            : '',
                    style: TextStyle(
                      fontSize: 42,
                      color: Player.playerX.contains(index)
                          ? Colors.blue
                          : Colors.pink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> lastBlock() {
    return [
      Text(
        result,
        style: TextStyle(
          fontSize: 42.0,
        ),
        textAlign: TextAlign.center,
      ),
      ElevatedButton.icon(
        onPressed: () {
          setState(
            () {
              activePlayer = 'X';
              gameOver = false;
              turn = 0;
              result = '';
              Player.playerX = [];
              Player.playerO = [];
            },
          );
        },
        icon: Icon(Icons.replay),
        label: Text(
          'Repeat This Game',
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Theme.of(context).splashColor,
          ),
        ),
      ),
    ];
  }

  void _onTap(int index) async {
    if ((Player.playerX.isEmpty || !Player.playerX.contains(index)) &&
        (Player.playerO.isEmpty || !Player.playerO.contains(index))) {
      game.playGame(
        index,
        activePlayer,
      );
      updateState();
      if (!isSwitched && !gameOver && turn != 9) {
        await game.autoPlay(activePlayer);
        updateState();
      }
    }
  }

  void updateState() {
    setState(
      () {
        activePlayer = (activePlayer == 'X') ? 'O' : 'X';
        turn++;
        String winnerPlayer = game.checkWinner();
        if (winnerPlayer != '') {
          gameOver = true;
          result = '$winnerPlayer is the winner';
        } else if (!gameOver && turn == 9) {
          result = 'It\'s Draw!';
        }
      },
    );
  }
}
