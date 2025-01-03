# ArrayList

`ArrayList` 是 Java 集合框架中最常用的集合类之一，继承自 `AbstractList` 并实现了 `List` 接口。它是一个基于**动态数组**的数据结构，用于**存储顺序集合**，

- 支持随机存取（通过**下标**直接存取）
- 可存储**重复**元素
- 可存`null`元素

- 如果内部数组的容量不足时会**自动扩容**

- 插入删除元素效率较低
- **线程不安全**，需要手动同步



#### 核心字段

```java
// 默认初始容量 10
private static final int DEFAULT_CAPACITY = 10; 
// 空数组，用于无参构造器，节省内存
private static final Object[] EMPTY_ELEMENTDATA = {}; 
// 用于懒加载的空数组，用于无参构造
private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {}; 
// 实际存储数据的数组，不可序列化
transient Object[] elementData; 
// 当前存储的元素数量
private int size; 
```

- **`EMPTY_ELEMENTDATA`** 是一个永远为空的数组。
- **`DEFAULTCAPACITY_EMPTY_ELEMENTDATA`** 是用来表示空 `ArrayList` 的“懒加载”标志，在没有元素添加前不分配空间，直到有元素插入才真正初始化。



#### 构造方法

1. 无参构造

创建一个初始容量为0的数组，第一次添加元素时，容量会扩展为默认初始容量10

```java
public ArrayList() {
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}
```

2. 有参构造

- 指定初始容量的构造

  用户可以通过此构造器显示定义数组的初始大小，若容量为负数，那么会抛出异常

```java
public ArrayList(int initialCapacity) {
    if (initialCapacity > 0) {
        this.elementData = new Object[initialCapacity];
    } else if (initialCapacity == 0) {
        this.elementData = EMPTY_ELEMENTDATA;
    } else {
        throw new IllegalArgumentException("Illegal Capacity: " + initialCapacity);
    }
}
```

- 通过集合初始化

```java
public ArrayList(Collection<? extends E> c) {
    elementData = c.toArray();
    size = elementData.length;
    // 确保 ArrayList 中的 elementData 数组始终是一个标准的 Object[] 类型数组
    if (elementData.getClass() != Object[].class)
        elementData = Arrays.copyOf(elementData, size, Object[].class);
}
```

​	针对注释部分进行说明：

​	确保 `ArrayList` 中的 `elementData` 数组始终是一个标准的 `Object[]` 类型数组，如果 `elementData` 	不是一个 `Object[]` 数组（即可能被意外或特殊的代码**改变了类型**），则通过 `Arrays.copyOf` 创建一个	新的 `Object[]` 数组，并将原数组中的元素复制到新的数组中。

​	`Arrays.copyOf` 会根据指定的目标类型（这里是 `Object[].class`）创建一个新的数组，将原始数据复制	到新数组中。

​	*即可能被意外或特殊的代码**改变了类型***是指	

- 某些代码通过反射或某些特殊的操作修改了 `elementData`，使其变成了一个非 `Object[]` 类型的数组

- 多线程操作使得 `ArrayList` 的内部实现发生变化，导致 `elementData` 的类型不是 `Object[]`。



#### 核心方法

##### **添加元素**

```java
public boolean add(E e) {
    // 修改操作计数器，防止并发修改异常（在iterator中讲过）
    modCount++;
    
    // 调用私有方法 add，将元素 e 添加到 ArrayList 的底层存储数组 elementData 中。
    add(e, elementData, size);
    return true;
}

private void add(E e, Object[] elementData, int s) {
    // 检查数组是否已满
    if (s == elementData.length)
        // 满了就调用扩容方法
        elementData = grow();
    // 存入新元素
    elementData[s] = e;
    size = s + 1;
}
```

关于为什么要将这一个功能拆分，主要目的是为了提高代码的可读性、灵活性和复用性

- 指责单一原则

  add(E e)是公共接口方法，专注于对外提供添加元素的功能接口；

  add(E e, Object[] elementData, int s) 是一个内部辅助方法，负责底层数组的操作

- 增强复用性

  内部辅助方法是通用的，可在其他场景中使用，比如其他方法要批量添加多个元素，就可以调用。

- 简化扩展和维护

  如果将来要修改add的底层逻辑，那么只要修改这一个就行了，而不用动其他add方法；

  同时add(E e)的接口定义不会因为内部实现的变化而受影响，保证了对外API的稳定性



**在指定位置添加**

```java
public void add(int index, E element) {
    rangeCheckForAdd(index);
    modCount++;
    final int s;
    Object[] elementData;
    // 当前容量 = 长度的时候，进行扩容 
    if ((s = size) == (elementData = this.elementData).length)
        elementData = grow();
    // 数组中从索引 index 开始的元素全部向右移动一位。
    System.arraycopy(elementData, index, elementData, index + 1, s - index);
    elementData[index] = element;
    size = s + 1;
}
```



##### 扩容

在代码中，扩容是通过调用 `grow()` 方法完成的。扩容的核心目的是解决数组容量固定的问题，因为数组一旦创建后长度是不可变的。

**扩容的策略**

- 默认扩容策略是按照原来数组大小`1.5倍`的一定比例进行增长
- 只有在数组空间不足时，才会执行扩容（懒执行）
- 扩容过程中使用 `Arrays.copyOf()` 来复制数据，确保元素顺利迁移到新的数组中。

```java
// 当size == element.length的时候，调用扩容函数
private Object[] grow() {
        return grow(size + 1);
}

// 负责根据当前size大小来扩容
private Object[] grow(int minCapacity) {
    // 当前数组容量
    int oldCapacity = elementData.length;
    // 如果当前数组已经有元素了 或者 当前数组不是处于初始状态（通过无参构造）
    if (oldCapacity > 0 || elementData != DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
        // 根据 当前容量、最小增长值 和 倾向增长值（当前容量的一半）获取新长度
        int newCapacity = ArraysSupport.newLength(oldCapacity,
                minCapacity - oldCapacity, /* minimum growth */
                oldCapacity >> 1           /* preferred growth */);
        // Arrays.copyOf()创建一个新的数组，并将旧数组中的元素拷贝到新数组中。
        return elementData = Arrays.copyOf(elementData, newCapacity);
    } else {
        // 是由无参构造法创建的，直接分配一个新数组
        // 长度为max(默认长度10, 最小长度)
        return elementData = new Object[Math.max(DEFAULT_CAPACITY, minCapacity)];
    }
}

// 在StringBuilder处接触过，是一样的
public static int newLength(int oldLength, int minGrowth, int prefGrowth) {
   	//  倾向容量为 = 当前容量 + max(最小增长值， 倾向增长值（当前容量的一半）)
   	int prefLength = oldLength + Math.max(minGrowth, prefGrowth); // might overflow
    // 如果 prefLength 在有效范围内，就返回作为新长度
    if (0 < prefLength && prefLength <= SOFT_MAX_ARRAY_LENGTH) {
        return prefLength;
    } else {
        // 如果 prefLength 不在范围内，就重新计算容量
        return hugeLength(oldLength, minGrowth);
    }
}

// 数组容量超过最大限制时，hugeLength 计算新的容量。
private static int hugeLength(int oldLength, int minGrowth) {
    // 最小容量 = 当前容量 + 最小增长值
    int minLength = oldLength + minGrowth;
    // 进行溢出检查，若小于0，表示容量溢出
    if (minLength < 0) {
        throw new OutOfMemoryError(
            "Required array length " + oldLength + " + " + minGrowth + " is too large");
    // minLength ≤ SOFT_MAX_ARRAY_LENGTH，返回 SOFT_MAX_ARRAY_LENGTH（软最大数组长度）。
    } else if (minLength <= SOFT_MAX_ARRAY_LENGTH) {
        return SOFT_MAX_ARRAY_LENGTH;
     // 负责返回minLength
    } else {
        return minLength;
    }
}
```



##### 获取元素

按索引获取元素。

如果索引超出范围，则抛出 `IndexOutOfBoundsException`。

```java
public E get(int index) {
    Objects.checkIndex(index, size);
    return elementData(index);
}

E elementData(int index) {
	return (E) elementData[index];
}
```



##### 删除元素

- 根据索引下标进行删除

```java
public E remove(int index) {
    // 如果 index ＜ 0 或 ≥ size，会抛出 IndexOutOfBoundsException。
    Objects.checkIndex(index, size);
    final Object[] es = elementData;

    @SuppressWarnings("unchecked")
    E oldValue = (E) es[index];
    fastRemove(es, index);
    
	// 返回被删除的元素。
    return oldValue;
}

private void fastRemove(Object[] es, int i) {
    modCount++;
    final int newSize;
    // 如果删除的元素不是最后一个，则需要将索引 i 之后的元素左移。
    if ((newSize = size - 1) > i)
        System.arraycopy(es, i + 1, es, i, newSize - i);
    // 将最后一个数组位置赋值为null，以便垃圾回收
    es[size = newSize] = null;
}
```

- 删除指定元素

```java
public boolean remove(Object o) {
    final Object[] es = elementData;
    final int size = this.size;
    int i = 0;
    
    // 找到元素o的下标（如果有多个，就返回第一个的下标）
    found: {
        if (o == null) {
            for (; i < size; i++)
                if (es[i] == null)
                    break found;
        } else {
            for (; i < size; i++)
                if (o.equals(es[i]))
                    break found;
        }
        return false;
    }
    // 根据下标进行删除
    fastRemove(es, i);
    return true;
}
```



##### 更新元素

```java
public E set(int index, E element) {
    Objects.checkIndex(index, size);
    E oldValue = elementData(index);
    elementData[index] = element;
    return oldValue;
}
```



##### 查找元素

```java
public int indexOf(Object o) {
    return indexOfRange(o, 0, size);
}

int indexOfRange(Object o, int start, int end) {
    Object[] es = elementData;
    // 如果是null的话，用不了equals，要单独出来
    if (o == null) {
        for (int i = start; i < end; i++) {
            if (es[i] == null) {
                return i;
            }
        }
    } else {
        for (int i = start; i < end; i++) {
            if (o.equals(es[i])) {
                return i;
            }
        }
    }
    return -1;
}
```

找某个重复元素的最后一个的下标

```java
public int lastIndexOf(Object o) {
    return lastIndexOfRange(o, 0, size);
}
// 跟indexOfRange差不多，就是反向找罢了
int lastIndexOfRange(Object o, int start, int end) {
    Object[] es = elementData;
    if (o == null) {
        for (int i = end - 1; i >= start; i--) {
            if (es[i] == null) {
                return i;
            }
        }
    } else {
        for (int i = end - 1; i >= start; i--) {
            if (o.equals(es[i])) {
                return i;
            }
        }
    }
    return -1;
}
```



##### 包含元素

找该元素的下标，找得到就是有，找不到（-1）就是没有

```java
public boolean contains(Object o) {
    return indexOf(o) >= 0;
}
```





##### 时间复杂度

| **操作**                                | **时间复杂度** | **说明**                                                     |
| --------------------------------------- | -------------- | ------------------------------------------------------------ |
| **查找**（`get(int index)`）            | O(1)           | **常数时间**，直接访问数组索引位置。                         |
| **查找**（`indexOf(Object o)`）         | O(n)           | 需要遍历数组，最坏情况下会查遍所有元素。                     |
| **插入**（`add(E e)`）                  | O(1)           | 如果没有达到容量，向数组**末尾插入**元素，**常数时间**。     |
| **插入**（`add(int index, E element)`） | O(n)           | 在指定位置插入元素时，**后续元素需要移动，**最坏情况下需要移动整个数组。 |
| **删除**（`remove(int index)`）         | O(n)           | 删除指定位置的元素，后续元素需要**向前移动**，最坏情况下需要移动整个数组。 |
| **删除**（`remove(Object o)`）          | O(n)           | 需要**查找元素位置**，然后删除，最坏情况下需要遍历整个数组。 |
| **修改**（`set(int index, E e)`）       | O(1)           | 直接在指定位置进行修改，**常数时间**。                       |
| **增加容量**（`grow()`）                | O(n)           | 当容量不足时，需要创建新数组并复制数据。                     |

















