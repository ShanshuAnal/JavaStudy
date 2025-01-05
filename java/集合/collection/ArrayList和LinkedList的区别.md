## 1  ArrayList是如何实现的

`ArrayList` 实现了 `List` 接口，继承了 `AbstractList` 抽象类。

<img src="https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/list-war-2-01.png" alt="img" style="zoom:33%;" />

底层是基于**数组**实现的，并实现了**动态扩容**（当需要添加新元素时，如果 `elementData` 数组已满，则会自动扩容，新的容量将是原来的 1.5 倍）

```java
public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable {
    // 默认容量为 10
    private static final int DEFAULT_CAPACITY = 10; 
    // 存储元素的数组，数组类型为 Object
    transient Object[] elementData; 
    // 列表的大小，即列表中元素的个数
    private int size; 
}
```



#### `RandomAccess` 接口

这是一个标记接口内部为空的，标记“实现了这个接口的类支持快速（固定时间）随机访问”。快速访问意味着不需要遍历，就可以通过**下标**直接访问到内存地址。`ArrayList`直接用`get(int i)`方法直接随机访问。

而`LinkedList`没有实现该接口，表示它**不支持随机访问**，需要通过遍历来访问元素

```java
public interface RandomAccess {
}
```



#### `Cloneable`接口

这表明它是支持克隆的，内部重写了`Object`类的`clone()`的方法

```java
public Object clone() {
    try {
        // 调用Object的clone方法，此时v.elementData和this.elementData相同
        ArrayList<?> v = (ArrayList<?>) super.clone();
        // Arrays.copyOf创建了一个新数组，并复制了原数组中的元素，然后返回
        v.elementData = (elementData, size);
        v.modCount = 0;
        return v;
    } catch (CloneNotSupportedException e) {
        // this shouldn't happen, since we are Cloneable
        throw new InternalError(e);
    }
}
```



`Arrays.copyOf(original, newLength)`

若不指定返回数组类型的话，那么默认返回类型和`original`一样

上面传入的是`elementData`，这个是`Object`类型的，那么最终返回的就是`Object`类型的数组

```java
public static <T> T[] copyOf(T[] original, int newLength) {
	return (T[]) copyOf(original, newLength, original.getClass());
}
```



`Arrays.copyOf(original, newLength, newType)`

这里将 `newType` 强制转换为 `Object`，目的是**避免泛型类型擦除**的影响，使比较基于原始类型（即 `Class` 对象）的内存地址，而不是基于泛型的擦除类型。

- 如果不传入第三个参数，就是通过上面的调用，那么`newType`就和原来类型一样。

  比如这里就是`Object[].class`

- 如果传入第三个参数，比如传入的是`Integer[].class`，那么此时的判断结果就是`false`。需要调用`newInstance`方法来创建`Integer[]`类型的数组对象。

```java
/**
* 将一个数组复制为指定的新长度，并返回新数组
* <T,U> 支持类型转换，允许复制数组时改变类型
* 
*/ 
@IntrinsicCandidate
public static <T,U> T[] copyOf(U[] original, int newLength, Class<? extends T[]> newType) {
    @SuppressWarnings("unchecked")
    // 比较的是newType和Object[].class是否是同一个Class对象
    T[] copy = ((Object)newType == (Object)Object[].class)
        ? (T[]) new Object[newLength]
        : (T[]) Array.newInstance(newType.getComponentType(), newLength);
    
    System.arraycopy(original, 0, copy, 0, Math.min(original.length, newLength));
    return copy;
}
```



`System.arraycopy(Object src, int srcPos, Object dest, int destPos, int length)`

Java 中用于高效地复制数组内容的一个**本地方法**

**类型检查：**

- 源数组和目标数组必须是**相同或兼容类型**。
- 如果类型不兼容，会抛出 `ArrayStoreException`。

**范围检查：**

- 如果索引超出数组范围（源数组或目标数组），会抛出 `IndexOutOfBoundsException`。
- 如果要复制的长度超出数组剩余空间，也会抛出异常。

**浅拷贝：**

- `System.arraycopy` 执行的是**浅拷贝**，仅复制数组元素的引用。
- 如果数组中存储的是对象，则复制的只是**引用**，两个数组的元素仍然指向同一个对象。



#### `Serializable` 接口

这也是一个标记接口，用于标记该类是否可以被**序列化**，内部也是空的

```java
public interface Serializable {
}
```

Java 的**序列化**是指，将对象转换成以字节序列的形式来表示，这些字节序中包含了对象的字段和方法。序列化后的对象可以被写到数据库、写到文件，也可用于网络传输。

注意到`elementData`使用了`transient`关键字，这意味着该数组不会被序列化

> 为什么`elementData`不能被序列化呢
>
> 1. 这个数组是一个**动态数组**，用于存储实际的列表元素，它的容量通常大于实际存储的元素个数（动态扩容策略），如过直接序列化，会导致有**大量的无用空余空间，浪费存储**。
>
> 2. 并且由于该数组属于`ArrayList`的内部实现细节，直接序列化到文件中**存在安全隐患**，反序列化后的`ArrayList`可能会被篡改或破坏，违反了封装性
>
> 3. 序列化是为了存储对象的**逻辑状态**而不是底层细节，该数组是底层实现的一部分，序列化时专注于元素部分（也就是size范围内的部分），而非数组的实际结构



`ArrayList`是通过两个私有方法`writeObject` 和 `readObject` 来完成序列化和反序列化的

```java
@java.io.Serial
private void writeObject(java.io.ObjectOutputStream s) throws java.io.IOException {
    int expectedModCount = modCount;
    
    // 默认序列化非 transient 字段
    s.defaultWriteObject();

    // 将有效元素的个数写入序列化流
    s.writeInt(size);

    // 将 size 个有效元素序列化
    for (int i=0; i<size; i++) {
        s.writeObject(elementData[i]);
    }

    // 并发修改检查
    if (modCount != expectedModCount) {
        throw new ConcurrentModificationException();
    }
}
```

```java
@java.io.Serial
private void readObject(java.io.ObjectInputStream s) throws java.io.IOException, ClassNotFoundException {

    // 调用默认的反序列化逻辑，恢复非 transient 字段
    s.defaultReadObject();

    // 这个值在反序列化过程中被忽略，
    // 因为 ArrayList 的实现基于动态数组，而容量不重要，关键是元素数量
    s.readInt(); // ignored

    // 列表中有实际元素
    if (size > 0) {
        // 调用内部的安全检查机制，确保即将分配的数组不会导致内存问题
        SharedSecrets.getJavaObjectInputStreamAccess().checkArray(s, Object[].class, size);
       
        // 根据实际元素数量（size），分配新的数组
        // 而不是基于序列化时的容量（capacity）
        Object[] elements = new Object[size];

        // 遍历序列化流，逐个恢复保存的元素
        for (int i = 0; i < size; i++) {
            elements[i] = s.readObject();
        }

        elementData = elements;
    } else if (size == 0) {
        // 将 elementData 指向共有的静态的空数组
        elementData = EMPTY_ELEMENTDATA;
    } else {
        throw new java.io.InvalidObjectException("Invalid size: " + size);
    }
}
```

关键点在于：

1. **动态数组恢复：**

   不直接使用序列化时的容量（capacity），而是根据 `size` 恢复数组，避免浪费空间。

2. **安全性检查：**

   使用 `checkArray` 检查 `size` 是否在合理范围，防止恶意输入导致内存分配问题。

3. **空数组优化：**

   对于空列表，直接使用共享的静态空数组，节省资源。

4. **数据校验：**

   如果 `size` 非法（如为负值），直接抛出异常，避免非法状态的对象被反序列化。



## 2 LinkedList是如何实现的

`LinkedList`是一个双向链表。它可以被当作**堆栈**、队列或者双向队列进行操作 。

```java
public class LinkedList<E>
    extends AbstractSequentialList<E>
    implements List<E>, Deque<E>, Cloneable, java.io.Serializable {
    
    transient int size = 0;

    transient Node<E> first;

    transient Node<E> last;
}
```

它同样实现了`Cloneable`接口，表示他是支持拷贝的，重写了`Object`的`clone`方法

他也实现了`Serializable`接口，表示它也支持序列化操作。它用`transient`修饰了size、first、last这几个关键字段。它同样声明了`readObject`和`writeObject`两个自定义序列化方法

`LinkedList`在序列化的时候只保留了元素中的item，并没有保存前后节点引用，这样是为了减少内存空间，等在反序列化的时候再重新链接起来。

```java
@j ava.io.Serial
private void writeObject(java.io.ObjectOutputStream s) throws java.io.IOException {
    // 写入默认的序列化标记
    s.defaultWriteObject();

    // 写入链表的节点个数
    s.writeInt(size);

	// 按正确的顺序写入所有元素
    for (Node<E> x = first; x != null; x = x.next)
        s.writeObject(x.item);
}
```

在`readObject`方法中，直接将从流中读取到的节点对象插入 到当前链表中，从而恢复了序列化之前的顺序。

```java
@java.io.Serial
private void readObject(java.io.ObjectInputStream s)
    throws java.io.IOException, ClassNotFoundException {
    // 读取默认的序列化标记
    s.defaultReadObject();

    // 读取链表的节点个数
    int size = s.readInt();

    // 读取元素并将其添加到链表末尾
    for (int i = 0; i < size; i++)
        linkLast((E)s.readObject());
}
```



`LinkedList`就没有实现`RandomAccess`借口了，也就是不支持随机访问，这是因为链表存储数据的内存地址不是连续的



## 3 对比

#### 3.1 新增元素

（1）ArrayList

在前面已经具体讲解了`ArrayList`插入元素有两种方式

- 添加到数组末尾

  如果容量足够不用扩容的话，直接添加到末尾即可

- 插入到指定位置

  先检查插入位置是否越界，然后需不需要扩容，这是前置操作

  检查完毕后，将指定位置的元素向后移动一位，然后直接插入元素

（2）LinkedList

它插入元素也有两种

- 插在队尾

  直接在尾节点后插入

- 插入到指定位置

  先检查插入位置的合法性

  如果插入的位置是末尾的话，直接调用第一种方法

  否则将节点插入到指定位置的前面节点的后面

  - 如果插入位置是在链表的前半部分，那么就从头节点开始从前往后找
  - 如果插入位置是在链表的后半部分，那么就从尾节点开始从后往前找
  - 这种插入方式意味着，插入的位置越靠近链表的**中间位置**，遍历所花费的**时间就越多**

（3）插入性能总结

- 从**头部**新增元素，**ArrayList 花费的时间多**，因为需要对头部以后的元素进行**复制后移**
- 从**中间**新增元素，**ArrayList 花费的时间搞不好要比 LinkedList 少**，因为 **LinkedList 需要遍历**
- 从**尾部**新增元素，**ArrayList 花费的时间少**，因为数组是一段连续的内存空间，也不需要复制数组；而链表需要创建新的对象，前后引用也要重新排列。





#### 3.2 删除元素

（1）ArrayList

- 删除指定元素，需要先遍历数组，找到索引，然后直接把该位置后的元素往前移动一位
- 删除指定下标元素，先检查下标的合法性，直接把然后直接把该位置后的元素往前移动一位

`ArrayList`侧重于找下标，所以两种删除方式殊途同归。只要删除元素的**位置越靠前，则代价则越大**

（2）LinkedList

- 删除指定下标元素，先检查下标的合法性，在调用`node()`方法（前or后遍历）找到该节点，然后调用`unlink()`解除并更新前后节点的引用
- 删除指定元素，也是前后节点遍历，找到后调用`unlink()`解除并更新前后节点的引用
- 删除头尾节点则是直接将头尾节点引用后移

`LinkedList`侧重于找节点本身，当节点在首尾部分的时候，很高效，但是如果删除的是中间元素，那么效率就比较低了

（3）总结

- 从**头部**删除时，**ArrayList** 花费的时间比 LinkedList **多很多**；
- 从**中间**删除时，**ArrayList** 花费的时间比 LinkedList **少很多**；
- 从**尾部**删除时，**ArrayList** 花费的时间比 LinkedList **少一点**。



#### 3.3 遍历元素

（1）ArrayList

- 根据索引找元素，检查完下标合法性后，直接返回`elementData[index]`
- 找指定元素下标，那就是只能遍历数组，从头到尾找

（2）LinkedList

- 根据索引找元素，检查完下标合法性后，从首节点/尾节点开始遍历
- 找指定元素下标，只能遍历链表，从头到尾找



## 4 两者使用场景

1. 当需要**频繁随机访问元素**的时候，例如读取大量数据并进行处理或者需要对数据进行**排序或查找**的场景，可以使用 ArrayList。

   例如一个学生管理系统，需要对学生列表进行排序或查找操作，可以使用 ArrayList 存储学生信息，以便快速访问和处理。

2. 当需要**频繁插入和删除元素**的时候，例如实现**队列或栈**，或者需要**在中间插入或删除元素**的场景，可以使用 LinkedList。

   例如一个实时聊天系统，需要实现一个消息队列，可以使用 LinkedList 存储消息，以便快速插入和删除消息。

3. 在一些特殊场景下，可能需要同时支持随机访问和插入/删除操作。例如一个在线游戏系统，需要实现一个玩家列表，需要支持快速查找和遍历玩家，同时也需要支持玩家的加入和离开。在这种情况下，可以使用 LinkedList 和 ArrayList 的**组合**。

   例如使用 LinkedList 存储玩家，以便快速插入和删除玩家，同时使用 ArrayList 存储玩家列表，以便快速查找和遍历玩家。

















