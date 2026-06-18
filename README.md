git : https://github.com/kwondo99/fpga_uart_fifo_sensor_system

# FPGA UART FIFO Sensor System

## Project Overview

BASYS3 FPGA 보드에서 UART 통신, FIFO, ASCII Decoder/Sender, Watch/Stopwatch, SR04 초음파 센서, DHT11 온습도 센서, FND 출력을 통합한 3인 팀 프로젝트이다.

PC 키보드 입력을 UART로 수신하고, ASCII 명령어를 해석하여 보드의 시간 관리 기능과 센서 측정 기능을 제어하도록 설계했다. 측정된 시간 및 센서 데이터는 FND, LED, UART TX를 통해 확인할 수 있도록 구성했다.

전체 기능 블록을 연결하는 Top Module 구성과, 버튼 입력 및 ASCII 명령을 통합 제어하는 Control Unit 설계를 담당했다.

**사용 언어:**

Verilog

**사용 도구:**

Xilinx Vivado (Simulator)

## Project Information

| 항목 | 내용 |
| --- | --- |
| Period | 2026.05.01 ~ 2026.05.06 |
| Team | 3 members |
| My Role | Top Module 구성, Control Unit 설계, Watch, StopWatch 설계, 시스템 통합 및 시뮬레이션 검증 |
| Board | BASYS3 FPGA |
| Language | Verilog, SystemVerilog |
| Tool | Vivado, Vivado Simulator |
| Result | RTL 설계 / 시뮬레이션 / FPGA 구현 완료 |

## My Role

본 프로젝트는 3인 1조로 진행했으며, 각 팀원이 통신부, 센서부, 출력부, 제어부를 분담하여 설계한 뒤 Top Module에서 하나의 FPGA 시스템으로 통합했다.

Top Module 구성과 Control Unit 설계를 담당했다. UART로 수신된 ASCII 명령과 보드 버튼 입력을 동일한 제어 신호로 처리하고, Watch/Stopwatch 및 Sensor 모드 전환, FND 출력 선택, UART 상태 출력 제어가 정상적으로 이루어지도록 설계했다.

### Main Contributions

- UART, FIFO, ASCII Decoder, Watch/Stopwatch, Sensor, FND Controller를 연결하는 Top Module 구성
- 버튼 입력과 ASCII 명령을 통합 처리하는 Control Unit 설계 (select_control 기반 분배 구조)
- btnR 또는 ASCII `6` 입력에 따른 Time/Sensor 그룹 전환 구조 구현
- sw[0], sw[1] 입력에 따른 Watch, Stopwatch, SR04, DHT11 출력 선택 구조 설계
- 각 모드별 제어 신호가 Datapath와 FND 출력 경로로 정상 전달되는지 시뮬레이션 검증
- Top Module Waveform 분석을 통한 신호 연결 오류 및 Timing 문제 디버깅

## System Architecture

전체 시스템은 PC, UART_RX, FIFO_RX, ASCII_Decoder, Control Unit, Datapath, FND Controller, UART_TX, FIFO_TX, ASCII_Sender로 구성했다.

PC에서 입력된 ASCII 문자는 UART_RX를 통해 8-bit 병렬 데이터로 변환되고, FIFO_RX에 임시 저장된 뒤 ASCII_Decoder에서 제어 신호로 변환된다. Control Unit은 버튼 입력과 ASCII 명령을 통합하여 Watch, Stopwatch, SR04, DHT11 중 선택된 기능을 제어하고, Datapath에서 생성된 데이터는 FND와 UART_TX 경로로 출력되도록 구성했다. 상태/현재값을 PC로 출력할 때는 ASCII_Sender가 데이터를 1 digit씩 ASCII Code로 변환하고 FIFO_TX를 거쳐 UART_TX로 송신한다.

## Main Features

- BASYS3 FPGA 기반 통합 시스템 설계
- UART RX/TX 통신 모듈 연동 (9600 bps, 16x Oversampling tick = 153,600 Hz)
- FIFO Buffer를 이용한 데이터 송수신 안정화
- ASCII Decoder 기반 PC 키보드 명령 제어
- ASCII Sender 기반 상태/현재값 PC 출력 (Status + Data를 digit 단위 ASCII로 변환)
- Watch / Stopwatch 기능 통합
- SR04 초음파 센서 거리 측정 기능 구현
- DHT11 온습도 센서 데이터 수신 기능 구현 (1-Wire, 40-bit SIPO)
- FND Controller를 통한 측정값 및 시간 데이터 출력
- Button Debounce 및 LED 상태 표시 기능 구현
- Top Module Simulation 및 FPGA 동작 검증

## Control Mapping

### Switch

| Switch | 0 | 1 |
| --- | --- | --- |
| sw[0] | Watch 작동 | Stopwatch 작동 |
| sw[1] | Sec & Msec / Distance | Hour & Min / Temp & Humidity |
| sw[2] | Watch 정상 작동 | Watch 설정 모드 |

### Button & ASCII Command

| Button & Key | Watch | Stopwatch | Sensor |
| --- | --- | --- | --- |
| btnR / `6` | FND 값 변경 (Time ↔ Sensor 그룹 전환) |  |  |
| btnL / `4` | 자리수 이동 | Clear | 현재값 FND 출력 |
| btnD / `2` | 값 Down | Mode (Up/Down) | - |
| btnU / `8` | 값 Up | Run/Stop | - |
| `s` | 현재 시간 확인 | 현 상태 확인 | 현재값 PC 확인 |

## Control Unit Design

Control Unit은 버튼 입력과 UART ASCII 명령을 통합하여 시스템의 모드 선택과 기능 제어 신호를 생성하는 역할을 한다.

내부적으로 `select_control`이 입력(`btnL || ascii_4`, `btnD || ascii_2`, `btnU || ascii_8`, `btnR || ascii_6`, sw[0/1/2], ascii_s)을 받아 하위 제어 모듈로 분배한다.

| Sub Module | 출력 신호 |
| --- | --- |
| watch_control_unit | o_sel[2:0], o_digit, o_up_down |
| sw_control_unit | o_mode, o_run_stop, o_clear |
| sensor_control_unit | sr04_start, dht11_start |
| fnd_control_unit | datapath_sel[1:0], fnd_controller_sel |
| status_control_unit | sel_watch_status, sel_sw_status, sel_sr04_status, sel_dht_status |

보드 버튼뿐만 아니라 PC 키보드 입력으로도 동일한 기능을 수행할 수 있도록 ASCII Decoder 출력 신호와 Button Debounce 출력을 하나의 제어 흐름으로 통합했다. 이를 통해 Watch/Stopwatch 모드 전환, Sensor 모드 전환, 시간 설정, Run/Stop, Clear, 현재 상태 출력 기능을 제어할 수 있도록 설계했다.

## Sensor Overview

| 항목 | SR04 | DHT11 |
| --- | --- | --- |
| 측정 | 초음파 거리 측정 | 온도 / 습도 측정 |
| 통신 | 단방향 (trig / echo) | 단선 양방향 (1-Wire) |
| 변환 | Distance = echo / 58 (cm) | 40-bit 데이터 전송 |
| 구현 포인트 | 나눗셈 → 58µs 누적 카운트 | 3-state buffer + synchronizer |

### SR04 동작 요약

- `sr04_start` 인가 시 10µs 이상의 trig 펄스를 생성한다 (실측 11µs / 10,990ns 유지).
- echo High 구간 동안 1µs 카운터가 0~57 (58µs)을 주기로 롤오버될 때마다 distance를 +1 누적한다.
- distance가 400에 도달하면 Out of Range로 판단하여 RESPONSE → IDLE로 즉시 복귀한다 (Deadlock 방지, 400 × 58 = 23,200µs).

### DHT11 동작 요약

- Start phase: 18ms 이상 Low 구동 후 버스 제어권을 반환하며(High-Z), 풀업 저항으로 Idle 상태로 복구한다.
- Sync phase: 센서 응답 80µs Low → 80µs High 핸드셰이크를 포착한다.
- Data phase: High 구간 유지 시간을 임계값(40µs)과 비교하여 26µs면 `0`, 70µs면 `1`로 판별한다.
- 2-Stage Synchronizer(2단 D-FF)로 비동기 dht11 신호의 메타스테빌리티를 방어한다.
- 40번 Shift로 SIPO 변환 후 [39:32] 습도, [23:16] 온도를 추출한다.

## Top Module Integration

Top Module에서는 UART_RX, FIFO_RX, ASCII_Decoder, Control Unit, Datapath, FND Controller, ASCII_Sender, FIFO_TX, UART_TX 모듈을 하나의 시스템으로 연결했다.

PC에서 입력된 ASCII 명령은 UART_RX와 FIFO_RX를 거쳐 ASCII_Decoder에서 제어 신호로 변환되고, Control Unit은 이 신호를 버튼 입력과 함께 처리한다. 이후 선택된 모드에 따라 Watch, Stopwatch, SR04, DHT11 데이터가 FND와 UART_TX 출력 경로로 전달되도록 구성했다.

## Simulation & FPGA Verification

각 파트를 Communication, Datapath, Control Unit, Top Module로 나누어 검증했다.

- **Communication (UART/FIFO/ASCII)**: `s` 입력 시 ASCII_Sender가 Status(W/S/D/E) + Data를 순서대로 push_data에 싣고, FIFO가 선입선출로 pop하며, UART_TX가 1byte 단위로 PC에 출력되는지 확인했다.
- **Datapath (SR04/DHT11)**: trig 펄스 규격, 거리 누적, Out of Range 복귀, DHT11 핸드셰이크/비트 판별/SIPO 무결성을 검증했다 (Checksum Valid, Humidity 45% / Temperature 25°C 확인).
- **Control Unit**: watch / stopwatch / sr04 / dht11 각 시나리오에서 제어 출력과 status 신호가 1 tick으로 발생하는지 확인했다.
- **Top Module**: 버튼·UART 명령·센서 측정·FND 출력이 통합 시스템에서 정상 동작하는지, `fnd_data_in` 변화 / `w_sel_*_status` / `tx` 발생을 함께 검증했다.

최종적으로 Top Module 시뮬레이션과 FPGA Implementation을 통해 통합 시스템이 정상 동작함을 확인했다.

## What I Learned

3인 팀 프로젝트를 통해 개별 모듈을 단순히 구현하는 것뿐만 아니라, 여러 기능 블록을 하나의 Top System으로 통합하는 과정을 경험했다.

- 센서 스펙을 확인하고 이를 기준으로 신호 타이밍과 제어 조건을 설계하는 방법을 배웠다.
- ASCII Decoder/Sender를 활용하며 PC와의 데이터 통신 방식을 경험했다.
- FIFO를 buffer 및 register 구조로 활용하여 UART 데이터 손실을 방지하는 방법을 익혔다.
- Top Module을 구성하면서 모듈 간 입출력 신호의 방향, bit width, 동작 timing이 정확히 맞아야 전체 시스템이 안정적으로 동작한다는 점을 확인했다.
- Control Unit을 설계하며 버튼 입력과 UART ASCII 명령을 동일한 제어 구조로 통합하는 방법을 익혔고, FPGA 시스템에서 제어부가 전체 기능 흐름을 결정하는 핵심 블록임을 이해했다.
- 역할 분담을 통해 모듈별 설계와 검증을 효율적으로 진행하는 협업의 중요성을 느꼈다.
