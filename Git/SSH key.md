## ✅ 최종 목표

> GitHub에 패스워드 없이 `git push`, `git pull` 가능하게 만들기

---

## 📦 1단계: SSH 키 생성 (없으면 새로 만들기)

```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

- 생성 경로는 기본적으로 `~/.ssh/id_rsa` (개인키)와 `id_rsa.pub` (공개키)
- Enter 눌러서 기본 경로로 진행
- Passphrase는 설정해도 되고 안 해도 됩니다 (입력 안 해도 됨)

```
Generating public/private rsa key pair. 
Enter file in which to save the key (/Users/yourname/.ssh/id_rsa): [Enter] 
Enter passphrase (empty for no passphrase): [Enter]
```

---

## 🔑 2단계: 공개키 GitHub에 등록

```
cat ~/.ssh/id_rsa.pub
```
- 복사해서 GitHub에 등록:

📍 GitHub 접속 →  Settings → SSH and GPG keys →  "New SSH Key" 클릭 → 붙여넣고 저장

---

## 🧭 3단계: GitHub 원격 주소 SSH 방식으로 변경

HTTPS로 되어 있으면 비밀번호 입력이 계속 필요합니다. → SSH 방식으로 변경합니다.

```
# 기존 원격 주소 확인 
git remote -v  

# 원격 주소를 SSH 방식으로 변경 
git remote set-url origin git@github.com:yourusername/your-repo.git
```

---

## 🔐 4단계: SSH 키를 macOS에 등록 (비밀번호 없이 사용하려면 꼭 필요)

```
# macOS 키체인에 등록 (한 번만 하면 됨) ssh-add --apple-use-keychain ~/.ssh/id_rsa
```

> 패스프레이즈가 있는 키라면 처음 한 번 입력 필요, 이후부터는 저장됨

---

## ⚙️ 5단계: ~/.ssh/config 설정 (자동 인증)

```
nano ~/.ssh/config
```

추가:
```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa
  AddKeysToAgent yes
  UseKeychain yes
```

> `Ctrl + O` → `Enter` → `Ctrl + X`로 저장하고 종료

---

## 🧪 6단계: 테스트

```
ssh -T git@github.com
```

정상 응답:

```
Hi yourusername! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## ✅ 7단계: 이제부터 비밀번호 없이 push/pull 가능!

```
git pull      # 🔄 패스워드 없이 자동 
git push      # 🔼 패스워드 없이 자동
```

---

## 💬 자주 묻는 질문 (FAQ)

|질문|답변|
|---|---|
|`Permission denied (publickey)` 오류|키가 GitHub에 등록되지 않았거나, `~/.ssh/config` 설정 누락|
|패스프레이즈 계속 뜸|`ssh-add --apple-use-keychain ~/.ssh/id_rsa` 다시 실행|
|`fatal: repository not found`|`git remote -v` 확인 → URL이 잘못됐거나 권한 없음|

---

## 🎉 정리

|단계|설명|
|---|---|
|①|SSH 키 생성 (`ssh-keygen`)|
|②|공개키 GitHub 등록|
|③|Git 원격 주소 SSH 방식으로 설정|
|④|SSH 키를 키체인에 등록 (`ssh-add`)|
|⑤|`~/.ssh/config`로 자동 인증 설정|
|⑥|`ssh -T`로 연결 테스트|
|⑦|GitHub 비밀번호 없이 `push/pull` 성공 ✅|


---

> [[Home]]