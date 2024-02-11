import 'package:flutter/material.dart';

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
  final List<List<dynamic>> _list = [
    ['AC', '+/-', '%', '/'],
    ['7', '8', '9', 'x'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '00', '.', '='],
  ];

  String value = '0'; // 계산기 보여줄 텍스트
  String syntax = ''; // 산수 부호
  String prevValue = '0';

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
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: value.length > maxLength
                        ? (_fontSize - value.length).toDouble()
                        : _fontSize,
                  ),
                ),
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
                              onTap: () => calc(y),
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
  Future<void> calc(String x) async {
    String result = '';

    switch (x) {
      case 'AC': // 초기화
        result = '0';
        prevValue = '0';
        break;
      case '+/-': // 양음수 변환
        result = positiveConversion(x);
        break;
      case '%': // 퍼센트
        break;
      case '/': // 나누기
      case 'x': // 곱하기
      case '-': // 뺴기
      case '+': // 더하기
        result = pressSyntax(x);
        break;
      case '00': // 0 두개 붙이기
        result = addString(x);
        break;
      case '.': // 소수점 찍기
        result = addPoint(x);
        break;
      case '=': // 계산 완료
        break;
      default: // 0~9
        result = addString(x);
        break;
    }
    debugPrint('>>> value: $value, prevValue: $prevValue');
    // 계산기 화면의 값 수정
    setState(() {
      value = result;
    });
  }

  // 숫자 문자열 추가
  String addString(String x) {
    String result = '';

    // 숫자 여부 확인
    if (isNum(x)) {
      if (value.substring(0) == '0') {
        // value 값이 0인 경우 입력된 x만 추가
        result = x;
      } else {
        // value 값이 0이 아닌 경우 기존 value 에 x 추가
        debugPrint('>>>> value + x: ${value + x}');
        result = value + x;
        debugPrint('>>>> result: $result');
      }
    }
    return result;
  }

  // 숫자 여부 판단
  bool isNum(String x) {
    RegExp regExp = RegExp(r'^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$'); // 숫자형 정규식
    if (regExp.hasMatch(x)) {
      return true;
    } else {
      return false;
    }
  }

  // 양/음수 변환
  String positiveConversion(String x) {
    // 숫자 인지 판단
    if (isNum(x)) {
      double num = double.parse(x);
      num = num * -1; // 숫자면 숫자 (-1)을 곱하여 양음수 전환
      return num.toString();
    } else {
      return x;
    }
  }

  // 소수점 추가
  String addPoint(String x) => '$x.';

  // 덧셈, 뺄셈, 곱하기, 나누기
  String pressSyntax(String x) {
    double prev = 0;
    switch (x) {
      case '+':
        prev = double.parse(prevValue) + double.parse(value);
        break;
      case '-':
        prev = double.parse(prevValue) - double.parse(value);
        break;
      case '*':
        prev = double.parse(prevValue) * double.parse(value);
        break;
      case '/':
        prev = double.parse(prevValue) / double.parse(value);
        break;
    }
    setState(() {
      prevValue = prev.toString(); // 이전의 값 저장
      syntax = x; // 부호 추가
    });
    return !value.contains('.')
        ? prev.toStringAsFixed(0)
        : prev.toString();
  }

  // 계산
  void equals() {
    setState(() {
      prevValue = '0'; // 이전값 초기화
      syntax = ''; // 부호 초기화
    });
  }
}
