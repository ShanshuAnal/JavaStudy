# HashMap

`HashMap`的实现原理是**基于哈希表**的，**底层是一个数组**，每个数组的每个单元可能是一个**链表或者红黑树**，也可能只是一个键值对。

当添加一个键值对时，`HashMap`会根据键的哈希值计算出对应的数组下标，然后将该键值对插入对应的位置。当通过键查找值的时候，`HashMap`也会根据键的哈希值计算出数据下标，并查找对应的值。

- `HashMap`集合的`key`是无序且不可重复的
  - 无序：取出顺序和插入顺序不一定相同
  - 不可重复：`key`具有唯一性
  - 如果`key`是自定义类型的话，那么要重写`euqals()`和`hashCode()`
- `HashMap`底层是哈希表
  - 哈希表可以是：数组+链表、数组+红黑树、数组+链表+红黑树
    - 当桶中节点数达到 **8** 时，链表转换为红黑树（前提是桶的总元素数量超过 **64**，以避免小容量时频繁转换）
    - 当桶中节点数降到 **6** 或以下时，红黑树会退化为链表。
- `HashMap` **不是线程安全的**，多线程场景下应使用 `ConcurrentHashMap`。
- `HashMap`允许一个`null`键，允许多个值为`null`
- **扩容机制**：
  - 当元素数量超过 **容量 * 负载因子** 时，`HashMap` 会进行扩容（默认负载因子为 0.75）。
  - 扩容时容量加倍，并重新分配所有元素的位置。



## 1. 核心结构

```java
public class HashMap<K,V> extends AbstractMap<K,V>
    				implements Map<K,V>, Cloneable, Serializable {
    @java.io.Serial
    private static final long serialVersionUID = 362498820763181265L;
    
    transient Node<K,V>[] table;      // 存储元素的数组（哈希桶）
	transient int size;              // 当前键值对的数量
	int threshold;                   // 扩容阈值（容量 * 负载因子）
	final float loadFactor;          // 负载因子
}
```

- **哈希桶（table）**：
  `Node<K, V>[]` 数组是存储键值对的核心结构。每个位置是一个桶，桶中元素可能是链表或红黑树。

- **负载因子（loadFactor）**：
  控制扩容的阈值，默认值为 `0.75`，表示哈希桶填充到 75% 时会触发扩容，这是时间和空间效率的一个平衡点

- **扩容阈值（threshold）**：
  用于判断是否需要扩容，值为 `capacity * loadFactor`，初始时由 `tableSizeFor(initialCapacity)` 计算得出。

- **Node 类**：
  每个键值对存储在 `Node` 中，`Node` 是一个内部静态类：

  ```java
  static class Node<K,V> implements Map.Entry<K,V> {
      final int hash;           // 哈希值
      final K key;              // 键
      V value;                  // 值
      Node<K,V> next;           // 指向下一个节点（链表或树节点）
  
      Node(int hash, K key, V value, Node<K,V> next) {
          this.hash = hash;
          this.key = key;
          this.value = value;
          this.next = next;
      }
  }
  ```



## 2. 核心方法

#### 2.1 初始化

1. **默认构造方法**

不指定初始容量，并且延迟初始化哈希表（避免浪费内存）。默认负载因子`LoadFactor`为`0.75`，当填充超过75%时进行扩容

```java
public HashMap() {
    this.loadFactor = DEFAULT_LOAD_FACTOR; // 负载因子默认为 0.75
}
```

在插入元素前，`table`一直是`null`

当首次插入元素后，会调用`resize()`分配哈希桶，默认容量是16，扩容阈值是 16 * 0.75 = **12**

```java
if ((tab = table) == null || (n = tab.length) == 0) {
    // 分配内存
    n = (tab = resize()).length;
}
```



2. **指定容量构造**

根据用户指定的初始容量，计算适合的哈希表大小（取 2 的幂次）。

```java
public HashMap(int initialCapacity) {
    // 调用的就是第三个构造方法，这里还是默认负载因子为0.75
    this(initialCapacity, DEFAULT_LOAD_FACTOR);
}
```



3. **指定初始容量和负载因子**

用户可以自定义负载因子，影响扩容阈值的计算

`tableSizeFor`用于将用户指定的 `initialCapacity` 转换为**大于或等于**它的最小 **2 的幂次值**。哈希表的容量必须是2的幂，**以便通过位运算快速计算哈希桶索引**

```java
public HashMap(int initialCapacity, float loadFactor) {
    if (initialCapacity < 0)
        throw new IllegalArgumentException("Illegal initial capacity: " + initialCapacity);
    if (loadFactor <= 0 || Float.isNaN(loadFactor))
        throw new IllegalArgumentException("Illegal load factor: " + loadFactor);
    
    // 指定负载因子
    this.loadFactor = loadFactor;
    // 计算实际初始化时的扩容阈值（threshold）
    this.threshold = tableSizeFor(initialCapacity);
}

static final int tableSizeFor(int cap) {
    // 防止输入本身就是 2 的幂时，导致多扩展一倍
    int n = cap - 1;
    // 用于将低于最高位的所有位都置为1
    n |= n >>> 1;
    n |= n >>> 2;
    n |= n >>> 4;
    n |= n >>> 8;
    n |= n >>> 16;
    // 返回n + 1
    return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
}
```

初始化之后，哈希桶也是`null`，它的分配也是延迟到首次调用`put`方法的时候。也就是这种构造方法实际上只设置了`threshold`。



4. **从其他 Map 初始化**

将传入的 `Map` 中的所有键值对插入到 `HashMap` 中。

```java
public HashMap(Map<? extends K, ? extends V> m) {
    this.loadFactor = DEFAULT_LOAD_FACTOR;
    putMapEntries(m, false);
}
```

> 1. 为什么容量一定是2的幂次？
>
>    高效计算索引位置
>
>    在`HashMap`中，元素在哈希桶中的位置是这样计算出来的
>
>    ```java
>    index = (n - 1) & hash
>    ```
>
>    - 当**容量为2的幂次**时， `n - 1`的二进制是全1的形式
>
>      比如 n = 16（10000）， n - 1 = 15 （01111）
>
>      按位与操作`&`可以很高效地限制索引在`[0, n - 1]`这个范围，使得**索引分布均匀且高效**
>
>    - 当**容量不为2的幂次**时，`n - 1`的二进制形式不规则
>
>      这导致按位与操作**无法均匀地分布哈希值**，出现**哈希冲突**的可能性较大
>
>    所以在`HashMap`的构造方法中，即使我们传入的初始容量不是2的幂次方，它也会通过调用`tableSizeFor`方法来调整
>
>    
>
> 2. 为什么要延迟加载呢
>
>    延迟加载是指 **对象初始化时不直接分配资源，而是在第一次需要使用时才分配**
>
>    在 `HashMap` 中，表现在：
>
>    - 使用构造方法创建 `HashMap` 时，`table` 数组未分配，仍然是 `null`。
>    - 当第一次插入元素（`put` 方法）时，才通过 `resize` 方法分配哈希桶数组。
>
>    原因如下
>
>    - **减少不必要的内存**
>
>      如果初始化后分配默认大小的哈希桶但不用，会浪费内存。延迟加载保证了只有在真正需要存储数据的时候，才分配哈希桶，从而**节省内存**
>
>    - **提高性能**（避免不必要的初始化）
>
>      延迟加载避免了无意义的初始化操作，尤其在大量使用短生命周期`HashMap`时，显著提升性能
>
>    - **支持灵活的容量分配**
>
>      当真正需要存储数据时，`HashMap` 会根据 `tableSizeFor` 方法计算出适合的容量，并分配哈希桶。
>
>    - **符合懒加载的设计原则**
>
>      
>
> 3. 为什么负载因子默认是0.75
>
>    **加载因子（Load Factor）默认值为 0.75** 是一种**平衡了时间复杂度与空间效率**的设计选择。
>
>    - **既保证了**查找性能（较低的哈希冲突概率），**又避免了频繁扩容**。
>    - 大约有 25% 的哈希桶空闲，避免了存储密度过高导致的性能退化。
>
>    这个值是通过大量实验和实践得出的，在大多数使用场景下提供了较高的性能和内存利用率。
>
>    - **较小的负载因子**
>
>      会频繁触发扩容机制，即使还有大量的哈希桶尚未利用
>
>      每次扩容都要重新分配新的数组并迁移数据，增加内存和CPU开销
>
>      而且更多的空间浪费会对JVM的垃圾回收造成压力
>
>    - **较大的负载因子**
>
>      哈希桶越满则哈希冲突发生的概率就越大
>
>      哈希冲突会导致链表或红黑树越来越庞大，从而查找性能会退化





#### 2.2 put







#### 2.3 remove







#### 2.4 resize

`resize()` 方法不仅用于扩容，也用于初始化 `HashMap`。

- 首先获取当前哈希表的状态

- 判断当前哈希表的容量，并计算新容量和扩容阈值

  - 当前**已有容量**

    - 当前容量 ≥ 最大容量

      直接将**新扩容阈值**设置为`Integer.MAX_VALUE`，然后**直接返回**当前哈希桶

    - 否则将**新容量设置为当前容量的2倍**

      如果**新容量 ＜ 最大容量** 并且 **当前容量 ＞ 默认容量16**，则将**新扩容阈值设置为当前扩容阈值的两倍**

  - 哈希表**尚未初始化**，但是已经有了**扩容阈值**（构造函数规定了预定容量，第一次调用`put`）

    - 直接将**新容量设置为扩容阈值**

  - 哈希表通过默认构造方法初始化的，没有容量和扩容阈值，第一次调用`put`

    - 将**新容量**设置为默认容量16
    - 将新扩容阈值设置为 **新容量 * 负载因子** = 12

- 如果新扩容阈值还没设置，那么就根据公式 **新容量 * 负载因子** 来计算
  如果 新容量 或者 新扩容阈值 ≥ 最大容量，那么将**新扩容阈值**设置为 `Integer.MAX_VALUE`

- 创建新的哈希桶，容量为计算出的**新容量**，然后将新的哈希桶数组赋值给该哈希表对象的`table`

- 遍历原哈希桶 `oldTab` 中的每个桶，将其中的元素迁移到新桶中。

  

```java
final Node<K,V>[] resize() {
    //获取当前哈希表的状态
    Node<K,V>[] oldTab = table;
    int oldCap = (oldTab == null) ? 0 : oldTab.length;
    int oldThr = threshold;
    int newCap, newThr = 0;
    
    // 判断当前哈希表的容量并计算新容量和扩容阈值
    // （1）已有容量
    if (oldCap > 0) {
        // 当前容量 ≥ 最大容量了，就把扩容阈值设置为Integer.MAX_VALUE
        if (oldCap >= MAXIMUM_CAPACITY) {
            threshold = Integer.MAX_VALUE;
            return oldTab;
        }
        // 将 新容量 设置为 当前容量 的两倍
        // 如果新容量 ＜ 最大容量 并且 旧容量 ≥ 默认容量16，那么将 新扩容阈值 置为 旧扩容阈值的两倍
        else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                 oldCap >= DEFAULT_INITIAL_CAPACITY)
            newThr = oldThr << 1;
    }
    
    // （2）哈希表尚未初始化，但是设置了预定容量，已经有了扩容阈值
    else if (oldThr > 0) 
        // 将容量设置为扩容阈值
        newCap = oldThr;
    
    // （3）调用的默认构造方法
    else {           
        // 将新容量设置为默认容量16
        newCap = DEFAULT_INITIAL_CAPACITY;
        // 将新阈值设置为 默认容量16 * 默认负载因子0.72 = 12
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
    }
    
    // 如果新扩容阈值还没设置，那么就根据公式 新容量 * 负载因子 来计算
    // 如果 新容量 或者 新扩容阈值 ≥ 最大容量，那么将新扩容阈值设置为 Integer.MAX_VALUE
    if (newThr == 0) {
        float ft = (float)newCap * loadFactor;
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                  (int)ft : Integer.MAX_VALUE);
    }
    threshold = newThr;
    
    // 创建新的哈希桶数组
    @SuppressWarnings({"rawtypes","unchecked"})
    Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    table = newTab;
    
    // 将原有数据迁移到新哈希桶
    if (oldTab != null) {
        // 遍历原哈希桶 oldTab 中的每个桶，将其中的元素迁移到新桶中
        for (int j = 0; j < oldCap; ++j) {
            Node<K,V> e;
            if ((e = oldTab[j]) != null) {
                oldTab[j] = null;
                if (e.next == null)
                    newTab[e.hash & (newCap - 1)] = e;
                else if (e instanceof TreeNode)
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                else { 
                   // preserve order
                   // ....
                }
            }
        }
    }
    return newTab;
}
```



1. **为什么要扩容**

`HashMap` 的核心思想是通过哈希函数将键值对分布到数组的不同桶中。当哈希桶装满时，多个元素会被分配到同一个桶，形成链表或红黑树。冲突越多，查找效率就越差。

扩容的必要性就在于，它保证了哈希桶的负载均匀分布，减少哈希冲突，维持哈希表的查找高效率



2. **为什么扩容是翻倍**

- 快速分布新的哈希桶

  容量翻倍后，所有元素重新计算哈希值，可以有效减少冲突。并且翻倍后，使得哈希值的计算秩序额外检查最高位是否为1，这一位的差异决定了元素的分布位置（低位分组、高位分组），不需要完全计算哈希值

  ```java
  if ((e.hash & oldCap) == 0) {
      // 低位分组：位置保持不变
  } else {
      // 高位分组：位置移动到 `index + oldCap`
  }
  ```

- 保证容量是2的幂次

  上面已经说过

- 减少扩容频率

  每次翻倍，容量增加一倍，可以延长下一次扩容的时间，减少扩容堆性能的影响

  

3. **为什么重新分配元素**

   扩容时将旧哈希桶的元素重新分不到新哈希桶中是为了保证元素在新哈希桶中的分布的均匀性，降低哈希冲突。

