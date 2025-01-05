# ArrayList的iterator()

```java
public Iterator<E> iterator() {
        return new Itr();
}

private class Itr implements Iterator<E> {
    int cursor;       // index of next element to return
    int lastRet = -1; // index of last element returned; -1 if no such
    int expectedModCount = modCount;

    // prevent creating a synthetic constructor
    Itr() {}

    public boolean hasNext() {
        return cursor != size;
    }

    @SuppressWarnings("unchecked")
    public E next() {
        checkForComodification();
        int i = cursor;
        if (i >= size)
            throw new NoSuchElementException();
        Object[] elementData = ArrayList.this.elementData;
        if (i >= elementData.length)
            throw new ConcurrentModificationException();
        cursor = i + 1;
        return (E) elementData[lastRet = i];
    }

    public void remove() {
        if (lastRet < 0)
            throw new IllegalStateException();
        checkForComodification();

        try {
            ArrayList.this.remove(lastRet);
            cursor = lastRet;
            lastRet = -1;
            expectedModCount = modCount;
        } catch (IndexOutOfBoundsException ex) {
            throw new ConcurrentModificationException();
        }
    }
```

这段代码是 `ArrayList` 的内部类 `Itr` 的实现，它是 `Iterator<E>` 的具体实现，用于实现对 `ArrayList` 的迭代访问



#### 1. 成员变量

```java
private class Itr implements Iterator<E> {
    int cursor;       // 下一次迭代时返回的元素索引
    int lastRet = -1; // 上一次返回的元素索引，-1 表示没有
    int expectedModCount = modCount; // 记录当前集合的修改次数
}
```

- **`cursor`**：当前迭代器的位置，指向**下一个要返回的元素的索引**。
- **`lastRet`**：记录最近一次返回的元素索引。如果没有返回过元素，则为 -1。
- **`expectedModCount`**：用于检测集合的结构性修改，初始值为 `modCount = 0`。



#### 2. 构造方法

```java
Itr() {}
```

私有的内部类构造器，没有参数。这里的定义只是为了防止合成构造器的生成。



#### 3. hasNext()

用于判断是否还有未遍历的元素 `cursor != size`

```java
public boolean hasNext() {
    // 如果 `cursor` 没有到达集合末尾（`size`），说明还有元素可供访问。
    return cursor != size;
}
```



#### 4. next()

- 先获得当前元素下标 `i = cursor
- 游标往前移动`cursor = i + 1`
- **更新**上一次返回元素的索引`lastRet`，并根据下标返回数据

```java
@SuppressWarnings("unchecked")
public E next() {
    // 检测并发修改
    checkForComodification();
    
    // 检查 cursor 是否越界
    int i = cursor;
    if (i >= size)
        throw new NoSuchElementException();
    // 获取当前元素数组
    Object[] elementData = ArrayList.this.elementData;
    if (i >= elementData.length)
        throw new ConcurrentModificationException();
    
    // 更新索引 cursor
    cursor = i + 1;
    // 更新lastRet，并进行类型转换
    return (E) elementData[lastRet = i];
}

```



#### 5. remove()

删除迭代器返回的最后一个元素

- 直接删除以`lastRet`为下标的数据
- 先获取上一次返回元素的索引 `cursor = lastRet`（因为next之后，cursor已经指向下一个元素了）
- **更新`lastRet = -1`**

```java
public void remove() {
   	// 如果 lastRet < 0，说明在 next()之前调用了remove()或者连续调用了多次 remove()
    if (lastRet < 0)
        throw new IllegalStateException();
    
    // 检测并发修改
    checkForComodification();

    try {
        // 删除由 lastRet 指定的元素，同时更新 cursor 和 lastRet。
        ArrayList.this.remove(lastRet);
        cursor = lastRet;
        lastRet = -1;
        // 更新 expectedModCount，保持与当前集合的 modCount 一致。（重点）
        expectedModCount = modCount;
    } catch (IndexOutOfBoundsException ex) {
        throw new ConcurrentModificationException();
    }
}
```



##### 6. 并发修改异常

```java
final void checkForComodification() 
    // 比较集合的 modCount 和迭代器记录的 expectedModCount
    if (modCount != expectedModCount)
        throw new ConcurrentModificationException();
}
```

`checkForComodification` 检测并发修改，确保集合未被外部修改：

如果集合被其他线程或外部方法修改了结构（`modCount` 发生变化），会抛出 `ConcurrentModificationException`。也就是说，集合在遍历过程中，最好使用迭代器remove方法，而不是直接在集合上进行删除。

> **fast-fail	 快速失败机制**
>
> Java 集合框架中的一种机制，用于在检测到集合在迭代过程中被结构性修改时，抛出 **`ConcurrentModificationException`**
>
> 它依赖于集合内部的修改计数器`modCount`，它记录的是集合结构发生变化的次数。
>
> 当迭代器生成时，会捕获当前集合的`modCount`，存储为迭代器的`exceptedModCount`。当迭代器遍历每次调用`next()`或者`remove()`时，迭代器货比较这两个值是否相等。
>
> 
>
> 问题就在于集合的remove方法
>
> 集合自己调用remove方法的话，集合自己的`modCount`会更新，但迭代器的`exceptedModCount`没有更新。迭代器每次对集合结构进行操作的时候，都会调用`checkForComodification()`来检查这两个值是否相等，不相等的话就抛出`ConcurrentModificationException并发修改`异常了。
>
> 所以应用迭代器的remove方法进行删除，它首先调用集合自己的remove方法，`modCount`会更新，然后将`modCount`的值赋给`exceptedModCount`，从而保证了一致性。