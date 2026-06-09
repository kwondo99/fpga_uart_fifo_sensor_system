# FPGA UART FIFO Sensor System

## Project Overview

BASYS3 FPGA 보드에서 UART 통신, FIFO, ASCII Decoder, Watch/Stopwatch, SR04 초음파 센서, DHT11 온습도 센서, FND 출력을 통합한 3인 팀 프로젝트입니다.

PC 키보드 입력을 UART로 수신하고, ASCII 명령어를 해석하여 보드의 시간 관리 기능과 센서 측정 기능을 제어하도록 설계했습니다. 측정된 시간 및 센서 데이터는 FND, LED, UART TX를 통해 확인할 수 있도록 구성했습니다.

저는 전체 기능 블록을 연결하는 Top Module 구성과, 버튼 입력 및 ASCII 명령을 통합 제어하는 Control Unit 설계를 담당했습니다.

## Project Information

| 항목       | 내용                                                |
| -------- | ------------------------------------------------- |
| Period   | 2026.05.01 ~ 2026.05.06                           |
| Team     | 3 members                                         |
| My Role  | Top Module 구성, Control Unit 설계, 시스템 통합 및 시뮬레이션 검증 |
| Board    | BASYS3 FPGA                                       |
| Language | Verilog, SystemVerilog                            |
| Tool     | Vivado, Vivado Simulator                          |
| Result   | RTL 설계 / 시뮬레이션 / FPGA 구현 완료                       |

## My Role

본 프로젝트는 3인 1조로 진행했으며, 각 팀원이 통신부, 센서부, 출력부, 제어부를 분담하여 설계한 뒤 Top Module에서 하나의 FPGA 시스템으로 통합했습니다.

저는 Top Module 구성과 Control Unit 설계를 담당했습니다. UART로 수신된 ASCII 명령과 보드 버튼 입력을 동일한 제어 신호로 처리하고, Watch/Stopwatch 및 Sensor 모드 전환, FND 출력 선택, UART 상태 출력 제어가 정상적으로 이루어지도록 설계했습니다.

### Main Contributions

* UART, FIFO, ASCII Decoder, Watch/Stopwatch, Sensor, FND Controller를 연결하는 Top Module 구성
* 버튼 입력과 ASCII 명령을 통합 처리하는 Control Unit 설계
* btnR 또는 ASCII `6` 입력에 따른 Time/Sensor 그룹 전환 구조 구현
* sw[0], sw[1] 입력에 따른 Watch, Stopwatch, SR04, DHT11 출력 선택 구조 설계
* 각 모드별 제어 신호가 Datapath와 FND 출력 경로로 정상 전달되는지 시뮬레이션 검증
* Top Module Waveform 분석을 통한 신호 연결 오류 및 Timing 문제 디버깅

## System Architecture

전체 시스템은 PC, UART_RX, FIFO_RX, ASCII_Decoder, Control Unit, Datapath, FND Controller, UART_TX로 구성했습니다.

PC에서 입력된 ASCII 문자는 UART_RX를 통해 8-bit 병렬 데이터로 변환되고, FIFO_RX에 임시 저장된 뒤 ASCII_Decoder에서 제어 신호로 변환됩니다. Control Unit은 버튼 입력과 ASCII 명령을 통합하여 Watch, Stopwatch, SR04, DHT11 중 선택된 기능을 제어하고, Datapath에서 생성된 데이터는 FND와 UART_TX 경로로 출력되도록 구성했습니다.

```text
PC Keyboard Input
        ↓
UART_RX
        ↓
FIFO_RX
        ↓
ASCII_Decoder
        ↓
Control Unit
        ↓
Datapath
        ↓
FND / LED / UART_TX
```

## Main Features

* BASYS3 FPGA 기반 통합 시스템 설계
* UART RX/TX 통신 모듈 연동
* FIFO Buffer를 이용한 데이터 송수신 안정화
* ASCII Decoder 기반 PC 키보드 명령 제어
* Watch / Stopwatch 기능 통합
* SR04 초음파 센서 거리 측정 기능 구현
* DHT11 온습도 센서 데이터 수신 기능 구현
* FND Controller를 통한 측정값 및 시간 데이터 출력
* Button Debounce 및 LED 상태 표시 기능 구현
* Top Module Simulation 및 FPGA 동작 검증

## ASCII Command Mapping

| ASCII Input | Function                       |
| ----------- | ------------------------------ |
| `s`         | 현재 상태 UART 출력                  |
| `2`         | Down / Mode 제어                 |
| `4`         | Left / Clear / 현재값 출력          |
| `6`         | Watch·Stopwatch / Sensor 모드 전환 |
| `8`         | Up / Run·Stop 제어               |

## Control Unit Design

Control Unit은 버튼 입력과 UART ASCII 명령을 통합하여 시스템의 모드 선택과 기능 제어 신호를 생성하는 역할을 합니다.

보드 버튼뿐만 아니라 PC 키보드 입력으로도 동일한 기능을 수행할 수 있도록 ASCII Decoder 출력 신호와 Button Debounce 출력을 하나의 제어 흐름으로 통합했습니다. 이를 통해 Watch/Stopwatch 모드 전환, Sensor 모드 전환, 시간 설정, Run/Stop, Clear, 현재 상태 출력 기능을 제어할 수 있도록 설계했습니다.

## Top Module Integration

Top Module에서는 UART_RX, FIFO_RX, ASCII_Decoder, Control Unit, Datapath, FND Controller, UART_TX 모듈을 하나의 시스템으로 연결했습니다.

PC에서 입력된 ASCII 명령은 UART_RX와 FIFO_RX를 거쳐 ASCII_Decoder에서 제어 신호로 변환되고, Control Unit은 이 신호를 버튼 입력과 함께 처리합니다. 이후 선택된 모드에 따라 Watch, Stopwatch, SR04, DHT11 데이터가 FND와 UART_TX 출력 경로로 전달되도록 구성했습니다.

## Simulation & FPGA Verification

각 파트를 Communication, Datapath, Control Unit, Top Module로 나누어 검증했습니다.

UART/FIFO/ASCII 경로에서는 PC 입력 명령이 정상적으로 제어 신호로 변환되는지 확인했고, Sensor/FND 경로에서는 SR04와 DHT11 데이터가 FND 출력 형식으로 전달되는지 검증했습니다.

최종적으로 Top Module 시뮬레이션과 FPGA Implementation을 통해 버튼 입력, UART 명령 입력, 센서 측정, FND 출력이 통합 시스템에서 정상적으로 동작하는지 확인했습니다.

## Troubleshooting

### Module Integration Issue

각 팀원이 분담하여 설계한 모듈을 Top Module에서 연결하는 과정에서 신호명, bit width, enable 조건이 일치하지 않는 문제가 발생할 수 있었습니다. 이를 해결하기 위해 모듈별 입출력 신호를 정리하고, Top Module에서 연결 관계를 다시 확인하며 Waveform 기반으로 신호 전달 흐름을 검증했습니다.

### Button and ASCII Command Control Issue

보드 버튼 입력과 UART ASCII 명령 입력이 동일한 기능을 수행해야 했기 때문에 제어 신호가 중복되거나 충돌할 가능성이 있었습니다. 이를 해결하기 위해 Control Unit에서 버튼 입력과 ASCII Decoder 출력을 하나의 제어 흐름으로 통합하고, 모드별로 필요한 제어 신호만 Datapath에 전달되도록 구성했습니다.

### UART Data Timing Issue

UART는 1-byte 단위로 데이터를 순차 처리하기 때문에 여러 바이트 데이터를 전송할 때 데이터 유실 가능성이 있었습니다. 이를 해결하기 위해 FIFO를 사용하여 수신 및 송신 데이터를 임시 저장하고, UART 동작 가능 상태에 맞춰 순차적으로 데이터를 처리하도록 구성했습니다.

## What I Learned

3인 팀 프로젝트를 통해 개별 모듈을 단순히 구현하는 것뿐만 아니라, 여러 기능 블록을 하나의 Top System으로 통합하는 과정을 경험했습니다.

특히 Top Module을 구성하면서 모듈 간 입출력 신호의 방향, bit width, 동작 timing이 정확히 맞아야 전체 시스템이 안정적으로 동작한다는 점을 확인했습니다.

또한 Control Unit을 설계하며 버튼 입력과 UART ASCII 명령을 동일한 제어 구조로 통합하는 방법을 익혔고, FPGA 시스템에서 제어부가 전체 기능 흐름을 결정하는 핵심 블록임을 이해했습니다.

## Tools

* Verilog
* SystemVerilog
* Vivado
* Vivado Simulator
* BASYS3 FPGA
