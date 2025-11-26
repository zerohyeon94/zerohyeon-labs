## 1. 이전 completion 코드와 무엇이 달라졌는지 포인트 정리

### 1-1. `loadImage(from:completion:)` → `loadImage(from:) async throws -> UIImage`

**Before (대략 이런 형태였을 것):**

```swift
func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    URLSession.shared.dataTask(with: url) { data, _, error in
        DispatchQueue.main.async {
            if let data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }.resume()
}
```

**After:**

```swift
private func loadImage(from url: URL) async throws -> UIImage {
    let (data, _) = try await URLSession.shared.data(from: url)
    guard let image = UIImage(data: data) else {
        throw ImageLoadError.invalidData
    }
    return image
}
```

차이:

- `completion` 클로저가 사라지고, 그냥 **리턴값**으로 `UIImage`를 반환
    
- 에러는 `throws`로 던져서 위에서 `do/try/catch`로 처리
    
- `DispatchQueue.main.async` 같은 것도 거의 안 보임  
    → `@MainActor` 덕분에 UI 코드는 자연스럽게 main thread에서 실행

---

### 3-2. 호출부도 훨씬 깔끔해짐

**Before:**

```swift
startLoading()
loadImage(from: url) { [weak self] image in
    guard let self else { return }
    self.stopLoading()
    if let image {
        self.showImageWithFadeIn(image)
    } else {
        self.showError(...)
    }
}
```

**After:**

```swift
Task { [weak self] in
    guard let self else { return }

    do {
        let image = try await self.loadImage(from: url)
        self.showImageWithFadeIn(image)
    } catch {
        self.showErrorAlert(error: error)
    }

    self.stopLoading()
}
```

- 흐름을 “위에서 아래로 읽을 수 있는” 형태로 바꿔 줌
    
- 비동기 + 에러 처리가 훨씬 자연스럽고 테스트도 쉬움