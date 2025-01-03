# List

`List` 接口是 Java 集合框架中的一个重要接口，它是 **`Collection`** 接口的一个子接口，代表一个**有序**的元素集合，其中的元素**可以重复**。

`List` 接口的实现类包括 **`ArrayList`**, **`LinkedList`**, **`Vector`**, 和 **`Stack`** 等。

---



**特性：**

- 有序性

元素按照插入顺序进行存储，并且可以通过索引进行访问、插入和删除

- 允许重复元素

- 可以添加`null`（具体看实现类）

---



**特有方法**（都与下标有关）：

| 方法签名                                               | 返回类型  | 描述                                                         |
| ------------------------------------------------------ | --------- | ------------------------------------------------------------ |
| `void add(int index, E element)`                       | `void`    | 在指定位置插入一个元素，其他元素向后移动。                   |
| `E get(int index)`                                     | `E`       | 获取指定索引位置的元素。                                     |
| `E set(int index, E element)`                          | `E`       | 替换指定位置的元素，返回被替换的元素。                       |
| `void remove(int index)`                               | `void`    | 删除指定索引位置的元素，其他元素向前移动。                   |
| `int indexOf(Object o)`                                | `int`     | 返回元素第一次出现的索引位置，如果没有找到则返回 `-1`。      |
| `int lastIndexOf(Object o)`                            | `int`     | 返回元素最后一次出现的索引位置，如果没有找到则返回 `-1`。    |
| `boolean contains(Object o)`                           | `boolean` | 判断列表是否包含指定元素。                                   |
| `boolean isEmpty()`                                    | `boolean` | 判断列表是否为空。                                           |
| `int size()`                                           | `int`     | 返回列表中的元素个数。                                       |
| `void clear()`                                         | `void`    | 清空列表中的所有元素。                                       |
| `boolean containsAll(Collection<?> c)`                 | `boolean` | 判断列表是否包含指定集合中的所有元素。                       |
| `List<E> subList(int fromIndex, int toIndex)`          | `List<E>` | 返回指定区间内的子列表，`fromIndex` 为起始索引，`toIndex` 为结束索引。 |
| `boolean addAll(Collection<? extends E> c)`            | `boolean` | 将指定集合中的所有元素添加到列表末尾。                       |
| `boolean addAll(int index, Collection<? extends E> c)` | `boolean` | 从指定位置开始插入集合 `c` 中的所有元素。                    |



**转换为数组**

```java
Object[] toArray();

// 传入一个数组，来作为类型信息的模板
// 如果提供的数组长度不足，toArray 会根据列表的大小动态分配一个新的数组
<T> T[] toArray(T[] a);
```



```java
List<Integer> qwe = new ArrayList<>();
// 不指定类型，那么就返回Object数组
Obejct[] array = qwe.toArray();

// 此处指定将 List<Integer> 转换为 Integer[]
// 传入 new Integer[0] 是一种惯用写法，用来简化代码并减少不必要的数组初始化。
Integer[] array1 = qwe.toArray(new Integer[0]);

// 当然也可以指定长度
Integer[] array2 = qwe.toArray(new Integer[qwe.length]);

// 二维数组
List<int[]> papa = new ArrayList<>();

int[][] array = papa.toArray(new int[0][]);
```

> `new int[0][]`：指定转换后的数组类型，这里是一个空的二维数组，类型为 `int[][]`。
>
> **为什么用 `new int[0][]`：**
>
> - `toArray` 方法需要传入一个数组，来作为类型信息的模板。
> - 如果提供的数组长度不足，`toArray` 会根据列表的大小动态分配一个新的数组。
> - `new int[0][]` 是一种惯用写法，表示 "无需初始化内容，仅提供类型信息"。



---



**特有遍历方法**

`ListIterator`接口是`Iterator`的一个子接口，继承了`Iterator`的所有方法，并增加了对`List`的操作能力，主要体现在支持双向遍历、获取索引以及元素修改。



**`ListIterator` 接口的方法**

| 方法签名                | 返回类型  | 描述                                                         |
| ----------------------- | --------- | ------------------------------------------------------------ |
| `E next()`              | `E`       | 返回列表中的下一个元素，并将迭代器的当前位置向前移动。       |
| `E previous()`          | `E`       | 返回列表中的前一个元素，并将迭代器的当前位置向后移动。       |
| `boolean hasNext()`     | `boolean` | 如果迭代器有下一个元素，则返回 `true`，否则返回 `false`。    |
| `boolean hasPrevious()` | `boolean` | 如果迭代器有前一个元素，则返回 `true`，否则返回 `false`。    |
| `int nextIndex()`       | `int`     | 返回下一个元素的索引位置，如果没有下一个元素则返回列表的大小。 |
| `int previousIndex()`   | `int`     | 返回前一个元素的索引位置，如果没有前一个元素则返回 `-1`。    |
| `void remove()`         | `void`    | 删除迭代器当前指向的元素，调用此方法时必须在调用 `next()` 或 `previous()` 后进行。 |
| `void set(E e)`         | `void`    | 替换迭代器当前指向的元素为 `e`，如果没有先调用 `next()` 或 `previous()`，会抛出异常。 |
| `void add(E e)`         | `void`    | 在**当前迭代器位置插入元素 `e`**，不会覆盖现有元素，并将迭代器的当前位置向前移动。 |

​                                                                                                                                                                                                                                                                                                                                                                                                                                      **构造方法**

1. **无参数版本**：`ListIterator<E> listIterator()`
   这个版本会返回一个从列表头部开始的 `ListIterator`。默认情况下，它会指向 `List` 的第一个元素（索引为 0）。

2. **带参数版本**：`ListIterator<E> listIterator(int index)`
   这个版本会返回一个从指定索引位置 `index` 开始的 `ListIterator`。如果指定的 `index` 超出了 `List` 的大小，它会抛出 `IndexOutOfBoundsException`。

[ListIterator 方法详解](D:\study\java\notes\集合\ListIterator 方法详解.md)





**比较排序**

```java
public class Student implements Comparable<Student> {
    private String name;
    private int age;
    
    @Override
    public int compareTo(Student o) {
    	return age - o.getAge();
    }
}
```



1. `Collections.sort()`

`Collections.sort` 是 Java 中最常见的排序方式，基于 Timsort 算法实现，对 `List` 进行原地排序。

- 默认排序规则：需要列表元素实现 `Comparable` 接口

```java
List<Student> list = new ArrayList<>();
list.add(new Student("c", 3));
list.add(new Student("d", 4));
list.add(new Student("e", 5));
list.add(new Student("a", 1));
list.add(new Student("b", 2));

Collections.sort(list);
```

- 自定义排序规则，传入`Comparator`对象自定义排序，不需要列表元素实现`Comparable` 接口了

```java
Collections.sort(list, (o1, o2) -> Integer.compare(o1.getAge(), o2.getAge()));

Collections.sort(list, Comparator.comparingInt(Student::getAge));
```



2. `list.sort()`

更现代的排序方式，直接在 `List` 上调用，语法简洁,避免了使用工具类

```java
list.sort((o1, o2) -> (o1.getAge() - o2.getAge()));
```



3. `stream.sorted()`

stream提供了`sorted()`方法，用于生成一个有序类，适合需要排序后生成新List，原List不动

```java
List<Integer> sorted = list.stream.sorted.toList();
```



4. 使用 `Comparator` 自定义排序

```java
list.sort(Comparator.comparingInt(Student::getAge))
    
// 也支持多条件排序
list.sort(Comparator.comparing(Student::getName)
         		.thenComparingInt(Student::getAge));
```



5. 倒序排序

```java
// 先正序排，然后再倒序
list.sort(Comparator.comparingInt(Student::getAge));
Collections.reverse(list);

// 直接倒序
list.sort(Comparator.comparingInt(Student::getAge).reversed());
```











