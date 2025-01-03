# Collection

[collection的继承结构](D:\study\java\notes\collection.mdj)

[关于泛型](D:\study\java\notes\集合\泛型.md)

<img src="../../assets/Collection/image-20241210155857856.png" alt="image-20241210155857856" style="zoom:67%;" />

Collection是java集合框架的顶级接口，它提供了一组方法，用于存储和操作一组对象。Collection接口定义了集合的基本行为，集合可以看作是一个对象的容器，存储的对象称为元素。

Collection接口继承于Iterable接口，Iterable接口提供了遍历集合的能力 `iterator()`

可以通过继承Collection，java提供了多种集合类型，满足不同场景需要

---

**特点**

1. **抽象性**
   - 它是一个接口，不能实例化
   - Collection是更具体集合接口（Queue、SequencedCollection、Set）的接口
2. 统一操作
   - 定义了一些通用方法，如add、remove、size、iterator等
3. 泛型支持
   - 支持泛型，可以在编译时约束集合中的元素类型
4. 不支持直接存储原始类型
   - 集合中只能存储对象类型，基本数据类型要通过其包装类进行封装

---

**主要方法**

| 方法                                        | 描述                                     |
| ------------------------------------------- | ---------------------------------------- |
| `boolean add(E e)`                          | 添加指定的元素到集合中。                 |
| `boolean remove(Object o)`                  | 移除集合中指定的元素。                   |
| `boolean contains(Object o)`                | 检查集合是否包含指定的元素。             |
| `int size()`                                | 返回集合中元素的个数。                   |
| `boolean isEmpty()`                         | 检查集合是否为空。                       |
| `void clear()`                              | 清空集合中的所有元素。                   |
| `Iterator<E> iterator()`                    | 返回一个迭代器，用于遍历集合中的元素。   |
| `boolean retainAll(Collection<?> c)`        | 仅保留集合中与指定集合共有的元素。       |
| `boolean removeAll(Collection<?> c)`        | 从集合中移除与指定集合相同的所有元素。   |
| `boolean addAll(Collection<? extends E> c)` | 将另一个集合中的所有元素添加到当前集合。 |

---



### 1. 集合使用迭代器进行遍历

`Iterator` 是集合框架提供的接口，用于对集合元素进行逐一访问，而无需关心底层实现。


`Iterator` 是 Java 的一个接口，位于 `java.util` 包下，常见方法包括：

- `boolean hasNext()`：判断是否有下一个元素。
- `E next()`：返回下一个元素。
- `void remove()`：从底层集合中移除最后返回的元素（可选操作）。

**适用范围**

- 所有实现了 `Collection` 接口的集合类，如 `ArrayList`、`HashSet`。
- 一些非 `Collection` 接口的类，如 `Map`，可以通过 `keySet()`、`values()` 等方法间接获取 `Iterator`。

**优点**

- 与具体集合的内部结构无关。
- 提供统一的遍历方法。
- 避免了直接操作集合的索引或结构。

```java
List<String> list = new ArrayList<>();
list.add("A");
list.add("B");
list.add("C");
Iterator<String> iterator = list.iterator(); // 获取迭代器

while (iterator.hasNext()) {
    String element = iterator.next(); // 获取元素
    System.out.println(element);
}
```

**删除**

使用迭代器的remove方法进行删除，详见[ArrayList的iterator()](D:\study\java\notes\集合\ArrayList的iterator().md)

```java
public void testDelete() {
Collection<String> names = new ArrayList<>();

    names.add("ad");
    names.add("12");
    names.add("34");
    names.add("56");
    names.add("ty");;

    Iterator<String> it = names.iterator();
    while (it.hasNext()) {
    	String name = it.next(); 
		if (name.equals("34")) {
			it.remove();
		}
    }
}
```





### 2. SequencedCollection

`SequencedCollection` 是 Java 21 新增的接口，继承自 `Collection`。该接口专注于支持按**顺序操作**的集合。它统一了列表和双端队列的功能，运行开发者便捷地操作首尾元素（下标索引不行）。

---

**特点**

1. **统一了顺序操作的接口**

   通无论是 List 还是 Deque，都可以使用统一的方法如 getFirst() 和 getLast()。提供了更加一致的 API，使代码更易于理解和维护。

2. **填补集合抽象层的空白**

   Collection是集合的顶级接口，但它不提供顺序操作的方法，开发者不得不依赖特定子接口，比如List或者Deque，那么SequencedCollection就是来对顺序操作进行抽象统一，从而避免了直接依赖实现类的接口。

3. **支持反序操作**

   在 Java 21 之前，开发者必须手动构造反向迭代逻辑，代码复杂度较高，且容易出错。通过reversed() 方法，开发者可以轻松获取集合的反序视图，无需额外实现，与此同时还提高了代码的可读性。

---

**主要方法**

| 方法名                | 描述                                         |
| --------------------- | -------------------------------------------- |
| `getFirst()`          | 返回集合的第一个元素，集合为空时抛出异常。   |
| `getLast()`           | 返回集合的最后一个元素，集合为空时抛出异常。 |
| `addFirst(E element)` | 在集合的开头添加元素。                       |
| `addLast(E element)`  | 在集合的末尾添加元素。                       |
| `removeFirst()`       | 移除并返回集合的第一个元素。                 |
| `removeLast()`        | 移除并返回集合的最后一个元素。               |
| **`reversed()`**      | 返回该集合的反序视图（不修改原集合）。       |

