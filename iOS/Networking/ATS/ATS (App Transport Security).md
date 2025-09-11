## 1) 목적과 기본 개념

ATS는 iOS/macOS에서 **HTTP 기반 네트워킹을 기본적으로 HTTPS(TLS)** 로 강제해 **기밀성(암호화)** 과 **무결성(변조 방지)** 을 보장하는 정책입니다. 앱이 `URLSession`으로 외부 서버에 접속할 때 기본적으로 ATS 규칙을 따릅니다. [Apple Developer](https://developer.apple.com/documentation/security/preventing-insecure-network-connections?utm_source=chatgpt.com)

- **핵심 요건(요지)**
    - 서버는 **TLS 1.2 이상**과 **Forward Secrecy(순방향 보안)** 를 지원해야 함
    - 인증서는 유효하며 **SHA-256 이상**으로 서명되고 **RSA 2048bit 또는 EC 256bit+** 권장
    - 이 기준을 충족하지 못하면 ATS가 연결을 차단(대표 에러: **-1022**)합니다. [애플 지원+1](https://support.apple.com/guide/security/tls-security-sec100a75d12/web?utm_source=chatgpt.com)

---

## 2) 적용 범위와 기본 동작

- **네이티브 네트워킹**: `URLSession`/`NSURLConnection` 호출은 ATS 대상입니다.
- **웹뷰(WKWebView)**: 기본적으로 ATS 대상이지만, 필요 시 **웹뷰 트래픽에 한해** 완화할 수 있습니다(`NSAllowsArbitraryLoadsInWebContent`). 네이티브 요청에는 영향이 없습니다. [Apple Developer](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAppTransportSecurity/NSAllowsArbitraryLoadsInWebContent?utm_source=chatgpt.com)
    

> 애플은 **“서버를 고치는 것”** 을 1순위로 권장합니다. 예외(완화)는 **최소 범위**에서만 사용하고, 장기적으로 제거하는 것이 이상적입니다. [Apple Developer](https://developer.apple.com/news/?id=jxky8h89&utm_source=chatgpt.com)

---

## 3) 실패 증상과 1차 진단

- 런타임 메시지 예:  
    `The resource could not be loaded because the App Transport Security policy requires the use of a secure connection.`  
    `NSURLErrorDomain Code=-1022`
    
- 원인 예: HTTP 사용, TLS 버전/암호군 미달, 만료/약한 인증서, 리다이렉트가 HTTP로 떨어짐 등.

**진단 툴:**

`/usr/bin/nscurl --ats-diagnostics https://your.api.example`

- 서버가 ATS와 호환되는지 **여러 조합으로 자동 테스트**합니다. 어떤 항목에서 FAIL 나는지 보고 예외가 필요한지/서버를 고쳐야 하는지 결정합니다. `--verbose` 로 상세 로그 확인 가능. [Apple Developer+1](https://developer.apple.com/documentation/security/identifying-the-source-of-blocked-connections?utm_source=chatgpt.com)

---

## 4) Info.plist 설정(예외는 “최소 범위” 원칙)

루트 키: `NSAppTransportSecurity` (Dictionary). 주요 하위 키와 의미는 다음과 같습니다. [Apple Developer](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity?utm_source=chatgpt.com)

### (A) 전역 허용 — **지양**

`<key>NSAppTransportSecurity</key> <dict>   <key>NSAllowsArbitraryLoads</key><true/> </dict>`

- 앱 **전체**의 ATS를 꺼버립니다. 리뷰/보안 리스크가 크므로 권장되지 않습니다. [Apple Developer](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAppTransportSecurity/NSAllowsArbitraryLoads?utm_source=chatgpt.com)

### (B) **웹뷰에만** 허용

`<key>NSAppTransportSecurity</key> <dict>   <key>NSAllowsArbitraryLoadsInWebContent</key><true/> </dict>`

- **WKWebView 내 요청만** ATS 완화. 네이티브 `URLSession`에는 영향을 주지 않습니다. [Apple Developer](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAppTransportSecurity/NSAllowsArbitraryLoadsInWebContent?utm_source=chatgpt.com)

### (C) **로컬 네트워킹**(사설망/IP/.local)

`<key>NSAppTransportSecurity</key> <dict>   <key>NSAllowsLocalNetworking</key><true/> </dict>`

- **IP 주소, .local, 정규화되지 않은 호스트** 등 로컬 통신 허용 범위를 제어합니다(개발용 장비, IoT 디바이스 등). [Apple Developer](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity/nsallowslocalnetworking?utm_source=chatgpt.com)

### (D) **도메인별 예외(권장되는 완화 방식)**

`<key>NSAppTransportSecurity</key> <dict>   <key>NSExceptionDomains</key>   <dict>     <key>example.com</key>     <dict>       <key>NSIncludesSubdomains</key><true/>       <key>NSExceptionAllowsInsecureHTTPLoads</key><true/>  <!-- 해당 도메인에 한해 HTTP 허용 -->       <!-- 필요 시(권장X): 최소 TLS 버전 완화, PFS 완화 -->       <!-- <key>NSExceptionMinimumTLSVersion</key><string>TLSv1.0</string> -->       <!-- <key>NSExceptionRequiresForwardSecrecy</key><false/> -->     </dict>   </dict> </dict>`

- **특정 도메인**에만 예외를 적용합니다.
    
- **주의:** 도메인 예외는 **DNS 이름**에 적용됩니다. 앱이 **IP 주소로** 접속하면 예외가 적용되지 않을 수 있으며, 이런 케이스는 `NSAllowsLocalNetworking` 범주에 해당합니다. [Apple Developer](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAppTransportSecurity/NSExceptionDomains?utm_source=chatgpt.com)

---

## 5) TLS 요구사항(요지)

- **TLS 1.2 이상**(가능하면 1.3)
    
- **Forward Secrecy** 지원(필요 시 도메인별로 완화 가능하지만 권장 X)
    
- 인증서: **유효/신뢰 체인 완성/적정 키 길이**, **SHA-256 이상** 서명  
    이 기준은 **서버측 구성** 문제이므로, 앱에서 예외를 추가하는 대신 **서버 설정을 업데이트** 하는 것이 정석입니다. [애플 지원](https://support.apple.com/guide/security/tls-security-sec100a75d12/web?utm_source=chatgpt.com)
    

---

## 6) 의사결정 플로우 (실무 체크리스트)

1. **HTTPS 가능한가?** → 가능하면 **바로 전환**(서버 인증서/체인/TLS 설정 점검). [Apple Developer](https://developer.apple.com/news/?id=jxky8h89&utm_source=chatgpt.com)
    
2. **HTTPS 불가 도메인이 꼭 필요한가?** → 그렇다면 **도메인별 예외**로 **임시 완화** 후 제거 계획 수립. [Apple Developer](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity?utm_source=chatgpt.com)
    
3. **웹뷰 콘텐츠만 문제인가?** → `NSAllowsArbitraryLoadsInWebContent` 고려(네이티브엔 미적용). [Apple Developer](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAppTransportSecurity/NSAllowsArbitraryLoadsInWebContent?utm_source=chatgpt.com)
    
4. **로컬 장비/IP 접속인가?** → `NSAllowsLocalNetworking` 검토. [Apple Developer](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity/nsallowslocalnetworking?utm_source=chatgpt.com)
    
5. **정확한 원인 파악** → `nscurl --ats-diagnostics`로 서버 호환성 검사. [Apple Developer](https://developer.apple.com/documentation/security/identifying-the-source-of-blocked-connections?utm_source=chatgpt.com)
    

---

## 7) 흔한 함정(Pitfalls)

- **리다이렉트가 HTTP로 떨어짐**: 최종 URL만 HTTPS여도 중간 단계에서 **HTTP** 로 떨어지면 차단될 수 있습니다.
    
- **CDN/이미지 호스트가 HTTP**: 라이브러리(Nuke 등)가 HTTP URL을 받으면 실패(-1022).
    
- **IP 접속**: 도메인 예외가 적용되지 않을 수 있음 → `NSAllowsLocalNetworking` 사용 고려. [Apple Developer](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAppTransportSecurity/NSExceptionDomains?utm_source=chatgpt.com)
    
- **자체서명/만료 인증서**: ATS 차단. 서버 인증서 갱신/체인 수정 필요.
    
- **전역 끄기(NSAllowsArbitraryLoads)**: 심사에서 지적/거절 가능성 + 보안 리스크. [Apple Developer](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAppTransportSecurity/NSAllowsArbitraryLoads?utm_source=chatgpt.com)
    

---

## 8) 면접 답변 예시(디테일 버전, 40초)

> “**ATS는 iOS의 HTTPS 강제 정책**이라 `URLSession`은 기본적으로 TLS 1.2+와 유효 인증서를 요구합니다. 저는 우선 서버를 TLS 1.2/1.3, PFS, SHA-256 이상으로 맞추고, 불가피할 때만 `NSExceptionDomains`로 **도메인 단위 예외**를 씁니다. **웹뷰만** 예외가 필요하면 `NSAllowsArbitraryLoadsInWebContent`, **로컬/IP 통신**이면 `NSAllowsLocalNetworking`을 검토합니다. 문제 재현 시 `nscurl --ats-diagnostics`로 구체 원인을 확인해 예외를 최소화합니다.” [Apple Developer+4Apple Developer+4애플 지원+4](https://developer.apple.com/documentation/security/preventing-insecure-network-connections?utm_source=chatgpt.com)

---

## 9) 빠른 참고(공식 문서)

- **NSAppTransportSecurity 개요 & 키 레퍼런스**(Info.plist) [Apple Developer](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity?utm_source=chatgpt.com)
    
- **Preventing Insecure Network Connections**(ATS 개요/가이드) [Apple Developer](https://developer.apple.com/documentation/security/preventing-insecure-network-connections?utm_source=chatgpt.com)
    
- **NSAllowsLocalNetworking** 상세 설명 [Apple Developer](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity/nsallowslocalnetworking?utm_source=chatgpt.com)
    
- **웹뷰 전용 예외(NSAllowsArbitraryLoadsInWebContent)** [Apple Developer](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAppTransportSecurity/NSAllowsArbitraryLoadsInWebContent?utm_source=chatgpt.com)
    
- **도메인별 예외(NSExceptionDomains) & IP 주의사항** [Apple Developer](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAppTransportSecurity/NSExceptionDomains?utm_source=chatgpt.com)
    
- **애플 보안 문서 — TLS 요구사항**(TLS 1.2+, PFS, 인증서) [애플 지원](https://support.apple.com/guide/security/tls-security-sec100a75d12/web?utm_source=chatgpt.com)
    
- **News: Fine-tune your ATS settings**(예외 최소화 권고) [Apple Developer](https://developer.apple.com/news/?id=jxky8h89&utm_source=chatgpt.com)

---

## 10) 스니펫(재사용)

- **도메인별 예외**: `NSExceptionDomains` (필요한 도메인만, 임시) [Apple Developer](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity?utm_source=chatgpt.com)
    
- **웹뷰 전용 완화**: `NSAllowsArbitraryLoadsInWebContent` [Apple Developer](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAppTransportSecurity/NSAllowsArbitraryLoadsInWebContent?utm_source=chatgpt.com)
    
- **로컬 네트워킹 허용**: `NSAllowsLocalNetworking` [Apple Developer](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity/nsallowslocalnetworking?utm_source=chatgpt.com)
    
- **진단**: `/usr/bin/nscurl --ats-diagnostics <URL>` [Apple Developer](https://developer.apple.com/documentation/security/identifying-the-source-of-blocked-connections?utm_source=chatgpt.com)