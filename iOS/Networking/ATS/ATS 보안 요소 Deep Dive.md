## 1) TLS 1.2 (Transport Layer Security v1.2)

**개념**

- 인터넷에서 **통신을 암호화**하고 **위·변조를 방지**하는 표준 프로토콜의 버전.
    
- 핸드셰이크(서버 신원 확인) → 암호화된 데이터 교환 흐름으로 진행.
    
- TLS 1.2부터 **AES-GCM** 같은 최신 암호화/무결성 방식이 표준적으로 사용되고, 취약한 알고리즘(RC4, MD5 등)이 사실상 퇴출됨.
    
- TLS 1.3은 더 단순·안전·빠름(라운드트립 감소, 구식 스위트 제거) — 가능하면 1.3 권장, **최소 1.2 이상**은 필수(ATS 기준).

**왜 필요한가**

- 평문(HTTP)은 도청/변조가 가능. TLS는 **기밀성(암호화)**, **무결성(서명/태그)**, **서버 인증**을 제공.

**iOS 개발자 관점**

- **ATS는 기본적으로 TLS 1.2+를 요구**. 서버가 낮은 버전만 지원하거나 취약 스위트만 켜져 있으면 `-1022` 오류.
    
- 앱에서 예외를 열기 전에 **서버를 TLS 1.2+/1.3으로 올리는 게 정석**.

**확인 방법**

`/usr/bin/nscurl --ats-diagnostics https://api.example.com # 결과에 TLS 버전/암호 스위트 호환 여부가 표시됨`

---

## 2) Forward Secrecy (FS, 순방향 보안; 흔히 PFS)

**개념**

- 과거의 세션 키가 **서버 장기 비밀키 유출**로도 복호화되지 않도록 보장하는 성질.
    
- 구현 방식: **(EC)DHE** 계열의 _에페메럴(ephemeral) Diffie-Hellman_ 키 교환을 사용해 **세션마다 일회성 키**를 생성.
    
    - 예: `ECDHE_ECDSA`, `ECDHE_RSA`처럼 **ECDHE**가 들어간 스위트.

**왜 필요한가**

- 나중에 서버 개인키가 털려도, 과거 트래픽을 저장해 둔 공격자가 **예전 통신을 복호화하지 못함** → 개인정보/의료 데이터 등 민감 정보 보호에 매우 중요.

**iOS 개발자 관점**

- ATS는 **FS 지원을 사실상 기대**함. 서버/로드밸런서에서 **ECDHE**를 우선 활성화하도록 요청.
    
- 면접 한 줄: “우리는 `ECDHE_*` 스위트를 기본으로 쓰고, 과거 세션 보호를 위해 FS를 강제합니다.”

**확인 방법**

`/usr/bin/openssl s_client -connect api.example.com:443 -tls1_2 # ...Cipher    : TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256  ← ECDHE가 보이면 FS`

---

## 3) SHA-256 (서명/해시 알고리즘)

**개념**

- **해시 함수**이자 **인증서 서명 알고리즘의 해시 파트**로 흔히 쓰임(예: `sha256WithRSAEncryption`, `ecdsa-with-SHA256`).
    
- “인증서가 SHA-256 이상으로 서명” → 루트/중간 CA가 서버 인증서를 **SHA-256 계열**로 서명했다는 뜻(구식 SHA-1은 거부·감점).
    

**왜 필요한가**

- **서명 위조/충돌** 위험이 낮아 신뢰 체인을 안전하게 유지.
    

**iOS 개발자 관점**

- 인증서 체인에서 **Signature Algorithm**이 SHA-256 이상인지 확인. SHA-1 체인은 심사/클라이언트 정책에서 거부될 수 있음.
    

**확인 방법**

`/usr/bin/openssl s_client -connect api.example.com:443 -showcerts </dev/null \ | openssl x509 -text -noout | grep "Signature Algorithm" # Signature Algorithm: sha256WithRSAEncryption  또는 ecdsa-with-SHA256`

---

## 4) RSA 2048bit / EC 256bit+ (서버 인증서의 공개키 유형과 키 길이)

**개념**

- **서버 인증서의 ‘공개키’ 타입**
    
    - **RSA 2048bit**: 가장 널리 쓰이는 타입. 충분히 안전한 최소 권장 길이.
        
    - **EC 256bit (P-256, secp256r1)**: 타원곡선(ECDSA) 기반. **동급 보안에 더 짧은 키**, 일반적으로 **서명 연산이 빠름**(모바일 친화).
        
- 보안 등가성 대략: **RSA 2048 ≈ ECDSA P-256** (실무 감각)
    

**왜 필요한가**

- **서버 신원 인증**에 쓰이는 공개키/서명 체계. 충분한 키 길이는 **위조·브루트포스** 방어에 필수.
    

**iOS 개발자 관점**

- 서버 인증서의 **Public Key**가 RSA(2048+) 또는 EC(P-256 이상)인지 확인.
    
- 모범 조합 예:
    
    - `ECDHE_ECDSA_WITH_AES_128_GCM_SHA256` (TLS1.2)
        
    - `TLS_AES_128_GCM_SHA256` 또는 `TLS_CHACHA20_POLY1305_SHA256` (TLS1.3)
        
- ECDSA 인증서를 쓴다면 **클라이언트(옛 단말) 호환성**도 고려.
    

**확인 방법**

`/usr/bin/openssl s_client -connect api.example.com:443 -showcerts </dev/null \ | openssl x509 -text -noout | grep -E "Public Key Algorithm|Public-Key" # Public Key Algorithm: id-ecPublicKey (EC)  또는  rsaEncryption (RSA 2048)`

---

## 5) 요소 간 관계 요약

|요소|역할|실무에서 어떻게 보이나|
|---|---|---|
|**TLS 1.2+**|통신 암호화 프로토콜 버전|nscurl/openssl 출력에 **Protocol: TLS 1.2/1.3**|
|**Forward Secrecy(ECDHE)**|과거 세션 보호|**Cipher** 이름에 **ECDHE** 포함|
|**SHA-256**|인증서/서명 해시|인증서의 **Signature Algorithm: …SHA256…**|
|**RSA 2048 / EC 256+**|인증서의 공개키 유형/강도|인증서의 **Public Key Algorithm**과 **키 길이**|

---

> [[iOS 학습 인덱스]]