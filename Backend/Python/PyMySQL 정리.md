# MySQL

- 테이블(Table)
- 행(Row)
- 열(Column)
- PK(Primary Key)
- FK(Foreign Key)

# PyMySQL

- 파이썬으로 MySQL데이터베이스와 상호작용할 수 있게 해주는 라이브러리

## 초기 설정

```python
import pymysql ## 미리 설치를 진행한 후에 import 해야한다.

## 내가 사용하고자 하는 DB를 연결해야한다.
conn = pymysql.connect(
	host=host,
	user=user,
	password=password,
	db=database,
	port=port,
	charset='utf8'
)
```

## 실제 예시 

1. `with conn.cursor() as cur:`
	- with문을 사용하면 커서(cur)를 컨텍스트 매니저(블록의 시작과 끝에서 자동으로 어떤 일을 해주는 객체)로 사용.
	- 블록을 나오는 순간 자동으로 `cur.close()`가 호출됨 (단, 커서만 닫히는 것이고 `conn` 연결은 유지)
2. `execute()`
	- SQL문을 실행하는 함수
3. `%s`
	- SQL에 값을 넣는 placeholder
	- `execute(sql, (값, ))` 형태로 전달하며 인젝션 방지 효과가 있다.
4. `fetchall()`
	- SELECT 결과의 모든 행을 한번에 가져옴
	- 여러개의 데이터를 조회하기 위해 사용
5. `fetchone()`
	- SELECT 결과의 첫번째 행을 가져옴
	- 단일 데이터를 조회하기 위해 사용


```python
with conn.cursor() as cur:

sql = """
	SELECT
		p.name,
		l.test_name,
		l.result,
		l.result_date
	FROM labs AS l
	JOIN visits AS vs
		ON l.visit_id = vs.visit_id
	JOIN patients AS p
		ON vs.patient_id = p.patient_id
	WHERE l.test_name = 'HbA1c'
		AND CAST(REPLACE(l.result, '%%', '') AS DECIMAL(4,2)) >= %s
	ORDER BY l.result_date DESC;
"""

cur.execute(sql, (7.0,))
rows = cur.fetchall()
  
for name, test_name, result, result_date in rows:
print(f"환자 이름: {name}, 검사명: {test_name}, 결과: {result}, 검사 날짜: {result_date}")
```

### 추가 SQL

1. 문자열에서 `%` 빼기
	
	```sql
	REPLACE(문자열, 찾을 문자열, 바꿀 문자열)
	```
	- 문자열에서 '찾을 문자열'을 찾아서 '바꿀 문자열로' 변경하는 것
	
2. 문자열을 숫자로 변환
	```
	CAST(값 AS 타입)
	```
	- 값을 지정한 타입으로 형 변환하는 함수

	```sql
	DECIMAL(전체자릿수, 소수점_아래_자릿수)
	```
	- DECIMAL 타입

---

> [[백엔드 학습 인덱스]]