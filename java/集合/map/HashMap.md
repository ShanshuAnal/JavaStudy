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
    
    transient Node<K,V>[] table;      // 存储元素的数组（哈希桶数组）
	transient int size;              // 当前键值对的数量
	int threshold;                   // 扩容阈值（容量 * 负载因子）
	final float loadFactor;          // 负载因子
}
```

- **哈希桶数组（table）**：
  `Node<K, V>[]` 数组是存储键值对的核心结构。每个位置是一个桶，桶中元素可能是链表或红黑树。

- **负载因子（loadFactor）**：
  控制扩容的阈值，默认值为 `0.75`，表示哈希表填充到 75% 时会触发扩容，这是时间和空间效率的一个平衡点

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

当首次插入元素后，会调用`resize()`分配哈希表，默认容量是16，扩容阈值是 16 * 0.75 = **12**

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

初始化之后，哈希表也是`null`，它的分配也是延迟到首次调用`put`方法的时候。也就是这种构造方法实际上只设置了`threshold`。



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
>    在`HashMap`中，元素在**哈希表中的索引下标**是这样计算出来的
>
>    ```java
>    hash = hash(key);
>    index = (n - 1) & hash
>    ```
>
>    当**容量为2的幂次**时， `n - 1`是一个奇数，奇数的二进制最后一位是1，它保证了`(n - 1) & hash`的最后一位既可能为1，也可能为0，这取决于哈希值的最后一位
>
>    也就说与运算的结果**既可能是偶数，也可能是奇数**，这样便可以保证了索引下标的**均匀性**。
>
>    
>
>    与操作的结果就是**将哈希值的高位全部归0，只保留低位值，用于做索引下标**（n - 1就相当于一个底位掩码）
>
>    例子：
>
>    ​	比如有哈希值 `10100101 11000100 00100101`，用它做取模运算，
>
>    ​	哈希表容量为16，16 - 1是15 `00000000 00000000 00001111`（高位用 0 来补齐）
>
>    ​	那么有：
>
>    ```java
>    	10100101 11000100 00100101
>    &	00000000 00000000 00001111
>    ----------------------------------
>    	00000000 00000000 00000101
>    ```
>
>    ​	15的高位全是0，所以与运算的结果肯定也为0，只剩下4个低位`0101`，换成十进制就是5
>
>    ​	这就意味着将哈希值为 `10100101 11000100 00100101`的键值对放在哈希桶数组的第5位
>
>    
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
>      如果初始化后分配默认大小的数组但不用，会浪费内存。延迟加载保证了只有在真正需要存储数据的时候，才分配数组，从而**节省内存**
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
>    **加载因子（Load Factor）默认值为 0.75** 是一种**平衡了时间复杂度与空间效率**的设计选择。**既保证了**查找性能（较低的哈希冲突概率），**又避免了频繁扩容**。并且大约有 25% 的哈希桶空闲，避免了存储密度过高导致的性能退化。
>
>    - **较小的负载因子**
>    
>   会频繁触发扩容机制，即使还有大量的哈希桶尚未利用
>    
>   每次扩容都要重新分配新的数组并迁移数据，增加内存和CPU开销
>    
>   而且更多的空间浪费会对JVM的垃圾回收造成压力
>    
> - **较大的负载因子**
>    
>   数组越满则哈希冲突发生的概率就越大
>    
>   哈希冲突会导致链表或红黑树越来越庞大，从而查找性能会退化



#### 2.2 计算哈希值

hash 方法的主要作用是将 `key` 的 hashCode 值进行处理，得到最终的哈希值，用于确定该键值对在哈希桶数组的**索引下标**。

当`key`为`null`时，其哈希值直接为0。

```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

`key == null ? 0 : (h = key.hashCode()) ^ (h >>> 16)`

- 这是一个三目运算符，如果键值为null，则哈希码为0；

- 否则，通过调用`hashCode()`方法获取**键的哈希码**，并将其与**右移16位的哈希码**进行**异或**运算，得到最终的哈希值（PS：**键的哈希码** ≠ **最终的哈希值**）

> `^` 运算符：**异或**运算符是Java中的一种位运算符，它用于将两个数的二进制位进行比较
>
> 相同则为0，不同则为1
>
> `h >>> 16`：将哈希码向右移动16位，相当于将原来的哈希码分成了两个16位的部分。



理论上哈希值是一个`int`类型，范围从-2147483648 到 2147483648，前后加起来近40亿的映射空间，只要哈希值映射得比较松散，一般是不会出现哈希碰撞，但是一个40亿长度的数组内存是放不下的。

`HashMap`在默认初始化第一次添加元素的时候，数组容量大小只有16，所以哈希值是不可以直接拿来用的，用之前要**和数组的长度做取模运算**`index = (n - 1) & hash`，这个取模操作的目的是将哈希值映射到桶的索引上

> 在计算机中，取模运算和取余运算是不一样的，它们的差别在于，当被除数为负数的时候
>
> - 取模运算的结果符号和被除数相同，-10 mod 3 = -1
> - 取余运算的结果符号和除数相同，     -10 % 3 = 2
>
> 在Java中，取模运算用的是%，取余运算用的是`Math.floorMod()`



**至于为什么不直接用`key`的哈希码作为哈希值**

![image-20250106192744985](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250106192744985.png)

某哈希码为 `11111111 11111111 11110000 11101010`

将它右移 16 位，得 `00000000 00000000 11111111 11111111`

再进行异或操作，得 `11111111 11111111 00001111 00010101`，这就是最终的哈希值

由于混合了哈希码的的高位和低位，从而掺杂了部分高位的特征，使得高位的信息也得到了保留，所以低位的随机性加大了。

再与数组容量 - 1进行取模运算，得到索引下标 `00000000 00000000 00000000 00000101`，也就是 **5**



如果不用`hash`方法进行优化，直接用`key`的哈希码和`n-1`进行取模操作的话

这个哈希码和 `00000000 10100101 11000100 00100101`的计算结果都是5，发生了哈希碰撞

但使用`hash`方法进行优化之后，新哈希码通过计算得到的哈希值是`00000000 10100101 00111011 10000000`

再与`n-1`做取模操作得到的下标为0



所以，`hash`方法是用来做**哈希值优化**的，将`key`哈希码的高位与低位进行异或操作，得到一个新的哈希值，**混合了原哈希码中的高位和低位**，从而**增加了随机性**，让**数据元素更加均衡的分布，减少碰撞。**







#### 2.3 添加元素

将一个键值对插入到`HashMap`中就可以用`put`方法；想修改某个键对应的值时，也可以直接用`put`方法，因为键是唯一的，所以再次`put`的时候会覆盖掉原来的值。

下面详细剖析 `HashMap` 的 `put()` 方法及其核心实现 `putVal()` 方法，包括了哈希计算、元素插入、冲突处理和扩容触发机制等关键部分。

注意，由于当`key`为`null`时哈希值为0，所以桶索引下标为`(n - 1) & hash = 0`，也就是说 null 会插入到 HashMap 的第一位。

```java
public V put(K key, V value) {
    // 传入参数：
    // 1. 由key计算出的哈希值
    // 2. 键 值
    // 3. 是否只在键不存在时插入（默认false）
    // 		false：无条件更新值（默认行为）； true：只在 键不存在 或者 值为null 时更新
    // 4. 标识是否可以移除（一般用于LinkedHashMap）
	return putVal(hash(key), key, value, false, true);
}

final V putVal(int hash, K key, V value, boolean onlyIfAbsent, boolean evict) {
    Node<K,V>[] tab; Node<K,V> p; int n, i;
    
    // 用于判断数组是否已经初始化，若未初始化则调用resize进行延迟初始化
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length;
    
    // 定位插入位置
    // 根据（n - 1）& hash计算出桶索引
    // 如果桶table[i]为空，则直接在此创建新节点
    if ((p = tab[i = (n - 1) & hash]) == null)
        tab[i] = newNode(hash, key, value, null);
    
    // 如果桶table[i]不为空，那么就要处理哈希冲突
    else {
        // 使用e保存找到的节点，它表示键值对 key -> value
        Node<K,V> e; K k;
        
        // 如果桶中的节点的hash和key都与插入的键值对相同，使用e指向它
        if (p.hash == hash && ((k = p.key) == key || (key != null && key.equals(k))))
            e = p;
        
        // 如果p是红黑树节点，那么调用putTreeVal方法，在红黑树中完成插入或更新
        else if (p instanceof TreeNode)
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        
        // 如果p是链表节点，那么就遍历链表节点
        else {
            for (int binCount = 0; ; ++binCount) {
                // 如果链表尾部仍未找到相同的键，那么直接新增节点到链表末尾
                if ((e = p.next) == null) {
                    p.next = newNode(hash, key, value, null);
                    
                    // 当链表长度达到阈值（TREEIFY_THRESHOLD = 8），将链表转换为红黑树。
                    if (binCount >= TREEIFY_THRESHOLD - 1)
                        treeifyBin(tab, hash);
                    break;
                }
                // 如果找到相同的键，则直接跳出循环
                if (e.hash == hash && 
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    break;
                
                // 更新p节点 
                p = e;
            }
        }
        
        // 键已存在，更新已存在的键对应的值并返回旧值
        if (e != null) { 
            // 记录旧值
            V oldValue = e.value;
            
            // 如果当前是 无条件更新值 或 有条件更新且当前值为null 的时候，更新值
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            
            // 这是一个钩子方法，用于在访问节点后执行某些操作
            // 在HashMap中此方法体是空的，在LinkedHashMap中，可能用于调整节点顺序
            afterNodeAccess(e);
            
            //返回旧制
            return oldValue;
        }
    }
    // 更新修改计数器，用于支持fast-fail机制
    ++modCount;
    
    // 如果当前容量 ＞ 最小容量阈值了，就要扩容
    if (++size > threshold)
        resize();
    afterNodeInsertion(evict);
    
    // 如果插入新的键值对，那么返回null
    return null;
}
```



注意添加新节点处不是直接`new`一个节点对象，而是调用`newNode`方法，由该方法创建并返回。虽然这个在HashMap中没什么用，但是在`LinkedHashMap`中进行了重写，用于实现顺序插入。

```java
Node<K,V> newNode(int hash, K key, V value, Node<K,V> next) {
    return new Node<>(hash, key, value, next);
}
```

Java 8 中，当链表的节点数超过一个阈值（8）时，链表将转为红黑树（节点为TreeNode），红黑树是一种高效的平衡树结构，能够在 `O(log n)` 的时间内完成插入、删除和查找等操作。这种结构在节点数很多时，可以提高 HashMap 的性能和可伸缩性。

> 因为TreeNode的大小大约是常规链表节点的两倍，所以只有当桶内包含足够多的节点时才使用红黑树
>
> 参见TREEIFY_THRESHOLD「阈值，值为8」，节点数量较多时，红黑树可以提高查询效率
>
> 由于删除元素或者调整数组大小时，红黑树可能会被转换为链表（节点数量小于 8 时），节点数量较少时，链表的效率比红黑树更高，因为红黑树需要更多的内存空间来存储节点。在具有良好分布的hashCode使用中，很少使用红黑树。
>



#### 2.4 删除元素



```java
// 给定key删除对应的键值对，返回被删除的值
public V remove(Object key) {
	Node<K,V> e;
	return (e = removeNode(hash(key), key, null, false, true)) == null ? null : e.value;
}

// 这是 HashMap 删除操作的核心方法
// matchValue：是否要求同时匹配值，true表示只有在键、值同时匹配的时候才删除
// movable：是否允许调正节点位置，通常为true
final Node<K,V> removeNode(int hash, Object key, Object value,
                           boolean matchValue, boolean movable) {
    Node<K,V>[] tab; 
    Node<K,V> p; 
    int n, index;
    
    // 快速定位到数组tab[index]
    if ((tab = table) != null && (n = tab.length) > 0 &&
        (p = tab[index = (n - 1) & hash]) != null) {
        
        Node<K,V> node = null, e; 
        K k; 
        V v;
        
        // 如果桶头节点的 hash 和 key 匹配，找到目标节点 node
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
        node = p;
        
        // 处理链表或红黑树 
        else if ((e = p.next) != null) {
            
            // 若是红黑树，则调用getTreeNode方法查找目标节点
            if (p instanceof TreeNode)
                node = ((TreeNode<K,V>)p).getTreeNode(hash, key);
            
            // 遍历链表中的每个节点
            else {
                do {
            		// 比较 hash 和 key，找到匹配节点后退出循环
                    if (e.hash == hash && 
                        ((k = e.key) == key || (key != null && key.equals(k)))) {
                        node = e;
                        break;
                    }
                    p = e;
                } while ((e = e.next) != null);
            }
        }
        
        // 验证删除条件
        if (node != null && (!matchValue || (v = node.value) == value ||
							(value != null && value.equals(v)))) {
            // 目标节点是红黑树节点，调用 removeTreeNode 方法调整红黑树结构
            if (node instanceof TreeNode)
                ((TreeNode<K,V>)node).removeTreeNode(this, tab, movable);
            
            // 如果目标节点是桶的头节点，将桶头指针指向头节点的下一个节点
            else if (node == p)
                tab[index] = node.next;
            // 如果目标节点在链表中间或尾部，调整前一个节点的 next 指针
            else
                p.next = node.next;
            
            // 更新状态
            ++modCount;
            --size;
            // 子类可扩展的操作，默认无具体逻辑
            afterNodeRemoval(node);
            return node;
        }
    }
    return null;
}
```

`afterNodeRemoval(node);`在HashMap中是空实现，在LinkedHashMap中用于将该节点从双链表中删除

#### 2.5 查询元素

```java
// 根据键获取对应的值。
public V get(Object key) {
    Node<K,V> e;
    // 调用getNode方法获取目标节点，如果节点存在返回其值，否则返回null
    return (e = getNode(key)) == null ? null : e.value;
}
```



**主要流程**：

1. 数组定位

2. 如果哈希表`table`不为空且桶的数量 `n > 0`

   - 计算哈希值 `hash = hash(key)`
   - 定位桶的索引：`(n - 1) & hash`

3. 检查桶头节点

   如果头节点 `first` 的哈希值与键匹配，直接返回头节点

4. 遍历后续节点

   如果存在后续节点，判断结构类型：

   - **红黑树**：调用 `getTreeNode(hash, key)` 方法在红黑树中查找目标节点
   - **链表**：遍历链表逐个匹配节点，依次比较哈希值和键

5. 未找到节点

   返回 `null`

```java
// 根据键查找对应的节点
final Node<K,V> getNode(Object key) {
    Node<K,V>[] tab; Node<K,V> first, e; int n, hash; K k;
    
    // 检查哈希表是否初始化，且对应索引下标的桶是否有存储元素
    if ((tab = table) != null && (n = tab.length) > 0 &&
        (first = tab[(n - 1) & (hash = hash(key))]) != null) {
        
        // 检查第一个节点是否能匹配上，匹配上就直接返回第一个节点
        if (first.hash == hash && // always check first node
            ((k = first.key) == key || (key != null && key.equals(k))))
            return first;
        
        // 如果有后续节点，那么继续检查
        if ((e = first.next) != null) {
            
            // 如果是树节点，调用getTreeNode查找目标节点
            if (first instanceof TreeNode)
                return ((TreeNode<K,V>)first).getTreeNode(hash, key);
            
            // 如果是链表，则逐一进行匹配
            do {
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    return e;
            } while ((e = e.next) != null);
        }
    }
    
    // 未找到匹配节点，直接返回null
    return null;
}
```



#### 2.6 扩容机制

`resize()` 方法不仅用于扩容，也用于初始化 `HashMap`。

- 首先获取当前哈希表的状态

- 判断当前哈希表的容量，并计算新容量和扩容阈值

  - 当前**已有容量**

    - 当前容量 ≥ 最大容量

      直接将**新扩容阈值**设置为`Integer.MAX_VALUE`，然后**直接返回**当前哈希表

    - 否则将**新容量设置为当前容量的2倍**

      如果**新容量 ＜ 最大容量** 并且 **当前容量 ＞ 默认容量16**，则将**新扩容阈值设置为当前扩容阈值的两倍**

  - 哈希表**尚未初始化**，但是已经有了**扩容阈值**（构造函数规定了预定容量，第一次调用`put`）

    - 直接将**新容量设置为扩容阈值**

  - 哈希表通过默认构造方法初始化的，没有容量和扩容阈值，第一次调用`put`

    - 将**新容量**设置为默认容量16
    - 将新扩容阈值设置为 **新容量 * 负载因子** = 12

- 如果新扩容阈值还没设置，那么就根据公式 **新容量 * 负载因子** 来计算
  如果 新容量 或者 新扩容阈值 ≥ 最大容量，那么将**新扩容阈值**设置为 `Integer.MAX_VALUE`

- 创建新的数组，容量为计算出的**新容量**，然后将新的数组赋值给该哈希表对象的`table`

- 遍历原数组 `oldTab` 中的每个桶，将其中的元素迁移到新桶中。


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
    
    // 创建新数组
    @SuppressWarnings({"rawtypes","unchecked"})
    Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    table = newTab;
    
    // 将原有数据迁移到新哈希表
    // 如果旧哈希表不为空
    if (oldTab != null) {
        // 遍历原哈希表 oldTab 中的每个桶，将其中的元素迁移到新桶中
        for (int j = 0; j < oldCap; ++j) {
            Node<K,V> e;
            // 如果该元素不为空
            if ((e = oldTab[j]) != null) {
                // 将旧数组中该位置的元素置为 null，以便垃圾回收
                oldTab[j] = null;
                
                // 如果该元素没有冲突，也就是该桶中没有其他的键值对节点了
                // 就直接将这个节点放入新数组（要重新计算索引下标）
                if (e.next == null)
                    newTab[e.hash & (newCap - 1)] = e;
                
                // 如果该节点是树节点
                // 那么直接将该树分为两个节点
                // 如果分裂后的桶节点数量低于阈值（UNTREEIFY_THRESHOLD=6），则将红黑树转换回链表。
                // 如果分裂后的桶节点≥6，那么保留为红黑树
                else if (e instanceof TreeNode)
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                
                // 如果该节点是链表
                else { 
                  	Node<K,V> loHead = null, loTail = null; // 低位链表的头结点和尾结点
                    Node<K,V> hiHead = null, hiTail = null; // 高位链表的头结点和尾结点
                    Node<K,V> next;
                    do {
                        next = e.next;
                        // 如果增加的1bit是0，说明在低位链表，索引不变
                        if ((e.hash & oldCap) == 0) {
                            // 如果低位链表还没有结点
                            // 将该元素作为低位链表的头结点
                            if (loTail == null)
                                loHead = e;
                             // 如果低位链表已经有结点，将该元素加入低位链表的尾部
                            else
                                loTail.next = e;
                            // 更新低位链表的尾结点
                            loTail = e;
                        }
                        
                        // 如果增加的1bit是1，那么说明在高位链表中
                        else {
                            // 如果高位链表还没有结点
                            // 将该元素作为高位链表的头结点
                            if (hiTail == null)
                                hiHead = e;
                            // 如果高位链表已经有结点，将该元素加入高位链表的尾部
                            else
                                hiTail.next = e;
                            // 更新高位链表的尾结点
                            hiTail = e;
                        }
                    } while ((e = next) != null);
                    
                    // 如果低位链表不为空
                    // 就把低位链表的尾节点指向null，以便垃圾回收
                    // 然后将低位链表作为新哈希表对应位置（原位置）的元素
                    if (loTail != null) {
                        loTail.next = null;
                        newTab[j] = loHead;
                    }
                    // 如果高位链表不为空
                    // 就把高位链表的尾节点指向null，以便垃圾回收
                    // 然后将高位链表作为新哈希表对应位置（原位置 + 旧容量）的元素 
                    if (hiTail != null) {
                        hiTail.next = null;
                        newTab[j + oldCap] = hiHead;
                    }
                }
            }
        }
    }
    return newTab;
}
```



1. **为什么要扩容**

`HashMap` 的核心思想是通过哈希函数将键值对分布到数组的不同桶中。当哈希表装满时，多个元素会被分配到同一个桶，形成链表或红黑树。冲突越多，查找效率就越差。

扩容的必要性就在于，它保证了哈希表的负载均匀分布，减少哈希冲突，维持哈希表的查找高效率



2. **为什么扩容是翻倍**

- **快速分布新的哈希表**（JDK8+）

  容量翻倍后，不用重新计算哈希值，可以有效减少冲突。只要看原来hash值新增的那个bit是1还是0

  如果是0的话，那就是索引不变；如果是1的话，索引就变成了“原索引 + 原来的容量”
  这个设计非常巧妙。省去了JDK7-之前重新计算hash的时间，同时由于新增的1 bit的值随机的(0 or 1)，因此扩容还可以将原有的节点均匀地分散到新的桶中

  ```java
  if ((e.hash & oldCap) == 0) {
      // 低位分组：位置保持不变
  } else {
      // 高位分组：位置移动到 `index + oldCap`
  }
  ```

  > 当前哈希表容量为16
  >
  > 假设key1的哈希值最后8位是0000 0101，key2的哈希值最后八位是 0001 0101，它们与 n-1 做与运算后的结果都是0101 = 5，都是在索引下标为5的桶中
  >
  >
  > 扩容后哈希表的容量为32
  >
  > key1和key2的哈希值重新与 n - 1 做与运算后的结果分别为 01010 = 5，11010 = 5 + 16 = 21
  >
  > ![image-20250106215417599](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250106215417599.png)

- **保证容量是2的幂次**

  上面已经说过

- 减少扩容频率

  每次翻倍，容量增加一倍，可以延长下一次扩容的时间，减少扩容堆性能的影响

  

3. **为什么重新分配元素**

   扩容时将旧哈希表的元素重新分不到新哈希表中是为了保证元素在新哈希表中的分布的均匀性，降低哈希冲突。



## 3. 线程不安全

#### 3.1 多线程下扩容会死循环

`HashMap`是通过拉链法来解决哈希冲突的，也就是当哈希冲突时，会将相同哈希值的键值对通过链表的形式存放起来。

JDK7时，采用的是头部插入法来存放链表的，也就是下一个冲突的键值对会在上一个键值对的前面。在多线程条件下进行扩容就可能导致出现环形链表，造成死循环。

不过JDK8+就修复了这个问题，扩容时会保持链表的原有顺序。



#### 3.2 多线程下put会导致元素丢失

正常情况下，当发生哈希冲突的时候，HashMap是这样：
<img src="https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250106233439018.png" alt="image-20250106233439018" style="zoom:50%;" />

但多线程同时执行`put`操纵的时候，如果计算出来的索引位置是相同的，那么会造成前一个key被后一个key覆盖，从而导致元素的丢失



#### 3.3 put和get并发时会导致get到null

两个线程并行操作，A执行put操作，因为元素个数超出阈值而出现扩容，B线程此时执行get，有可能导致这个问题。

主要问题发生在`resize`方法中

```java
@SuppressWarnings({"rawtypes","unchecked"})
Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
table = newTab;
```

当线程A执行完`table = newTab;`但还没执行元素迁移时，该哈希表还是空的。若此时线程A被挂起，线程B开始执行`get`操作，那么肯定返回的是`null`了



#### 3.4 小结

`HashMap`线程不安全主要是因为它在进行插入、删除和扩容的时候，会对数组的结构进行改变，从而破坏了其不变性。具体来说就是，如果在一个线程正在对`HashMap`的链表进行遍历的时候，另一个线程对该链表进行了修改，那么就会导致链表的结构发生变化，从而破坏了当前线程正在进行的遍历操作，可能导致遍历失败或者出现死循环等问题。

所以在多线程环境下，可用使用Java提供的线程安全的`HashMap`实现类`ConcurrentHashMap`，它的内部采用了分段锁，将整个Map拆分成了多个小的`HashMap`，每个小的HashMap都有自己的锁，不同线程可以同时访问不同的小Map，从而实现了线程安全。在进行插入、删除和扩容时，只需锁住当前的小Map，不会锁定真个Map，从而提高并发访问的效率。
