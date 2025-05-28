## ✅ 1. **목표: CocoaPods 완전 제거**

### 1.1 다음 파일/폴더를 삭제하세요:

```bash
rm -rf Pods
rm -rf Podfile
rm -rf Podfile.lock
rm -rf *.xcworkspace
rm -rf Target\ Support\ Files/
```

---

### 1.2 `.xcodeproj` 열어서 CocoaPods 관련 설정 제거

1. `Build Phases` 탭에서 아래 항목 삭제:
    
    - **Check Pods Manifest.lock**
        
    - **[CP] Embed Pods Frameworks**
        
    - **[CP] Copy Pods Resources**
        
2. `Build Settings` → 다음 항목 확인 후 `Pods` 관련 내용 삭제:
    
    - **Framework Search Paths**
        
    - **Library Search Paths**
        
    - **Other Linker Flags** (예: `-framework "SomePod"`)

---

## ✅ 2. 의존성 수동 해결 방법

CocoaPods 없이도 의존성을 다음 중 하나로 처리할 수 있습니다:

---

### ✅ 방법 1: Swift Package Manager(SPM) 사용 (권장)

1. Xcode → File → **Add Packages...**
    
2. 사용하던 CocoaPod의 GitHub 주소 입력 (예: `https://github.com/Alamofire/Alamofire`)
    
3. 버전 조건 선택 후 → **Add Package**

> 대부분의 오픈소스 라이브러리는 SPM을 지원합니다.

---

### ✅ 방법 2: `.framework` 수동 추가

1. GitHub 등에서 `.xcframework` 또는 `.framework`를 직접 다운로드
    
2. `Xcode > Project > General > Frameworks, Libraries and Embedded Content`에 드래그 추가
    
3. `Build Phases` > `Link Binary With Libraries`에서 확인

---

### ✅ 방법 3: 소스코드 직접 포함 (단순 라이브러리일 경우)

- 예: MIT 라이선스 기반 라이브러리
    
- `Sources` 폴더에 `.swift` 파일 복사해서 직접 포함

---

## ✅ 정리

| 단계  | 설명                                                   |
| --- | ---------------------------------------------------- |
| 1   | CocoaPods 관련 모든 파일 삭제 (Pods, Podfile, xcworkspace 등) |
| 2   | Xcode에서 Pods 설정 제거 (Build Phases, Build Settings)    |
| 3   | SPM 또는 수동 `.framework`로 의존성 대체                       |
| 4   | CocoaPods 없이 `xcodeproj`로 빌드 확인                      |