ORM은 **Object-Relational Mapping(객체-관계 매핑)**의 줄임말

> “**파이썬(또는 다른 언어)에서 클래스로 DB 테이블을 다루게 해주는 층**”

---

## 1. ORM이 왜 나왔냐?

지금까지 했던 방식:

- **DB 세계**: 테이블, 행(row), 열(column), SQL
    
- **언어 세계**: 클래스, 객체, 리스트, 딕셔너리, 메서드

우리가 직접 할 때는:

```python
# PyMySQL
sql = "SELECT id, name FROM users WHERE age >= %s"
cursor.execute(sql, (20,))
rows = cursor.fetchall()
```

이렇게 **SQL 문자열을 직접 쓰고**, 결과를 dict/list로 받아서 처리하죠.

ORM은 이걸 이렇게 바꾸고 싶어해요 👇

```python
# ORM 스타일 (예: SQLAlchemy, Django ORM 등)
young_users = session.query(User).filter(User.age >= 20).all()

for user in young_users:
    print(user.id, user.name)
```

- `User`라는 **클래스**가 실제 DB의 `users` 테이블과 연결되어 있고,
    
- `user`는 그 테이블의 **한 행(row)을 표현하는 객체**

---

## 2. ORM의 핵심 아이디어

### (1) 테이블 ↔ 클래스

```python
# 예: SQLAlchemy
class User(Base):
    __tablename__ = "users"

    id   = Column(Integer, primary_key=True)
    name = Column(String(50))
    age  = Column(Integer)
```

- DB: `users` 테이블
    
- 코드: `User` 클래스
    
- 한 행(row): `User` 인스턴스

### (2) INSERT도 객체로

```python
new_user = User(name="Alice", age=25)
session.add(new_user)
session.commit()
```

→ 내부적으로는 `INSERT INTO users ...` SQL을 만들어 DB에 날림.

### (3) SELECT도 객체로

```python
user = session.query(User).filter(User.id == 1).first()
print(user.name, user.age)
```

→ 내부적으로는 `SELECT ... FROM users WHERE id = 1` SQL 실행.

---

## 3. 우리가 지금 쓰는 것들과의 관계

- **PyMySQL**
    
    - DB 드라이버 (SQL 직접 쓰는 계층)
        
    - ORM **아래층**에 있는 느낌
        
- **SQLAlchemy ORM (파이썬)**
    
    - PyMySQL 같은 드라이버를 내부에서 사용
        
    - 우리는 `User`, `Movie` 같은 클래스로만 DB를 다룸
        
- **MongoDB**는 원래가 NoSQL이라 전통적인 “ORM”이라기보다
    
    - **ODM(Object-Document Mapper)** 라고 부름
        
    - 역할은 비슷함: 도큐먼트 ↔ 파이썬 객체 매핑
        
- **iOS 쪽으로 비유**
    
    - Core Data도 일종의 ORM/ODM 같은 느낌이에요
        
    - SQLite 같은 걸 내부에서 쓰면서 우리는 `NSManagedObject` 서브클래스로 데이터를 다룸

---

## 4. ORM의 장점 / 단점

### ✅ 장점

1. **코드가 객체지향적으로 깔끔해짐**
    
    - `user.name`, `movie.year` 같이 접근
        
2. **SQL 문자열을 직접 덜 씀**
    
    - 반복적인 CRUD 코드 감소
        
3. **DB 교체 유연성**
    
    - MySQL → PostgreSQL 바꿔도 ORM 코드 자체는 거의 그대로일 수 있음
        
4. **타입/스키마가 코드에 드러남**
    
    - IDE 자동완성, 타입 체크에 유리

### ⚠️ 단점

1. **SQL을 안 배운 건 아니다**
    
    - 복잡한 쿼리(튜닝, 최적화)는 결국 SQL 이해 필요
        
2. **단순한 쿼리는 편하지만, 매우 복잡한 쿼리는 오히려 ORM 코드가 더 지저분**
    
3. **ORM이 생성하는 SQL을 이해 못 하면 디버깅이 힘들 수 있음**

---

## 5. 지금 당신 위치 기준으로 요약

- 지금 배우는 **PyMySQL + 직접 SQL**은 **“Low-level, 원형에 가까운 방식”** → 이걸 잘 이해해두는 게 **ORM 이해에도 엄청 큰 도움**이에요.
    
- 나중에 **SQLAlchemy ORM, Django ORM** 같은 걸 쓸 때:
    
    - “아, 얘가 내부에서 SELECT / INSERT / JOIN을 알아서 만들어주는 거구나”
        
    - “근데 결국 DB에서는 똑같이 SQL로 돈다” 라는 감각이 생깁니다.

---

### 한 줄 정리

> ORM = **Object-Relational Mapping**  
> → “DB 테이블을 코드의 클래스/객체로 매핑해서, SQL 대신 객체를 가지고 DB를 다루게 해주는 라이브러리/패턴”

---

> [[백엔드 학습 인덱스]]