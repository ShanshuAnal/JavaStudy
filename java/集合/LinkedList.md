# LinkedList

`LinkedList` 是 Java 中 `List` 接口的一个实现类，它实现了双向链表的数据结构。每个元素都被称为 **节点 (Node)**，每个节点包含 **数据部分** 和 **前向引用**以及 **后向引用**。

- 对于插入、删除等操作（尤其是在头部或尾部）非常高效
- 由于访问元素需要遍历链表，因此随机访问性能较差

#### 核心字段

```java
public class LinkedList<E> extends AbstractSequentialList<E>
    implements List<E>, Deque<E>, Cloneable, java.io.Serializable {
   	// 链表元素数量
    transient int size = 0;
    // 链表头节点
    transient Node<E> first;
	// 链表尾节点
    transient Node<E> last;
    
    // 节点类
    private static class Node<E> {
    E item;
    Node<E> next;
    Node<E> prev;

    Node(Node<E> prev, E element, Node<E> next) {
        this.item = element;
        this.next = next;
        this.prev = prev;
    }
}
```



#### 构造方法

- 无参构造

- 有参构造——创建一个包含指定集合元素的链表

```java
public LinkedList(Collection<? extends E> c) {
    this();
    addAll(c);
}
```



#### 核心方法

##### 1. 添加元素

- 在链表末尾添加

```java
public boolean add(E e) {
    // 调用 linkLast方法将新元素链接到链表尾部。
    linkLast(e);
    return true;
}

void linkLast(E e) {
    // 获取尾节点
    final Node<E> l = last;
    final Node<E> newNode = new Node<>(l, e, null);
    // 更新尾节点
    last = newNode;
    // 如果一个节点都没有，那么首节点就是尾节点
    if (l == null)
        first = newNode;
    // 添加到链表中
    else
        l.next = newNode;
    // 更新长度和操作次数
    size++;
    modCount++;
}
```

- 在指定位置添加

```java
public void add(int index, E element) {
    checkPositionIndex(index);

    // 如果是在最后进行插入，那么就相当于add(E e)
    if (index == size)
        linkLast(element);
    // 否则先找到该下标对应的节点，然后插入
    else
        // 在下标i的节点之前插入
        linkBefore(element, node(index));
}

// 在某个节点前面插入一个节点
void linkBefore(E e, Node<E> succ) {
    final Node<E> pred = succ.prev;
    final Node<E> newNode = new Node<>(pred, e, succ);
    succ.prev = newNode;
    // 如果链表为空 或者 插入在下标为0的位置
    if (pred == null)
        first = newNode;
    else
        pred.next = newNode;
    size++;
    modCount++;
}
```

- 在首尾添加

```java
public void addFirst(E e) {
    linkFirst(e);
}
public void addLast(E e) {
    linkLast(e);
}

// 插入第一个元素
private void linkFirst(E e) {
    // 先获取头节点
    final Node<E> f = first;
    // 创建节点
    final Node<E> newNode = new Node<>(null, e, f);
    更新头节点
    first = newNode;
    
    // 原头节点为null的话，说明链表为空
    if (f == null)
        last = newNode;
    else
        f.prev = newNode;
    size++;
    modCount++;
}
```



##### 2. 根据下标获取元素

```java
public E get(int index) {
    checkElementIndex(index);
    return node(index).item;
}

// 根据下标返回节点
Node<E> node(int index) {
    // 如果在前半部分，就从头开始找
    if (index < (size >> 1)) {
        Node<E> x = first;
        for (int i = 0; i < index; i++)
            x = x.next;
        return x;
    // 在后半部分，就从尾巴开始找
    } else {
        Node<E> x = last;
        for (int i = size - 1; i > index; i--)
            x = x.prev;
        return x;
    }
}
```



##### 3. 删除元素

- 删除指定元素

  找到对应的节点，然后就是双链表删除

```java
public boolean remove(Object o) {
    // 如果元素为null的话，要单独处理，因为用不了equals方法
    if (o == null) {
        for (Node<E> x = first; x != null; x = x.next) {
            if (x.item == null) {
                unlink(x);
                return true;
            }
        }
    } else {
        for (Node<E> x = first; x != null; x = x.next) {
            if (o.equals(x.item)) {
                unlink(x);
                return true;
            }
        }
    }
    return false;
}

// 删除节点的底层操作，返回删除节点的值
E unlink(Node<E> x) {
    // assert x != null;
    final E element = x.item;
    final Node<E> next = x.next;
    final Node<E> prev = x.prev;

    // 如果前节点为null
    if (prev == null) {
        first = next;
    } else {
        prev.next = next;
        x.prev = null;
    }

    if (next == null) {
        last = prev;
    } else {
        next.prev = prev;
        x.next = null;
    }

    // 执行到这，节点x的prev和next都为null，再将item置为null，JVM会自动回收垃圾
    x.item = null;
    size--;
    modCount++;
    return element;
}
```



- 删除指定下标元素

```java
public E remove(int index) {
    checkElementIndex(index);
    // 先获得指定下标的节点
    // 然后删除节点
    return unlink(node(index));
}
```



##### 4. 修改元素

获得指定下标的节点，然后修改节点值，返回原节点值

```java
public E set(int index, E element) {
    checkElementIndex(index);
    Node<E> x = node(index);
    E oldVal = x.item;
    x.item = element;
    return oldVal;
}
```

---



#### 与ArrayList进行对比

##### 共同点

1. 接口实现

   - 都实现了`List`接口，具备按索引访问元素的能力

   - 都支持动态扩容

   - 可以添加重复元素、`null`

   - 线程不安全

2. 核心功能

   - 可以增删改查
   - 可以用迭代器进行遍历
   - 支持排序操作

3. 支持序列化

4. 顺序存储（在内存中保存的顺序与输入的顺序一致）

   

##### 不同点

#### **ArrayList 和 LinkedList 的异同点**

------

##### **一、共同点**

1. **接口实现**：
   - 都实现了 **`List`** 接口，提供了按索引访问元素的能力。
   - 都支持 **动态扩容**（ArrayList）或动态增长（LinkedList）。
   - 都支持重复元素和 `null` 元素。
   - 都是非线程安全的，需要通过手动同步来保证多线程环境下的安全性。
2. **核心功能**：
   - 提供常见的增删改查方法，比如 `add()`、`remove()`、`get()`、`set()` 等。
   - 提供迭代器（`Iterator` 和 `ListIterator`）来遍历元素。
   - 支持排序操作（例如 `Collections.sort()`）。
3. **序列化支持**：
   - 都实现了 `Serializable` 接口，可以被序列化。
4. **集合的特性**：
   - 顺序存储（逻辑顺序，ArrayList 是数组连续存储，LinkedList 是链表链式存储）。
   - 适合存储数量不定的元素。

------

##### **二、区别**

| **特性**         | **ArrayList**                                                | **LinkedList**                                               |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **底层数据结构** | 动态数组                                                     | 双向链表                                                     |
| **内存分配**     | 连续内存块，存储元素的引用或直接存储值                       | 非连续内存，每个节点存储数据和两个引用                       |
| **访问速度**     | 按索引随机访问，时间复杂度为 **O(1)**                        | 按索引访问需要从头遍历到指定位置，时间复杂度为 **O(n)**      |
| **插入和删除**   | - 尾部插入：**O(1)**  - 中间插入/删除：**O(n)**（需要移动后续元素） | - 首尾插入：**O(1)**  - 中间插入/删除：**O(n)**（需要遍历到指定位置） |
| **扩容机制**     | 当容量不足时，扩容为原来的 1.5 倍，涉及数组复制，时间复杂度为 **O(n)** | 不需要扩容，链表节点按需分配内存                             |
| **内存占用**     | 额外内存开销较小，仅存储元素本身或引用                       | 每个节点需要额外存储两个引用（前驱和后继），开销较大         |
| **适用场景**     | - 数据量较大但**变动较少**，主要进行**随机访问**场景，例如缓存或列表展示 | - 数据**变动频繁**，主要进行插入/删除场景，例如任务队列或动态更新的链表 |
| **线程安全性**   | 非线程安全，通过 `Collections.synchronizedList` 包装或使用 `CopyOnWriteArrayList` 实现线程安全 | 非线程安全，通过 `Collections.synchronizedList` 包装实现线程安全 |
| **迭代性能**     | 迭代性能较高，受益于数组的连续存储和缓存命中率               | 迭代性能相对较低，由于链表的非连续存储，需要跳转多个内存地址 |
| **实现特点**     | - 使用动态数组实现  - 通过 `System.arraycopy` 复制元素       | - 使用双向链表实现  - 每个节点存储前驱和后继引用             |



##### 总结对比

| **特性**          | **ArrayList**    | **LinkedList**         |
| ----------------- | ---------------- | ---------------------- |
| **底层数据结构**  | 动态数组         | 双向链表               |
| **随机访问效率**  | **高**（O(1)）   | **低**（O(n)）         |
| **插入/删除效率** | **低**（O(n)）   | **高**（O(1)）         |
| **内存占用**      | **低**           | **高**                 |
| **线程安全性**    | 非线程安全       | 非线程安全             |
| **适用场景**      | 数据量大，变动少 | 变动频繁，随机访问较少 |

















