# MongoDB
- 데이터베이스(DataBase)
- 컬렉션(collection)
- 도큐먼트(Document)
- 기본적으로 `_id`라는 고유값이 자동으로 들어감
- 예시
```json
{
	"name": "David",
	"age": 30,
	"blood_pressure": {
		"sys": 120,
		"dia": 80
	},
	"labs": [
		{
			"test": "HDL",
			"value": 55
		},
		{
			"test": "LDL",
			"value": 120
		},
	]
}
```

# PyMongo

- 파이썬으로 MongoDB와 사용할 수 있게 해주는 라이브러리

## 초기설정

```python
from pymongo import MongoClient ## pymongo를 사용하기 위해 설치를 해야한다.

mongodb_uri = "mongodb+srv://dbUser:password1234@cluster0.fijlql6.mongodb.net/?appName=Cluster0"
client = MongoClient(mongodb_uri) # MongoDB에 접속
db = client.sample_mflix # DB를 선택
movies = db.movies # 컬렉션 선택
```

## 도큐먼트 삽입

### 단일 도큐먼트 삽입 `insert_one()`

```python
my_movie = {
	"title": "My Test Movie",
	"year": 2023,
	"genres": ["Comedy", "Action"]
}

result = temp_movies.insert_one(my_movie)
print(result.inserted_id) # 결과: 69317769879515f794a22035
```

### 여러 도큐먼트 삽입 `insert_many()`

```python
my_movie_list = [
	{
		"title": "Another Test Movie 1",
		"year": 2024,
		"genres": ["Drama"]
	},
	{
		"title": "Another Test Movie 2",
		"year": 2024,
		"genres": ["Mystery", "Thriller"]
	}
]
  
result = temp_movies.insert_many(my_movie_list)
print(result.inserted_ids) # 결과: [ObjectId('693177e6879515f794a22036'), ObjectId('693177e6879515f794a22037')]
```

## 데이터 조회 
### 조건에 맞는 첫 번째 도큐먼트 조회 `find_one()`

```python
display(movies.find_one({
	'title': 'The Great Train Robbery' # 결과: 해당 title을 가지고 있는 정보를 전달해줌
}))
```

### 조건에 맞는 모든 도큐먼트 조회 `find()`

```python
for r in movies.find({"year": 1903}):
display(r) # 결과: 해당 year를 가지고 있는 정보를 모두 전달
```

### 프로젝션 (Projection)
- `find()` 또는  `find_one()` 메소드 사용 시 결과 도큐먼트에서 원하는 필드만 선택해서 가져온다.
- 두번째 인자로 딕셔너리를 전달하여 필드를 포함하거나 제외 가능
- `_id` 필드를 제외하려면 `_id: 0`으로 설정하면됨

```python
for doc in movies.find(
	{"year": 1903},
	{"title": 1, "year": 1, '_id': 0}):
display(doc) # 결과: 해당되는 year을 가진 것 중 title, year만 표시하게 구현
```

## 결과 정렬 및 제한
### 결과 정렬 `sort()`
- 조회 결과를 특정 필드를 기준으로 정렬.
- 1 : 오름차순
- -1 : 내림차순
### 결과 개수 제한 `limit()`

```python
for doc in movies.find(
	{}, {"title": 1, "year": 1, "_id": 0}).sort("year", -1).limit(5): # 내림차순으로 정렬 후 5개 조회
display(doc)

print("\n================\n")

for doc in movies.find(
	{}, {"title": 1, "year": 1, "_id": 0}).sort("year", 1).limit(3): # 오름차순으로 정렬 후 3개 조회
display(doc)
```

## 도큐먼트 업데이트
### 단일 업데이트 `update_one()`
- `modified_count` : 실제로 내용이 변경된 수를 나타낸다.

```python
updated_result_one = temp_movies.update_one(
	{"title": "My Test Movie"},
	{
		"$set": {
			"year": 2025,
			"status": "updated"
		}
	}
)

print(updated_result_one.modified_count) # 결과: 1 --> 이는 수정이 일어났다는 것을 알림.
```
### 다중 업데이트 `update_many()`
- `matched_count` : 조건에 걸린 문서가 몇개 있는지

```python
updated_result_many = temp_movies.update_many(
	{
		"$or": 
		[
			{
				"year": 2025, "status": "updated"
			}
		]
	},
	{
		"$set": 
		{
			"status": "reviewed"
		}
	}

)

print("매칭된 도큐먼트: ", updated_result_many.matched_count) # 실제로 매칭된 것 1
print("수정된 도큐먼트: ", updated_result_many.modified_count) # 수정된 것도 1로 표시
```
## 도큐먼트 삭제
### 단일 삭제 `delete_one()`
- `deleted_count` : 삭제된 도큐먼트 수

```python
deleted_result_one = temp_movies.delete_one({"year": 2023})

print("삭제된 도큐먼트: ", deleted_result_one.deleted_count) # 결과: 1 --> 실제로 해당되는 것은 2개가 있었으나 1개만 삭제
```
### 다중 삭제 `delete_many()`

```python
deleted_result_many = temp_movies.delete_many({"year": 2024})

print("삭제된 도큐먼트: ", deleted_result_many.deleted_count) # 결과: 4 --> 실제로 4개가 있었고 모두 삭제됨.
```

## 컬렉션 삭제 `drop()`
- 컬렉션 전체를 삭제
- 내부에 있는 모두 도큐먼트도 삭제된다.

```python
print("컬렉션 삭제 전 : ", 'temp_movies' in db.list_collection_names()) # 결과: 컬렉션이 존재하기 때문에 True

temp_movies.drop()

print("컬렉션 삭제 후 : ", 'temp_movies' in db.list_collection_names()) # 결과: drop으로 삭제했기 때문에 False
```

---

> [[백엔드 학습 인덱스]]