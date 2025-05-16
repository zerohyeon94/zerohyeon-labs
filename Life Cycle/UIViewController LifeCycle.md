# UIViewController 생명주기

## 💡 핵심 흐름 요약
1. init()
2. loadView()
3. viewDidLoad()
4. viewWillAppear()
5. viewDidAppear()
6. viewWillDisappear()
7. viewDidDisappear()
8. deinit()

## 🔧 언제 무엇을 쓰면 좋을까?
- `viewDidLoad`: UI 구성, 초기 데이터 설정
- `viewWillAppear`: 화면 갱신이 필요한 UI 처리
- `viewDidAppear`: 애니메이션, 트래킹 시작
- `deinit`: 메모리 정리, Notification 해제 등