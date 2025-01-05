# Map

map的继承结构


![image-20250105202737358](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250105202737358.png)

## 常用方法

#### 1. 添加或修改元素

- `V put(K key, V value);`	

  将指定的键值对添加到`Map`中，如果键已存在，则会用新的值替换旧的值

  ```java
  map.put("key1", "value1");
  ```

- `putAll(Map<? extends K, ? extends V> m)`
  将另一个 Map 的所有键值对添加到当前 Map 中

  ```java
  map.putAll(otherMap);
  ```

---



#### 2. 获取元素

- `get(Object key)`

  根据指定的键获取对应的值，如果键不存在，则返回`null`

  ```java
  String value = map.get("key1");
  ```

- `getOrDefault(Object key, V defaultValue)`

  如果键存在，返回对应的值，否则返回默认值`defaultValue`

  ```java
  String value = map.getOrDefault("key2", "defaultValue");
  ```

- `Map.of()`

  ```java
  // 通过Map的静态方法of生成新的map集合对象
  Map<Integer, String> map1 = Map.of(1, "a", 2, "b", 3, "c");
  ```

---



#### 3. 检查元素

- `containsKey(Object key)`

  检查 Map 是否包含指定的键。

  ```java
  boolean hasKey = map.containsKey("key1");
  ```

- `containsValue(Object value)`
  检查 Map 是否包含指定的值。

  ```java
  boolean hasValue = map.containsValue("value1");
  ```

---



#### 4. 删除元素

- `remove(Object key)`
  **根据键删除键值对**，返回被删除的值。如果键不存在，返回 `null`。

  ```java
  String removedValue = map.remove("key1");
  ```

- `remove(Object key, Object value)`
  仅在**键和值同时匹配**时才删除该键值对，返回布尔值表示是否删除成功。

  ```java
  boolean isRemoved = map.remove("key1", "value1");
  ```

---



#### 5. 获取视图

- `keySet(): Set<K>`
  返回 Map 中所有键的 `Set` 视图。

  ```java
  Set<String> keys = map.keySet();
  ```

- `values(): Collection<V>`
  返回 Map 中所有值的 `Collection` 视图。

  ```java
  Collection<String> values = map.values();
  ```

- `entrySet(): Set<Map.Entry<K, V>>`
  返回 Map 中所有键值对的 `Set` 视图，每个元素是 `Map.Entry`。

  ```java
  Set<Map.Entry<String, String>> entries = map.entrySet();
  ```

---



#### 6. 遍历方式

```java
Map<Integer, String> map = new HashMap<>();
map.put(1, "a");
map.put(2, "b");
map.put(3, "a");
```

- 获取所有`key`，再根据`Key`

  ```java
  
  // 获取所有key，得到key的集合
  Set<Integer> keys = map.keySet();
  
  // 用迭代器进行遍历
  Iterator<Integer> iterator = keys.iterator();
  while (iterator.haNext()) {
      Integer key = iterator.next();
      String value = map.get(key);
  }
  
  // 用增强forEach循环，底层上是调用的迭代器
  for (int key : keys) {
      String value = map.get(key);
  }
  ```

- 获取所有键值对的`Set`视图集合（效率高）

  `Entry`是`Map`的内部类

  ```java
  Set<Map.Entry<Integer, String>> entries = map.entryset();
  Iterator<Map.Entry<Integer, String>> iterator = entries.iterator();
  
  while (iterator.hasNext()) {
      Map.Entry<Integer, String> entry = iterator.next();
      Integer key = entry.getKey();
      String value = entry.getValue();
  }
  ```

  

#### 7. 其他操作

- `size(): int`
  返回 Map 中键值对的数量。

  ```java
  int size = map.size();
  ```

- `isEmpty(): boolean`

  检查 Map 是否为空。

  ```java
  boolean isEmpty = map.isEmpty();
  ```

- `clear(): void`

  清空 Map 中的所有键值对，无返回值。

  ```java
  map.clear();
  ```

---



