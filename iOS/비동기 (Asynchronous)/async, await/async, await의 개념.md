## 1. async/await는 언제 등장했나요?

Swift의 async/await는

- **Swift 5.5**
    
- **iOS 15 / macOS 12** (2021년 WWDC)

에서 **공식 Concurrency(동시성) 기능**으로 처음 등장했어요.

그 전까지는:

- `URLSession` + completion handler
    
- `DispatchQueue.global().async { ... }`
    
- RxSwift, Combine 같은 라이브러리

로 비동기를 처리했는데,  코드가 점점 **콜백 지옥**, **중첩 지옥**이 되기 쉽고, 에러 처리도 복잡했죠.

그래서:

> “동기 코드처럼 **위에서 아래로 읽히는 비동기 코드**를 짜게 해 주자”

라는 목표로 **async/await + Structured Concurrency**가 등장했다고 보면 됩니다.

---

## 2. async/await가 “뭐” 하는 건가요?

한 줄로 말하면:

> **비동기 작업을 동기 코드처럼 보이게 만드는 문법 + 런타임 시스템**

### 2-1. 문법 느낌 먼저 보기

### 기존 스타일 (completion handler)

```swift
func fetchUser(completion: @escaping (User?) -> Void) {
    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data else {
            completion(nil)
            return
        }
        let user = try? JSONDecoder().decode(User.self, from: data)
        completion(user)
    }.resume()
}
```

### async/await 스타일

```swift
func fetchUser() async throws -> User {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}
```

차이점:

- **completion 인자 사라짐**
    
- **return 타입 그대로 사용**
    
- 에러는 `throws`, 비동기 기다림은 `await`
    
- 위에서 아래로 읽히는 일반 함수처럼 생김

---

## 3. async / await 문법 기초

### 3-1. async 함수 선언

```swift
func fetchUser() async throws -> User {
    // 비동기 작업
}
```

- `async` : 이 함수는 **비동기적으로 실행**될 수 있다
    
- `throws` : 에러를 던질 수 있다
    
- `-> User` : 결국 `User`를 리턴한다

### 3-2. async 함수 호출

```swift
Task {
    do {
        let user = try await fetchUser()
        print(user.name)
    } catch {
        print("에러 발생: \(error)")
    }
}
```

- `await` : **비동기 결과를 기다리는 키워드**
    
- `Task { ... }` : 비동기 컨텍스트를 시작하는 “작업 단위”

> 핵심: `await`는 “여기서 잠깐 멈췄다가, 결과 나오면 다시 이어서 실행해줘” 라는 뜻

---

## 4. 기존 completion 스타일 → async/await로 바꾸기 예시

예를 들어, 기존에 이런 코드가 있다고 할게요.

```swift
func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data = data, let image = UIImage(data: data) else {
            completion(nil)
            return
        }
        completion(image)
    }.resume()
}
```

### async/await 버전

```swift
func loadImage(from url: URL) async -> UIImage? {
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    } catch {
        print("이미지 로드 실패: \(error)")
        return nil
    }
}
```

ViewController에서:

```swift
Task { [weak self] in
    guard let self else { return }
    self.imageView.image = await loadImage(from: url)
}
```

→ **콜백 중첩 없이**,  
→ `await` 한 줄로 **“기다렸다가 이어서 코드 실행”** 느낌.

---

## 5. 실무에서 async/await를 언제 쓰냐?

대략 이런 것들에 다 쓰입니다:

- **네트워크 통신** (REST API, 이미지 다운로드)
    
- **디스크 IO 작업** (파일 읽기/쓰기)
    
- **지연 작업** (`Task.sleep`, 타이머 등)
    
- **서버에서 여러 요청을 병렬로 보내고 합치기** (async let, TaskGroup)

예:

```swift
async let user = fetchUser()
async let posts = fetchPosts()

// 둘 다 끝날 때까지 기다렸다가
let (userResult, postsResult) = await (try user, try posts)
```

이런 식으로 **structured concurrency**도 가능해져요 (이건 나중에 깊게 해볼만한 주제).

---

## 6. 지금 단계에서 딱 알고 있으면 좋은 요약

1. **언제 등장했나?**  
    → Swift 5.5 / iOS 15 (2021 WWDC), Concurrency 첫 도입
    
2. **왜 나왔나?**  
    → completion handler, GCD 기반 비동기 코드가 너무 복잡해서  
    **동기처럼 읽히는 비동기 코드**를 만들기 위해
    
3. **어떻게 쓰나?**
    
    - 비동기 함수는 `async` / `async throws`
        
    - 호출할 때는 `await` + `try`
        
    - ViewController에서는 `Task { ... }` 안에서 사용