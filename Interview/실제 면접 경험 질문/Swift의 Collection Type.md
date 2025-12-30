## 1) 대표 컬렉션 3가지

### 1) Array

- **순서 있음(ordered)**
    
- **중복 허용**
    
- 인덱스로 접근: `arr[0]`

```swift
var a = [1, 2, 3]
a.append(4)          // [1,2,3,4]
let x = a[1]         // 2
```

**언제?**

- “순서”가 중요하거나, UI 리스트/테이블/섹션 같은 것

**성능 감각**

- `append`(끝에 추가) 보통 빠름(암묵적으로 평균 O(1))
    
- 중간 삽입/삭제는 뒤 원소들을 밀어야 해서 보통 O(n)
    
- 인덱스 접근 O(1)

---

### 2) Dictionary (키-값)

- **순서 없음(개념적으로)**
    
- **키 중복 불가, 값은 중복 가능**
    
- 키로 접근: `dict[key]`

```swift
var d: [String: Int] = ["apple": 3, "banana": 2]
d["apple"] = 4
let v = d["banana"]  // Optional(2)
```

**언제?**

- “이름 → 점수”, “id → 모델”처럼 **빠르게 찾고 싶을 때**

**성능 감각**

- 키로 조회/삽입/삭제 평균 O(1) (해시 기반)
    
- `dict[key]`는 **Optional** (없는 키일 수 있어서)

---

### 3) Set

- **순서 없음**
    
- **중복 불가(유일성)**
    

```swift
var s: Set<Int> = [1, 2, 2, 3]  // 실제론 {1,2,3}
s.insert(4)
s.contains(2) // true
```

**언제?**

- “중복 제거”, “포함 여부(contains) 체크”가 핵심일 때  
    예) 즐겨찾기 id 목록, 차단 리스트, 권한 목록 등
    

**성능 감각**

- `contains`, `insert`, `remove` 평균 O(1)

---

## 2) 공통 개념: Value Type + Copy-on-Write (중요)

Swift의 `Array/Dictionary/Set`은 **값 타입(struct)** 입니다.

- 변수에 대입하면 “바로 전체 복사”가 아니라,
    
- **실제로 수정될 때(copy-on-write)** 복사합니다.

```swift
var a1 = [1,2,3]
var a2 = a1      // 여기서는 보통 실제 복사 안 함
a2.append(4)     // 여기서 a2만 수정되므로 필요 시 복사 발생
```

면접에서 이렇게 말하면 좋아요:

> “Swift 컬렉션은 값 타입이라 참조 공유로 인한 부작용이 적고, 성능을 위해 COW로 최적화되어 수정 시점에만 복사한다.”

---

## 3) Collection / Sequence 프로토콜 관점(면접 플러스 점수)

Swift 표준 라이브러리는 “여러 타입을 공통 인터페이스로 묶기” 위해 프로토콜을 씁니다.

- `Sequence`: **for-in 순회 가능**, `map/filter/reduce` 등 사용 가능
    
- `Collection`: Sequence보다 강함
    
    - `startIndex`, `endIndex`, `index(after:)`
        
    - 서브스크립트 접근 가능
        
- `RandomAccessCollection`: 인덱스 이동이 빠름(대부분 Array)

즉,

- “순회만 필요”하면 Sequence 수준으로도 충분
    
- “인덱싱/슬라이싱/카운트/범위” 같은 컬렉션 기능을 기대하면 Collection

(실무에선 그냥 `Array` 쓰지만, 제네릭/라이브러리 만들 때 중요)

---

## 4) 언제 뭘 고르면 되나요? (한 줄 요약)

- **Array**: 순서가 중요 + 중복 가능 + 리스트/테이블
    
- **Dictionary**: 키로 빠른 조회가 필요(id→모델)
    
- **Set**: 중복 제거/포함 체크가 핵심(contains가 자주 호출됨)

---

## 5) 면접용 15초 답변 템플릿

“Swift의 대표 컬렉션은 Array, Dictionary, Set이 있고, Array는 순서가 있고 중복을 허용하며 인덱스로 접근합니다. Dictionary는 키-값 구조로 키 기반 조회가 평균적으로 빠르고, Set은 순서 없이 유일한 값만 저장해서 중복 제거와 contains가 빠릅니다. 이 컬렉션들은 값 타입이고 Copy-on-Write로 수정 시점에만 복사되어 성능과 안정성을 같이 챙깁니다.”