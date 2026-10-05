# 선택 산술 참조

완성된 Python 코드로 signed 해석, carry·overflow, 곱셈·나눗셈 실행, 누산기 비트 폭을 확인한다. 강의 확인 문제와 선택 심화 학습에 사용한다.

```bash
make test
make demo
```

`0x7fffffff + 1`과 `0xffffffff + 1`의 결과·carry·overflow를 먼저 예측하고 실행값과 비교한다. `dot_i16`의 넓은 누산기와 좁은 누산기도 비교할 수 있다. 이 자료는 선택 자습용으로 제공하며, 별도 제출은 요구 범위에서 제외한다. 필수 RTL 구현은 [HW02](../../assignments/hw02/README.md)에 포함한다.
