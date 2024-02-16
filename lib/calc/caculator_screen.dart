import 'package:calc/base/extensions.dart';
import 'package:flutter/material.dart';

import 'calc_model.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final int maxLength = 5; // 글자 길이 최대 사이즈
  final double boxSize = 75; // 키패트 원 사이즈
  final double _fontSize = 60; // 값 폰트 사이즈
  final double circleRadius = 45;

  // 키패트 값
  final List<List<dynamic>> _list = [
    ['C', '+/-', '%', '/'],
    ['7', '8', '9', 'x'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '00', '.', '='],
  ];

  String total = ''; // 계산기 보여줄 텍스트
  String padText = '';
  String syntax = ''; // 연산 부호
  int syntaxIndex = 0;
  double num = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 숫자 표시
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      padText.isEmpty ? '0' : padText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      // value 값이 없는 경우 0으로 표시, 있는 경우 value 값 표시
                      total,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: total.length > maxLength ? (_fontSize - total.length).toDouble() : _fontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 키패트
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ..._list.map(
                    (x) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...x.map(
                          (y) => DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(circleRadius),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(circleRadius),
                              onTap: () => pressedPad(y),
                              child: SizedBox(
                                width: boxSize,
                                height: boxSize,
                                child: Center(
                                  child: Text(
                                    '$y',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 계산 메소드
  // x 의 값은 키패드 입력한 값
  Future<void> pressedPad(String x) async {
    String text = padText.isNotEmpty ? padText : '';
    int index = 0;
    String currentTotal = '';

    // 부호나 숫자인 경우
    if (isSyntax(x) || isNum(x)) {
      text += x;
      index = isSyntax(x) ? padText.length : 0; // 연산자인 경우 문자열의 길이를 넣어줌(연산자의 마지막 값이라서)
    }

    // 계산기 화면의 값 수정
    setState(() {
      // 초기화
      if (x == 'C') {
        clear();
      } else {
        if(isSyntax(x)) {
          syntax = x;
        }
        padText = text; // 문자 추가
        syntaxIndex = index.isPositive ? index : syntaxIndex; // 부호 갱신
        total = syntaxIndex.isPositive ? getTotal(x) : '';
      }
    });
  }

  // 0 문자 더하기
  String addZero(String x) {
    if (total.isNotEmpty) {
      return total + x;
    } else {
      return '';
    }
  }

  // 숫자 더하기
  void addNum(String x) {}

  // 숫자 여부 판단
  bool isNum(String x) {
    RegExp regExp = RegExp(r'^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$'); // 숫자형 정규식
    if (regExp.hasMatch(x)) {
      return true;
    } else {
      return false;
    }
  }

  // 부호 여부 판단
  bool isSyntax(String x) {
    if (x == '+' || x == '-' || x == 'x' || x == '/') {
      return true;
    } else {
      return false;
    }
  }

  // 양/음수 변환
  String positiveConversion() {
    // 숫자 인지 판단
    if (isNum(total)) {
      double num = double.parse(total);
      num = num * -1; // 숫자면 숫자 (-1)을 곱하여 양음수 전환
      return num.toString();
    } else {
      return '';
    }
  }

  // 소수점 추가
  String addPoint(String x) => '$x.';

  // 클리어
  void clear() {
    setState(() {
      total = '';
      padText = '';
      syntax = '';
      num = 0;
      syntaxIndex = 0;
    });
  }

  // num 가져오기
  String getNum() => syntaxIndex.isPositive ? padText.substring(syntaxIndex+1) : '0';

  // 계산 결과 가져오기
  String getTotal(String x) {
    if(x == '=') {
      return total;
    } else {
      double result = 0;
      String numText = getNum();
      double num = numText.isNotEmpty ? double.parse(numText) : 0;
      double value = total.isNotEmpty ? double.parse(total) : double.parse(padText.substring(0, syntaxIndex));

      switch(syntax) {
        case '+':
          result = value + num;
          break;
        case '-':
          result = value - num;
          break;
        case 'x':
          result = num.isPositive ? value * num : value * 1;
          break;
        case '/':
          result = num.isPositive ? value / num : value / 1;
          break;
      }
      return result % 1 > 0 ? result.toString() : result.toStringAsFixed(0);
    }
  }
}
