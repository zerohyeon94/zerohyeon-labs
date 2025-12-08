## 1. SQL 인젝션이란?

**SQL 인젝션(SQL Injection)** =  
사용자 입력값에 **SQL 조각을 섞어서**,  
내가 작성한 원래 쿼리의 의미를 **바꿔버리는 공격**이에요.

예를 들어, 회원 이름으로 로그인한다고 가정해 볼게요.

### ❌ 나쁜 코드 (문자열 붙여쓰기)

```python
name = input("이름을 입력하세요: ")  # 사용자가 입력한 값

sql = "SELECT * FROM users WHERE name = '" + name + "';"
print(sql)
cur.execute(sql)
```

원래는 사용자가 `Tom`을 입력하면:

```sql
SELECT * FROM users WHERE name = 'Tom';
```

정상인데,

어떤 악의적인 사용자가 이렇게 입력할 수 있어요:

```text
' OR 1=1 --
```

그럼 최종 SQL은:

```sql
SELECT * FROM users WHERE name = '' OR 1=1 --';
```

- `OR 1=1` → 항상 참
    
- `--` → 뒤에 오는 건 주석 처리

결과적으로 **모든 유저가 다 조회**될 수 있어요. 
로그인 로직이라면, “비밀번호 확인 없이” 통과해버릴 수도 있고요.

심하면:

```text
'; DROP TABLE users; --
```

같은 걸로 테이블 날려먹는 공격도 가능해요.

---

## 2. 파라미터 바인딩이 막아주는 것

이제 같은 로직을 **플레이스홀더 `%s` + 파라미터**로 쓰면:

```python
name = input("이름을 입력하세요: ")

sql = "SELECT * FROM users WHERE name = %s"
cur.execute(sql, (name,))
```

여기서 중요한 건:

- SQL 문자열:  
    `"SELECT * FROM users WHERE name = %s"`  
    👉 **그냥 틀(Template)** 역할만 함
    
- 값(`name`)은 `execute` 두 번째 인자로 따로 전달  
    👉 DB 드라이버(pymysql)가
    
    - 따옴표, 특수문자 등을 **자동으로 이스케이프**
        
    - 이 값을 **절대 SQL 코드로 해석하지 않고 “그냥 데이터”로만 사용**

즉, 사용자가 `' OR 1=1 --` 를 입력해도:

- 이게 **“조건식”이 아니라 문자열 값**으로 취급돼요.
    
- 최종적으로는 요런 느낌으로 처리됨:

```sql
SELECT * FROM users WHERE name = '\' OR 1=1 --'
```

그래서 조건은 “name이 `' OR 1=1 --`라는 문자열인 사람”만 찾게 되고,  
우리가 의도한 **단순 비교 쿼리**에서 벗어나지 않습니다.

---

## 3. 그래서 “인젝션 방지에 효과적”이란?

정리하면:

> 👉 **사용자가 입력한 값이 절대 쿼리의 구조를 바꾸지 못하게 한다**  
> 👉 입력값은 항상 “데이터”로만 취급되고, “SQL 코드”가 될 수 없다  
> 👉 그래서 SQL 인젝션 공격을 막는 데 효과적이다

라는 뜻이에요.

---

## 4. 기억해두면 좋은 규칙

1. **절대 이렇게 하지 말기** ❌

```python
sql = f"SELECT * FROM users WHERE name = '{name}'"
cur.execute(sql)
```

2. **항상 이렇게 쓰기** ✅

```python
sql = "SELECT * FROM users WHERE name = %s"
cur.execute(sql, (name,))
```

나중에 과제/면접에서

> “왜 파라미터 바인딩을 써야 하나요?”  
> “SQL 인젝션은 어떻게 방지하나요?”

라고 물어보면,

> 문자열로 직접 붙이지 않고, `%s` 플레이스홀더와 `execute(sql, params)`를 사용해서  
> **쿼리와 데이터(값)를 분리**하면 사용자가 입력한 값이 쿼리 구조를 바꾸지 못해서  
> SQL 인젝션 방지에 효과적입니다.