## 1. wholeNumberValue

`Character`가 가지고 있는 프로퍼티로, 문자가 나타내는 정수 값을 반환한다.

- **타입:** `Int?` (Optional)
    
- **특징:** 문자가 숫자가 아니면 `nil`을 반환한다.
    
- **기존 방식과의 비교:**
    
    - 예전 방식: `Int(String(char))` (문자를 String으로 바꾸고 다시 Int로 변환, 비효율적)
        
    - **권장 방식:** `char.wholeNumberValue` (더 직관적이고 효율적)

```swift
let char1: Character = "7"
let char2: Character = "A"

print(char1.wholeNumberValue) // Optional(7)
print(char2.wholeNumberValue) // nil
```

---

Instance Property
# wholeNumberValue

The numeric value this character represents, if it represents a whole number.

iOS 8.0+ | iPadOS 8.0+ | Mac Catalyst 13.0+ | macOS 10.10+ | tvOS 9.0+ | visionOS 1.0+ | watchOS 2.0+

```
var wholeNumberValue: Int? { get }
```

## [Discussion](https://developer.apple.com/documentation/swift/character/wholenumbervalue#discussion)

If this character does not represent a whole number, or the value is too large to represent as an `Int`, the value of this property is `nil`.

```
let chars: [Character] = ["4", "④", "万", "a"]
for ch in chars {
    print(ch, "-->", ch.wholeNumberValue)
}
// Prints:
// 4 --> Optional(4)
// ④ --> Optional(4)
// 万 --> Optional(10000)
// a --> nil
```

## [See Also](https://developer.apple.com/documentation/swift/character/wholenumbervalue#see-also)

[`var isNumber: Bool`](https://developer.apple.com/documentation/swift/character/isnumber)

A Boolean value indicating whether this character represents a number.

[`var isWholeNumber: Bool`](https://developer.apple.com/documentation/swift/character/iswholenumber)

A Boolean value indicating whether this character represents a whole number.

[`var isHexDigit: Bool`](https://developer.apple.com/documentation/swift/character/ishexdigit)

A Boolean value indicating whether this character represents a hexadecimal digit.

[`var hexDigitValue: Int?`](https://developer.apple.com/documentation/swift/character/hexdigitvalue)

The numeric value this character represents, if it is a hexadecimal digit.

---

> [[iOS 학습 인덱스]]