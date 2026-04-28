## 1. 리팩토링 핵심 포인트 정리

### 1) APIService: completion → async/await

**Before (completion 버전 느낌):**

```swift
func fetchUserProfile(userID: String, token: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
    URLSession.shared.dataTask(with: request) { data, response, error in
        ...
        completion(.success(profile))
    }.resume()
}
```

**After (async/await 버전):**

```swift
func fetchUserProfile(userID: String, token: String) async throws -> UserProfile {
    let (data, response) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(UserProfile.self, from: data)
}
```

- `completion` 없어지고
    
- **결과는 `return`, 에러는 `throws`** 로 자연스럽게 처리

---

### 2) ViewModel: `loadUser(id:) async`

```swift
@MainActor
final class UserViewModel {
    private(set) var userName: String?
    private(set) var userEmail: String?
    private let authToken: String = "top_secret_token_1234"

    func loadUser(id: String) async {
        do {
            let user = try await APIService.shared.fetchUserProfile(userID: id, token: authToken)
            self.userName = user.name
            self.userEmail = user.email
        } catch {
            self.userName = nil
            self.userEmail = nil
        }
    }
}
```

- ViewModel은 **UI에서 쓰이는 상태만 관리**
    
- 네트워크 로직은 그대로 `APIService`에게 맡김
    
- `@MainActor` 덕분에 ViewModel 안에서 UI 바인딩용 프로퍼티를 바로 수정해도 안전

---

### 3) ViewController: Task + await

```swift
private func loadUser() {
    Task { [weak self] in
        guard let self else { return }

        await self.viewModel.loadUser(id: "user123")
        self.updateUI()
    }
}
```

- **비동기 작업을 시작할 “컨테이너”로 `Task {}` 사용**
    
- 안쪽에서는 `await`로 비동기 함수 호출
    
- `updateUI()`는 비동기 작업이 끝난 뒤에만 실행됨 → 흐름이 자연스럽고 이해하기 쉽다

---

> [[iOS 학습 인덱스]]