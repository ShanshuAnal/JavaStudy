# Iterator 和 Iterable 有什么区别

## 1. Iterator

`Iterator`是一个接口，提供一种机制来迭代集合中的元素，通过它可以逐一访问集合中的每个元素，而无需了解集合的内部实现

```java
public interface Iterator<E> {
    boolean hasNext();   // 判断是否有下一个元素
    E next();            // 返回下一个元素
    default void remove(); // 从集合中移除当前迭代的元素（可选操作）
}
```



#### **关键方法**

- **`hasNext()`**

  - 判断迭代器是否还有下一个元素。返回 `true` 表示可以调用 `next()` 获取元素

- **`next()`**

  - 返回下一个元素。如果没有更多元素，抛出 `NoSuchElementException`

- **`remove()`** *(可选)*

  - 移除当前迭代到的元素。如果集合不支持移除操作，会抛出 `UnsupportedOperationException`

  

#### **特点**

- 一次性使用，不可回退或重置
- 如果在迭代过程中其他线程修改了集合，会抛出并发修改异常`ConcurrentModificationException`
- 适合所有集合，`Iterator` 支持所有实现了 `Iterable` 接口的集合



#### 使用

```java
List<String> list = new ArrayList<>(Arrays.asList("A", "B", "C"));
Iterator<String> iterator = list.iterator();

while (iterator.hasNext()) {
    String element = iterator.next();
    if ("B".equals(element)) {
        iterator.remove(); // 移除元素 "B"
    }
}
System.out.println(list); // 输出: [A, C]
```



## 2. Iterable

`Iterable`也是一个接口，表示一个接口可以被迭代，它运行集合中的元素可以用`forEach`循环迭代

```java
public interface Iterable<T> {
    Iterator<T> iterator();
}
```



#### **关键方法**

- **`iterator()`**
  - 返回一个 `Iterator` 对象。通过这个 `Iterator`，实现对集合的遍历。



#### 使用

- 支持增强型for循环

  会隐式调用集合的`iterator`方法，获取迭代器，然后再自动调用`hasNext`和`next`

```java
List<String> list = Arrays.asList("A", "B", "C");
list.forEach(System.out::println)
```

- 自定义类实现

  任何类只要实现了`Iterable`接口，就都可以用`for-Each`循环

```java
class MyCollection implements Iterable<String> {
    private String[] data = {"A", "B", "C"};

    @Override
    public Iterator<String> iterator() {
        return Arrays.asList(data).iterator();
    }
}

MyCollection collection = new MyCollection();
for (String element : collection) {
    System.out.println(element);
}
```



#### 特点

- 表示可迭代的

  实现 `Iterable` 的类表示它支持通过 `Iterator` 遍历。

- **基础接口：**
  大多数集合类（如 `ArrayList`、`HashSet`）都实现了 `Iterable`。







## 3. 区别

| 特性         | `Iterator`                                          | `Iterable`                                       |
| ------------ | --------------------------------------------------- | ------------------------------------------------ |
| **定义**     | 用于迭代集合中的元素。                              | 表示一个集合可以被迭代。                         |
| **职责**     | 提供访问集合中元素的方法（`hasNext()`、`next()`）。 | 提供 `iterator()` 方法返回一个 `Iterator` 对象。 |
| **位置**     | 是集合访问机制的一部分。                            | 是集合实现的基础特性之一。                       |
| **关键方法** | `hasNext()`、`next()` 和可选的 `remove()`。         | `iterator()`。                                   |
| **关系**     | 被 `Iterable` 返回，用于迭代集合。                  | 返回 `Iterator`，使集合可以被迭代。              |
| **适用场景** | 手动遍历集合。                                      | 支持 `for-each` 语法。                           |





## 4. 关系

1. **`Iterator` 是迭代工具，`Iterable` 是集合的能力。**

- `Iterator` 是用于访问集合元素的具体机制。
- `Iterable` 表示集合可以被迭代。

2. **`Iterable` 是 `Iterator` 的入口。**

- 实现 `Iterable` 的类，必须提供 `iterator()` 方法。
- `iterator()` 返回一个 `Iterator`，用于具体的迭代操作。

3. **`for-each` 语法：**

- 通过 `Iterable` 提供的 `iterator()` 和 `Iterator` 的方法实现。





## 5. 为什么要分成两个接口

1. **职责分离：**
   - `Iterable` 负责声明集合可以被迭代。
   - `Iterator` 负责具体的迭代操作。
2. **灵活性：**
   - 同一个集合可以返回不同的 `Iterator`，实现多种迭代方式（如正序、逆序）。
3. **扩展性：**
   - 新的集合类型只需要实现 `Iterable` 接口，而无需重新实现迭代器逻辑。
4. **简洁性：**
   - 通过 `Iterable`，集合类可以支持 `for-each` 语法，简化代码书写。
5. **符合设计原则：**
   - 遵循接口隔离原则和单一职责原则，使代码清晰、易于维护。





## 6. 不要再ForEach中删除元素

# forEach循环陷阱

![img](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/fail-fast-20230428073517.png)



原因很简单，因为`forEach`是个语法糖，底层是由迭代器配合`while`循环实现的。

在使用迭代器遍历对象的时候，一定要用迭代器来进行删除`remove`操作，否则会抛出并发修改异常`ConcurrentModificationException`

> 具体：
>
> 迭代器会维护一个`expectedModCount`属性字段来记录集合被修改的次数，如果是在`forEach`循环执行删除操作，会导致`expectedModCount`和实际的`modCount`属性值不一致，从而导致了迭代器的`hasNext`和`next`方法抛出并发修改一场。
>
> 应使用迭代器来进行删除操作，它会在删除元素后更新迭代器状态，确保循环的正确性。



使用最简单的`for`循环虽然可以避开`fast-fail`机制，但是还是有问题的

```java
List<Integer> list = new ArrayList<>();
list.add(1);
list.add(2);
list.add(3);
for (int i = 0; i < list.size(); i++) {
	int num = list.get(i);
	if (num == 1) {
		list.remove(num);
	}
}
```

第一次循环，`i`为0，`list.size()`为3，`num`为0当执行完`remove`方法后，进入下一个循环

此时`i` 为1，`list.size()`由于删除了一个元素，大小为2，`num`为3，此时2直接被跳过了



















