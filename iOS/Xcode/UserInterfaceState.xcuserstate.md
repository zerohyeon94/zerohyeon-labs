
![[image_UserInterfaceState.png]]
## 1. `UserInterfaceState.xcuserstate`란?

- 이 파일은 Xcode가 **작업자의 UI 상태(에디터의 창 위치, 열려있는 탭, 커서 위치 등)**를 로컬에 저장하는 용도로 사용합니다.
    
- 프로젝트 내부의 `.xcworkspace/xcuserdata/사용자명.xcuserdatad/UserInterfaceState.xcuserstate` 경로에 위치합니다.
    
- **프로젝트 코드/기능과는 전혀 상관없는 개인 작업 환경(작업자의 Xcode UI 세팅) 데이터입니다.**

---

## 2. 왜 계속 Unstaged에 남을까?

- Xcode를 사용할 때마다 **작업할 때마다 자동으로 갱신**됩니다.  
    (파일 열기, 뷰 이동, 커서 위치 변경 등만 해도 바뀝니다)
    
- 그래서 **사소한 작업만 해도 내용이 달라져서 항상 git status에 뜨는 것**입니다.
    

---

## 3. 이 파일을 커밋해야 할까?

- **절대 커밋하거나 버전관리할 필요가 없습니다!**
    
- 오히려 팀원마다 다르고, 협업에 방해만 되므로 반드시 제외해야 합니다.

---

## 4. 어떻게 처리해야 할까? (`.gitignore`에 추가)

보통 **`.gitignore`**에 아래처럼 추가해서 **Git 관리에서 아예 제외**하는 것이 정석입니다.

```plaintext
# Xcode workspace UI state
*.xcuserstate
```

혹은 아래처럼 폴더 전체를 무시하는 경우도 많습니다:

```plaintext
*.xcuserstate
xcuserdata/
```

- 이미 Git에 추가되어 트래킹 되고 있다면,  
    아래 명령어로 **트래킹을 해제**할 수 있습니다:
    

```bash
git rm --cached path/to/UserInterfaceState.xcuserstate
```

---

## 결론/요약

- **항상 Unstaged로 남는 게 정상**입니다.
    
- 커밋하지 말고, `.gitignore`에 추가해서 Git의 관리에서 제외하세요.
    
- 이미 커밋된 적이 있다면 한 번만 삭제/트래킹 해제 후, 앞으로는 git status에 안 뜨게 할 수 있습니다.