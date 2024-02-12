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
  late double num1, num2 = 0;

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
    double prev = 0;
    String prevSyntax = '';
    // 덧셈, 뺄셈, 곱셈, 나눗셈 여부 판단
    // True 면 이전 값 저장 (num1 에)
    if (isSyntax(x)) {
      prev = double.parse(padText);
      prevSyntax = x;
      text = text + (padText.isNotEmpty ? x : '');
    } else {
      switch (x) {
        case 'C': // 초기화
          clear();
          break;
        case '+/-': // 양음수 변환
          break;
        case '%': // 퍼센트
          break;
        case '00': // 0 두개 붙이기
          // text 의 값이 없으면 패스
          text = text + (padText.isNotEmpty ? x : '');
          break;
        case '.': // 소수점 찍기
          break;
        case '=': // 계산 완료
          break;
        case '0':
          // text 의 값이 없으면 패스
          text = text + (padText.isNotEmpty ? x : '');
          break;
        default:
          text = text + x;
          break;
      }
    }

    // 계산기 화면의 값 수정
    setState(() {
      if (x != 'C') {
        padText = text;
        num1 = prev;
        syntax = prevSyntax;
      }
      if (syntax.isNotEmpty) {
        total = num1 % 1 > 0 ? num1.toString() : num1.toStringAsFixed(0);
      }
    });
  }

  // 숫자 문자열 추가
  String addString(String x) {
    String result = '';

    // 숫자 여부 확인
    if (!isNum(x)) {
      if (total.isEmpty) {
        // value 값이 0인 경우 입력된 x만 추가
        result = x;
      } else {
        // value 값이 0이 아닌 경우 기존 value 에 x 추가
        result = total + x;
      }
    }
    return result;
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

  // 더하기
  void plus(String x) {
    debugPrint('plus');
  }

  // 빼기
  void minus(String x) {
    debugPrint('minus');
  }

  // 곱하기
  void multiply(String x) {
    debugPrint('multiply');
  }

  // 나누기
  void divide(String x) {
    debugPrint('divide');
  }

  // 계산
  void equals() {
    setState(() {});
  }

  // 클리어
  void clear() {
    debugPrint('clear()');
    setState(() {
      for (var x in [total, padText, syntax]) {
        x = '';
      }
      num1 = 0;
      num2 = 0;
    });
  }
}
