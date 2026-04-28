## 1. Codable, Decodable, Encodable 개념

### **1) Encodable**

- Swift 객체 → JSON (혹은 다른 형식)으로 **인코딩(Encoding)**
    
- 즉, 내가 만든 모델을 **데이터로 변환할 때** 필요
    
- 예: POST 요청에서 JSON body 보낼 때

```swift
struct User: Encodable {
    let name: String
    let age: Int
}

let user = User(name: "Heebo", age: 30)
let jsonData = try JSONEncoder().encode(user)
// jsonData = {"name":"Heebo","age":30}
```

---

### **2) Decodable**

- JSON (혹은 다른 형식) → Swift 객체로 **디코딩(Decoding)**
    
- 즉, 서버 응답(JSON)을 **내 모델로 변환할 때** 필요
    
- 예: GET 응답을 User 객체로 변환
    

```swift
struct User: Decodable {
    let name: String
    let age: Int
}

let json = """
{ "name": "Heebo", "age": 30 }
""".data(using: .utf8)!

let user = try JSONDecoder().decode(User.self, from: json)
print(user.name) // Heebo
```

---

### **3) Codable**

- 사실 `Codable = Decodable & Encodable`
    
- 양방향(Encode + Decode) 모두 지원하는 타입
    
- 대부분의 경우 **Codable**만 쓰면 충분

```swift
struct User: Codable {
    let name: String
    let age: Int
}
```

---

## 2. iOS에서 언제 쓰나요?

- **서버 응답(JSON → Model)** → `Decodable` or `Codable`
- **서버 요청(Model → JSON)** → `Encodable` or `Codable`
- **둘 다 필요** → `Codable`

---

## 3. 정리

|프로토콜|용도|예시 상황|
|---|---|---|
|**Encodable**|Swift 객체 → JSON 변환 (인코딩)|POST 요청 body 만들 때|
|**Decodable**|JSON → Swift 객체 변환 (디코딩)|GET 응답 파싱|
|**Codable**|Encodable + Decodable (양방향)|대부분 경우(모델 정의 시 기본 사용)|

---

👉 정리하면:

- **Encodable = Encode(보내기)**
- **Decodable = Decode(받기)**
- **Codable = 둘 다**

---

# 실무에서 사용되는 상황

## 1. **서버 응답(JSON → Swift 모델)**

👉 **`Decodable`** 사용

- 서버에서 내려주는 JSON을 파싱해서 Swift 구조체/클래스로 변환할 때 필요합니다.
    
- 예: GET `/users/1` 요청 후, 유저 정보를 모델로 변환
```swift
struct User: Decodable {
    let id: Int
    let name: String
}

let data = response.data
let user = try JSONDecoder().decode(User.self, from: data)
```

✅ **실무에서 가장 자주 씀** (API 응답 처리)

---

## 2. **서버 요청(Swift 모델 → JSON Body)**

👉 **`Encodable`** 사용

- 서버에 보낼 body를 Swift 객체에서 JSON으로 인코딩할 때 필요합니다.
    
- 예: POST `/login` 요청 시, 아이디/비밀번호를 JSON body로 전송
```swift
struct LoginRequest: Encodable {
    let username: String
    let password: String
}

let login = LoginRequest(username: "test", password: "1234")
let body = try JSONEncoder().encode(login)
```

✅ **POST/PUT/PATCH 요청에서 주로 사용**

---

## 3. **요청 + 응답을 모두 모델로 다루고 싶을 때**

👉 **`Codable` (Encodable + Decodable)**

- 같은 모델이 **요청에도 쓰이고, 응답에도 쓰일 때**는 Codable을 쓰면 편리합니다.
    
- 예: 회원가입 요청 → 같은 모델이 서버 응답에도 포함되는 경우
```swift
struct User: Codable {
    let id: Int?
    let name: String
    let email: String
}
```

✅ **요청/응답 겸용 모델은 보통 Codable로 선언**

---

## 4. **실무에서의 사용 패턴 정리**

|상황|보통 쓰는 프로토콜|이유|
|---|---|---|
|GET 응답 파싱 (JSON → Model)|`Decodable`|서버 응답만 파싱|
|POST/PUT/PATCH 요청 (Model → JSON)|`Encodable`|요청 body 전송|
|요청/응답 둘 다 같은 모델 쓸 때|`Codable`|양방향 필요|
|파일 업로드/다운로드 (멀티파트 등)|보통 직접 Data 다룸, Codable 잘 안 씀|바이너리 처리|

---

## 5. **실무 예시**

- **회원가입 API**
    - Request: `Encodable` (`SignupRequest`)
    - Response: `Decodable` (`SignupResponse`)
- **프로필 수정 API (요청/응답 구조 동일)**
    - Request/Response 둘 다 `User: Codable`
- **로그인 토큰 요청 (Form URL-encoded)**
    - Encodable 대신 `URLQueryItem` 직접 사용 → JSON 아닌 케이스

---
## 📌 예시 1: 로그인 요청 & 응답

### 서버 API 사양

- **POST /login**
    
- Request body (JSON):
```json
{
  "username": "test",
  "password": "1234"
}
```

- Response body (JSON):
```json
{
  "accessToken": "abc.def.ghi",
  "refreshToken": "jkl.mno.pqr"
}
```

---

### Swift 모델 정의
```swift
// 요청 전용 모델 → Encodable
struct LoginRequest: Encodable {
    let username: String
    let password: String
}

// 응답 전용 모델 → Decodable
struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
```

---

### 사용 예시

```swift
// 1) 요청 만들기
let request = LoginRequest(username: "test", password: "1234")
let body = try JSONEncoder().encode(request)

// 2) 응답 파싱
let responseData: Data = ... // 서버 응답
let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: responseData)

print(loginResponse.accessToken) // "abc.def.ghi"

```

👉 요청은 `Encodable`, 응답은 `Decodable`만 구현하면 됩니다.

---

## 📌 예시 2: 회원가입 (요청과 응답이 같은 구조)

### 서버 API 사양

- **POST /signup**
    
- Request body (JSON):
```json
{
  "id": 1,
  "name": "Heebo",
  "email": "heebo@example.com"
}
```

- Response body (JSON):
```json
{
  "id": 1,
  "name": "Heebo",
  "email": "heebo@example.com"
}
```

---

### Swift 모델 정의

```swift
// 요청/응답 구조가 동일하므로 Codable 사용
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}
```

---

### 사용 예시

```swift
// 1) 요청 만들기
let newUser = User(id: 1, name: "Heebo", email: "heebo@example.com")
let body = try JSONEncoder().encode(newUser)

// 2) 응답 파싱
let responseData: Data = ... // 서버 응답
let createdUser = try JSONDecoder().decode(User.self, from: responseData)

print(createdUser.name) // "Heebo"
```

👉 요청과 응답 모두 `User`를 그대로 사용 가능 → `Codable`이 편리

---

## ✅ 정리

- **로그인 API (요청/응답 구조 다름)**
    - 요청 모델 = `Encodable`  
    - 응답 모델 = `Decodable` 
- **회원가입 API (요청/응답 구조 동일)**
    - 하나의 모델을 `Codable`로 정의해 양쪽 다 사용

---

> [[iOS 학습 인덱스]]