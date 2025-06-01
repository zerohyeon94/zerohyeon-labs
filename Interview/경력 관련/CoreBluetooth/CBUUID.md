`CBUUID`는 **CoreBluetooth에서 BLE 서비스나 캐릭터리스틱을 특정하기 위해 사용하는 식별자**입니다.

BLE 통신에서 기기를 특정하거나 기능을 찾기 위해 **UUID를 사용하는데**, 이를 Swift에서 다루기 쉽게 만들어둔 구조체가 `CBUUID`입니다.

---
## ✅ CBUUID란?

- *CBUUID (CoreBluetooth UUID)**는 BLE의 **Service** 또는 **Characteristic**을 식별하기 위한 **고유 식별자**를 표현하는 타입입니다.
- BLE 프로토콜은 모든 기능(서비스/캐릭터리스틱)을 **UUID로 식별**합니다.
- iOS의 CoreBluetooth에서는 이 UUID를 **CBUUID 객체**로 다룹니다.

```swift
let heartRateServiceUUID = CBUUID(string: "180D") // 표준 심박수 서비스
let customServiceUUID = CBUUID(string: "F0001130-0451-4000-B000-000000000000") // 사용자 정의
```

---

## ✅ CBUUID의 목적

|목적|설명|
|---|---|
|✅ 기기 식별|특정 서비스(UUID)를 갖는 기기만 검색하기 위함|
|✅ 서비스 검색|연결된 기기에서 특정 서비스만 검색|
|✅ 캐릭터리스틱 찾기|해당 서비스 내에서 원하는 기능(UUID)의 캐릭터리스틱을 찾기 위함|

---

## ✅ 사용 예시

### 🔹 1. 특정 UUID를 가진 기기만 스캔

```swift
let serviceUUIDs = [CBUUID(string: "180D")] // 심박수 서비스
centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
```

### 🔹 2. 서비스 내 캐릭터리스틱 검색

```swift
peripheral.discoverCharacteristics([CBUUID(string: "2A37")], for: service)
```

---

## ✅ 표준(UUID) vs 사용자 정의(UUID)

|종류|예시|설명|
|---|---|---|
|표준 UUID|`"180D"` (심박수), `"2A37"` (심박 측정값)|Bluetooth SIG에서 정의한 공용 값|
|사용자 정의 UUID|`"F000AA00-0451-4000-B000-000000000000"`|기기 제조사에서 임의로 설정|
## 📌 정리 요약

|항목|설명|
|---|---|
|CBUUID|BLE 서비스/캐릭터리스틱 식별을 위한 UUID 타입|
|쓰임|스캔, 서비스 검색, 캐릭터리스틱 찾기|
|표준 vs 사용자 정의|표준은 Bluetooth SIG 정의, 사용자 정의는 제조사 정의|
|사용 목적|BLE 기능을 정확하게 지정하고 연결하기 위함|
## ✅ cbuuidService & cbuuidCharacteristic

```swift
public func cbuuidService(_ param: Dictionary<String, String>? ) -> CBUUID
public func cbuuidCharacteristic(_ param: Dictionary<String, String>? ) -> CBUUID
```

---

## ✅ 핵심 차이점 요약

|함수 이름|반환하는 UUID 종류|의미|
|---|---|---|
|`cbuuidService`|**서비스 UUID**|기기가 제공하는 기능의 범주 (예: 심박수 측정 전체 기능)|
|`cbuuidCharacteristic`|**캐릭터리스틱 UUID**|서비스 내의 **개별 데이터 항목** (예: 심박수 수치)|
## 🔹 예를 들어 보겠습니다

BLE 기기 예시 (심박수 측정기):

- **서비스 UUID**: `180D` (Heart Rate Service)
- **캐릭터리스틱 UUID**: `2A37` (Heart Rate Measurement)

```swift
// 기기를 스캔할 때 사용하는 서비스 UUID
let heartRateServiceUUID = CBUUID(string: "180D") // 서비스 전체

// 연결 후 측정 데이터를 받을 때 사용되는 캐릭터리스틱 UUID
let heartRateMeasurementUUID = CBUUID(string: "2A37") // 특정 데이터
```

---

## 🔹 코드 설명

```swift
public func cbuuidService(_ param: Dictionary<String, String>? ) -> CBUUID {
    return SKEEPER_SERVICE_CBUUID
}
```

- 이 함수는 **BLE 기기의 "서비스"를 특정하기 위한 UUID**를 리턴합니다.
- 이 UUID는 `scanForPeripherals(withServices:)` 같은 함수에서 특정 기기만 찾을 때 사용됩니다.

```swift
public func cbuuidCharacteristic(_ param: Dictionary<String, String>? ) -> CBUUID {
    return SKEEPER_CHARACTERISTIC_CBUUID
}
```

- 이 함수는 **연결 후 데이터를 주고받는 캐릭터리스틱**의 UUID를 리턴합니다.
- `discoverCharacteristics(_:for:)` 에 사용됩니다.

---

## ✅ 실제 사용 흐름 예시

```swift
// 1. 스캔 단계: 서비스 UUID로 기기 필터링
centralManager.scanForPeripherals(withServices: [cbuuidService(nil)], options: nil)

// 2. 연결 후: 서비스 검색 후 해당 캐릭터리스틱 검색
peripheral.discoverCharacteristics([cbuuidCharacteristic(nil)], for: service)
```

---

## ✅ 결론

|함수|역할|
|---|---|
|`cbuuidService`|BLE 기기의 전체 기능 범주(Service)를 찾기 위해 사용|
|`cbuuidCharacteristic`|서비스 내부의 세부 데이터 항목(Characteristic)을 찾기 위해 사용|

이처럼 **서비스는 "기능 묶음"**, **캐릭터리스틱은 "실제 데이터를 담는 통신 채널"**이라고 이해하시면 됩니다.