## 1. `URLEncoding.default`와 `JSONEncoding(options: [])`의 차이

### 1) **URLEncoding.default**

- **GET/DELETE**:
    - 파라미터가 **쿼리스트링**(`?key1=value1&key2=value2`)으로 URL에 붙음
    - 예)
        ```pgsql
        GET /api/user?name=YeongHyeon&age=25
		```
        
- **POST/PUT**:
    - 파라미터가 **application/x-www-form-urlencoded** 형태로  
        **HTTP Body에 key=value&key2=value2** 포맷으로 들어감
    - 예)
        ```makefile
        Content-Type: application/x-www-form-urlencoded
		Body: name=YeongHyeon&age=25
		```
        
    - (특이: `.queryString` 옵션을 주면 POST도 URL 쿼리스트링에 붙일 수도 있음)
        

---

### 2) **JSONEncoding(options: [])**

- **모든 HTTP Method에서**
    - 파라미터가 **JSON 포맷**(`{"name":"YeongHyeon","age":25}`)으로  
        **HTTP Body**에 들어감
    - **Content-Type** 헤더가 `application/json`으로 자동 세팅됨
    - 예)
        
        ```swift
        Content-Type: application/json
		Body: {"name":"YeongHyeon","age":25}
		```
        

---

## 2. 실제 사용 예

```swift
// 1) URLEncoding
AF.request(
    url,
    method: .post,
    parameters: ["name": "홍길동", "age": 30],
    encoding: URLEncoding.default
)

// 2) JSONEncoding
AF.request(
    url,
    method: .post,
    parameters: ["name": "홍길동", "age": 30],
    encoding: JSONEncoding.default // == JSONEncoding(options: [])
)
```

---

## 3. 서버에서 인식하는 차이

- **URLEncoding** → PHP, ASP, Form 기반 서버 등에서 전통적으로 많이 사용
    
- **JSONEncoding** → REST API, Node.js, Python, 최신 서버에서 많이 사용

만약 서버가

- “Content-Type: application/json”을 요구 → JSONEncoding
    
- “Content-Type: application/x-www-form-urlencoded”를 요구 → URLEncoding

---

## 4. 실무/팁

- **API 명세서(스웨거, Postman 등)에서 Content-Type이 뭔지 확인하고 선택!**
    
- iOS/Android 협업/공통 API 개발 땐 JSONEncoding이 대세
    
- 예외: 결제, 인증 등 오래된 API는 URLEncoding 요구하는 경우 있음