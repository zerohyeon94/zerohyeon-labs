## ✅ 1. CoreBluetooth 개요

**CoreBluetooth**는 iOS에서 BLE 통신을 위한 프레임워크입니다.
주로 다음과 같은 역할로 나뉘어 사용됩니다.

| 역할             | 클래스                                              | 구조                         |
| -------------- | ------------------------------------------------ | -------------------------- |
| 중앙(Central)    | `CBCentralManager`, `CBPeripheral`               | 데이터를 "가져오는" 쪽. 예: iPhone 앱 |
| 주변(Peripheral) | `CBPeripheralManager`, `CBMutableCharacteristic` | 데이터를 "보여주는" 쪽. 예: 청진기, 센서  |

> 대부분의 iOS 앱은 중앙(Central) 역할을 수행하며 BLE 기기(주변기기)에 연결합니다.
---
## ✅ 2. BLE 통신 흐름

BLE 통신은 다음과 같은 단계로 동작합니다:

```
1. CBCentralManager 시작 (전원 상태 확인)
2. 주변 기기 스캔 시작 (scanForPeripherals)
3. 주변 기기 발견 → 연결 (connect)
4. 서비스(Service) 검색
5. 캐릭터리스틱(Characteristic) 검색
6. 캐릭터리스틱 읽기/쓰기/알림 등록
7. 데이터 송수신 처리
```
## 🔄 BLE 통신 흐름 요약

1. **Central 초기화**
    ```swift
    let centralManager = CBCentralManager(delegate: self, queue: nil)
    ```
2. **기기 스캔 시작**
    ```swift
    centralManager.scanForPeripherals(withServices: nil, options: nil)
    ```
3. **기기 발견 시 연결**
    ```swift
    centralManager.connect(peripheral, options: nil)
    ```
4. **서비스 탐색**
    ```swift
    peripheral.discoverServices(nil)
    ```
5. **캐릭터리스틱 탐색**
    ```swift
    peripheral.discoverCharacteristics(nil, for: service)
    ```
6. **데이터 읽기 또는 알림 설정**
    ```swift
    peripheral.readValue(for: characteristic)
    peripheral.setNotifyValue(true, for: characteristic)
    ```
7. **데이터 수신**
	```swift
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
	``` 

## 💡 실제 사용 예시 (예: 청진기 BLE 연동)

- 특정 **서비스 UUID**와 **캐릭터리스틱 UUID**를 알고 있다면 해당 값으로 `scanForPeripherals`나 `discoverServices`를 필터링할 수 있어요.
- 데이터를 전송받거나 보낼 때는 해당 캐릭터리스틱 UUID를 기준으로 읽기/쓰기 작업을 합니다.
---
## 🔍 예시 코드 조각

```swift
func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) { 
	self.peripheral = peripheral central.connect(peripheral, options: nil) 
} 

func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) { 
	peripheral.delegate = self 
	peripheral.discoverServices([CBUUID(string: "180D")]) // 예: 심박수 서비스 
}
``` 
---
## ✅ 3. 주요 클래스/메서드 개념

| 클래스/메서드                              | 설명                           |
| ------------------------------------ | ---------------------------- |
| ⭐️`CBCentralManager`                 | BLE 스캔 및 연결 담당               |
| ⭐️`CBPeripheral`                     | 특정 주변기기 (기기)에 대한 연결 및 서비스 검색 |
| ⭐️`CBService`                        | 기기 내에서 기능(서비스)을 구분하는 단위      |
| ⭐️`CBCharacteristic`                 | 실제 데이터를 주고받는 단위              |
| `centralManager(_:didDiscover:)`     | 주변기기 발견 시 호출                 |
| `centralManager(_:didConnect:)`      | 연결 완료 시 호출                   |
| `peripheral.discoverServices`        | 서비스 검색                       |
| `peripheral.discoverCharacteristics` | 캐릭터리스틱 검색                    |
| `readValue`, `writeValue`            | 읽기/쓰기 동작                     |
| `setNotifyValue(true)`               | 알림 수신 등록                     |

---

## ✅ 4. 알아야 할 BLE 개념

|용어|설명|
|---|---|
|**UUID**|서비스와 캐릭터리스틱을 식별하는 고유 ID (16/32/128-bit)|
|**Service**|기능 그룹 (예: 심박수 측정)|
|**Characteristic**|개별 데이터 단위 (예: 현재 심박수 값)|
|**Properties**|`.read`, `.write`, `.notify` 등 동작 가능성 표시|
|**Descriptors**|추가 메타데이터 (잘 사용하지 않지만 존재)|
|**MTU**|한 번에 전송 가능한 최대 데이터 크기 (기본 20바이트)|
|**Notify vs Indicate**|실시간 데이터 수신 방식 (Notify는 확인 없음, Indicate는 응답 보냄)|

---

## ✅ 5. BLE 연동 시 주의점

- **BLE 권한 설정**: `Info.plist`에 `NSBluetoothAlwaysUsageDescription` 추가
- **앱이 백그라운드 상태일 때 제한 있음**: `UIBackgroundModes` > `bluetooth-central` 필요
- **데이터 크기 제한**: 기본 20 byte → 장치와 협의하여 패킷 나눠서 전송
- **타이밍 이슈**: 너무 빠른 read/write는 실패 가능
- **연결 상태 유지**: 재접속/타임아웃 관리 필요

## 📌 마무리 요약

| 항목        | 요약                                               |
| --------- | ------------------------------------------------ |
| BLE 통신 흐름 | 스캔 → 연결 → 서비스 → 캐릭터리스틱 → 데이터 주고받기                |
| 핵심 개념     | UUID, Service, Characteristic, read/write/notify |
| 주의 사항     | 권한, 백그라운드 모드, 타이밍, 메모리 누수, 데이터 크기 제한             |
| 면접 포인트    | 흐름 설명 능력, UUID 이해, notify vs read 구분, 문제 해결 경험   |