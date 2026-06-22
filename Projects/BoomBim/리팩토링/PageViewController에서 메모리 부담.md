`UIPageViewController`는 컨테이너라서 **현재 페이지 + 양옆(최대 2개) 뷰컨**을 동시에 붙여 두는 경우가 많아요(스크롤 방식). 여기에 당신이 **모든 페이지의 VC를 배열로 강하게 보관**하거나, 각 VC가 **큰 이미지/데이터를 오래 쥐고** 있으면 메모리 부담이 커집니다. 테이블처럼 “셀 재사용”이 자동으로 되지 않는 것도 한몫합니다.

# 왜 메모리가 불어날까?

- **미리 로드**: `transitionStyle = .scroll`일 때 내부적으로 옆 페이지를 선로딩(보통 좌/우 각 1개).
    
- **개발자 보관**: `pages: [UIViewController]` 식으로 100개를 전부 강참조.
    
- **무거운 리소스**: 큰 이미지(원본 크기로 디코딩), 대형 모델, Player 등.
    
- **순환 참조**: 자식 VC → 상위/뷰모델을 강하게 캡처.

# 메모리 친화 베스트 프랙티스

1. **온디맨드 생성 + 작은 캐시**
    
    ```swift
	final class Pager: UIPageViewController {
	  private let cache = NSCache<NSNumber, UIViewController>() // 용량/개수 제한
	  func vc(at idx: Int) -> UIViewController {
	    if let vc = cache.object(forKey: NSNumber(value: idx)) { return vc }
	    let vc = makeVC(for: idx) // 가볍게 생성
	    cache.setObject(vc, forKey: NSNumber(value: idx))
	    return vc
	  }
	}
    ```
    
    - 데이터소스의 `viewControllerBefore/After`에서 **필요할 때만 생성**하세요.
        
    - 캐시는 3~5개 정도면 충분(현재+양옆+여분).
        
2. **무거운 것은 뷰 수명에 맞춰 풀기**
    
    - `viewDidDisappear`에서 이미지/오디오/대용량 객체를 해제 또는 다운샘플링.
        
    - 큰 이미지는 **다운샘플링**해서 표시(원본 그대로 디코딩 금지).
        
3. **강한 참조 고리 끊기**
    
    - 델리게이트/클로저는 `[weak self]` 사용.
        
    - 자식 VC가 상위를 강하게 들고 있지 않게 설계.
        
4. **양옆 프리로드만 믿고 전체 보관 금지**
    
    - “인덱스 → 데이터”만 보관, **VC 자체 배열 보관은 지양**.
        
5. **전환 콜백에서 정리**
    
	```swift
	func pageViewController(_ pvc: UIPageViewController,
	                        didFinishAnimating finished: Bool,
	                        previousViewControllers: [UIViewController],
	                        transitionCompleted completed: Bool) {
	  if completed {
	    // 멀어진 VC라면 무거운 리소스 해제
	  }
	}
	```
    
6. **진단**
    
    - Xcode Memory Graph로 `_UIQueuingScrollView` 아래 자식 VC가 몇 개 살아있는지 확인.
        
    - Instruments → Allocations/Leaks로 이미지 디코딩/누수 체크.
        

# 요약

- `UIPageViewController` 자체가 메모리 몬스터는 아니지만, **자식 VC를 많이/무겁게 보관**하면 바로 부담됩니다.
    
- **온디맨드 생성 + 소형 캐시 + 무거운 리소스의 수명 관리**가 핵심입니다.
    
- 테이블처럼 자동 재사용이 없다는 점을 전제로, **개발자가 “얼마나 들고 있을지” 직접 설계**하세요.

---

> [[Home]]