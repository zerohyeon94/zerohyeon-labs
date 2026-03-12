이해를 돕기 위해, 면접 질문을 플래시카드처럼 넘기면서 공부하는 **'면접 카드 앱'**을 만든다고 가정해 보겠습니다.

- **메인 화면 (UIKit):** 카드를 좌우로 스와이프하는 복잡한 제스처나 애니메이션을 세밀하게 제어하기 위해 `UIKit`으로 구현했습니다.
    
- **카드 추가/수정 화면 (SwiftUI):** 텍스트 필드와 토글 버튼 등 폼(Form) 형태의 UI를 빠르고 선언적으로 그리기 위해 `SwiftUI`로 구현했습니다.

이때, SwiftUI 화면에서 새로운 면접 카드를 추가했을 때 UIKit으로 만들어진 메인 화면의 카드 덱이 어떻게 '자동으로' 업데이트되는지, 반응형 프로그래밍(Combine)을 활용한 데이터 흐름을 살펴보겠습니다.

---

### 1. 공통의 뇌(ViewModel) 만들기

먼저, 두 화면이 공유할 상태(데이터)를 관리하는 단일 출처(Single Source of Truth)를 만듭니다. 이를 보통 ViewModel이라고 부릅니다.

여기서는 Combine의 `@Published`를 사용해 데이터 스트림을 생성합니다.

```Swift
import Combine
import Foundation

class CardViewModel: ObservableObject {
    // 카드가 추가되거나 변경될 때마다 이벤트를 방출(Push)하는 데이터 스트림
    @Published var cards: [String] = ["CS 지식", "SwiftUI 상태관리"]
    
    func addCard(newCard: String) {
        cards.append(newCard)
    }
}
```

### 2. 데이터 생산자: SwiftUI (상태 변경하기)

SwiftUI 화면은 이 ViewModel을 넘겨받아 사용합니다. 사용자가 새 카드를 입력하고 '추가' 버튼을 누르면, 단순히 ViewModel의 함수를 호출하여 데이터를 변경합니다.

```Swift
import SwiftUI

struct AddCardView: View {
    @ObservedObject var viewModel: CardViewModel
    @State private var newCardText: String = ""
    
    var body: some View {
        VStack {
            TextField("새로운 면접 질문", text: $newCardText)
            Button("추가하기") {
                // ViewModel의 상태를 변경! -> 자동으로 이벤트가 방출됨
                viewModel.addCard(newCard: newCardText) 
            }
        }
    }
}
```

### 3. 데이터 소비자: UIKit (반응하여 화면 갱신하기)

UIKit으로 만들어진 메인 뷰 컨트롤러 역시 동일한 ViewModel 인스턴스를 가지고 있습니다. 여기서 핵심은 **UIKit 화면이 ViewModel의 `cards` 배열을 '구독(Subscribe)'하고 있다는 점**입니다.

```Swift
import UIKit
import Combine

class MainCardViewController: UIViewController {
    var viewModel: CardViewModel!
    private var cancellables = Set<AnyCancellable>() // 구독 관리 객체
    
    let cardCountLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func bindViewModel() {
        // ViewModel의 cards 배열에 변화가 생길 때마다 자동으로 이 블록이 실행됨
        viewModel.$cards
            .receive(on: RunLoop.main) // UI 업데이트는 메인 스레드에서
            .sink { [weak self] updatedCards in
                // 데이터가 밀려들어오면(Push), 화면을 다시 그린다!
                self?.cardCountLabel.text = "총 카드 수: \(updatedCards.count)"
                self?.updateCardDeckUI() 
            }
            .store(in: &cancellables)
    }
}
```

---

### 요약: 완벽한 분리와 반응

이 아키텍처의 가장 큰 장점은 **서로를 전혀 모른다**는 것입니다.

1. SwiftUI 뷰는 그저 ViewModel의 값을 바꿀 뿐, UIKit 뷰가 존재하는지조차 모릅니다.
    
2. UIKit 뷰 역시 SwiftUI 뷰가 언제 어떻게 값을 바꿨는지 신경 쓰지 않습니다. 그저 파이프라인(Combine)을 통해 "데이터가 바뀌었어!"라는 신호가 오면 자신의 UI를 갱신할 뿐입니다.
    

이렇게 중간에 데이터 스트림을 두고 통신하게 만들면, 어떤 프레임워크를 섞어 쓰더라도 스파게티 코드 없이 깔끔하게 앱을 확장해 나갈 수 있습니다.