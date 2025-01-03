# ListIterator 方法详解

```java
private class ListItr extends Itr implements ListIterator<E> {
    ListItr(int index) {
        super();
        cursor = index;
    }

    public boolean hasPrevious() {
        return cursor != 0;
    }

    public int nextIndex() {
        return cursor;
    }

    public int previousIndex() {
        return cursor - 1;
    }

    @SuppressWarnings("unchecked")
    public E previous() {
        checkForComodification();
        int i = cursor - 1;
        if (i < 0)
            throw new NoSuchElementException();
        Object[] elementData = ArrayList.this.elementData;
        if (i >= elementData.length)
            throw new ConcurrentModificationException();
        cursor = i;
        return (E) elementData[lastRet = i];
    }

    public void set(E e) {
        if (lastRet < 0)
            throw new IllegalStateException();
        checkForComodification();

        try {
            ArrayList.this.set(lastRet, e);
        } catch (IndexOutOfBoundsException ex) {
            throw new ConcurrentModificationException();
        }
    }

    public void add(E e) {
        checkForComodification();

        try {
            int i = cursor;
            ArrayList.this.add(i, e);
            cursor = i + 1;
            lastRet = -1;
            expectedModCount = modCount;
        } catch (IndexOutOfBoundsException ex) {
            throw new ConcurrentModificationException();
        }
    }
}
```

#### 1. 构造函数

若不传入参数，则默认值为0，即从下标为index的开始

```java
public ListIterator<E> listIterator(int index) {
        rangeCheckForAdd(index);
        return new ListItr(index);
    }
public ListIterator<E> listIterator() {
    return new ListItr(0);
}

// 实际只有一个有参构造
ListItr(int index) {
    super();
    cursor = index;
}
```

构造函数接受一个index，将其设置为cursor，用于跟踪当前迭代器的位置



#### 2. hasPrevious()

检查迭代器当前位置是否可以向前移动。 `cursor != 0`

```java
public boolean hasPrevious() {
    return cursor != 0;
}
```



#### 3. nextIndex()

当使用next()获取一个元素之后，cursor实际上就已经指向下一个元素了，因此直接返回cursor

```java
public int nextIndex() {
    return cursor;
}
```



#### 4. previousIndex() 方法

当使用previous()得到一个元素的时候，事实上cursor还指向这个元素，因此返回cursor

```java
public int previousIndex() {
    return cursor - 1;
}
```



#### 5. previous()

用于返回前一个元素，并将cursor前移

- `i = cursor - 1`，i 是前一个元素的下标
- 获得 i 下标的元素 e
- `cursor = i`，cursor前移
- `return e，lastRet = i`

```java
public E previous() {
    checkForComodification();
    int i = cursor - 1;
    if (i < 0)
        throw new NoSuchElementException();
    Object[] elementData = ArrayList.this.elementData;
    if (i >= elementData.length)
        throw new ConcurrentModificationException();
    cursor = i;
    return (E) elementData[lastRet = i];
}
```



#### 6. set(E e)

直接设置下标是`lastRet`的元素为`e`

注意，当执行 remove 或者 add 操作后，`lastRet`被设置为 **-1**

```java
public void set(E e) {
    if (lastRet < 0)
        throw new IllegalStateException();
    checkForComodification();

    try {
        ArrayList.this.set(lastRet, e);
    } catch (IndexOutOfBoundsException ex) {
        throw new ConcurrentModificationException();
    }
}
```



#### 7. add(E e)

方法用于在当前位置 `cursor` 插入新元素 `e`。

- `i = cursor`，在下标为 i 处插入新元素（老元素后移）

- `cursor = i + 1`，游标后移到下一个元素
- `lastRest = -1`



#### 例子

```java
List<Integer> nums = new ArrayList<>();
nums.add(1);
nums.add(2);
nums.add(3);
nums.add(5);

// 构造迭代器
ListIterator<Integer> iterator = nums.listIterator();

// 此时cursor为0，插入0后，cursor指向下标1
iterator.add(0);
while (iterator.hasNext()) {
    Integer num = iterator.next();
    // 这里输出的: 1,2,3,5	4是add的时候cursor后移了
    System.out.print(num + ",");
    if (num == 3) {
        iterator.add(4);
    }
}

[0, 1, 2, 3, 4, 5]
System.out.println(nums);



while (iterator.hasPrevious()) {
    Integer previous = iterator.previous();
    
    // 这里输出： 5,4,3,2,0,1,0
    // 原因就是通过previous得到2后，cursor实际上还是指向2的
    // 插入了0后，cursor后移，原数组也后移，相当于没动了
    // 而下一次迭代previous得到的就是插入的0
    System.out.print(previous + ",");
    if (previous == 2) {
        iterator.add(0);
    }
}

// [0, 1, 0, 2, 3, 4, 5]
System.out.print(nums);


ListIterator<Integer> li = nums.listIterator();
while (li.hasNext()) {
    // next之后cursor后移，所以直接返回cursor即可
    Integer next = li.next();
    if (next == 0) {
        // 1， 3
        System.out.println(li.nextIndex());
    }
}

ListIterator<Integer> iterator1 = nums.listIterator();
while (iterator1.hasNext()) {
    Integer next = iterator1.next();
    if (next == 0) {
        // 直接在下标lastRet处修改
        iterator1.set(9);
    }
}
// [9, 1, 9, 2, 3, 4, 5]
System.out.println(nums);


ListIterator<Integer> iterator2 = nums.listIterator();
while (iterator2.hasNext()) {
    Integer next = iterator2.next();
    if (next == 9) {
        // 直接删除下标为lastRet的元素
        // 然后先将 cursor设置lastRet，毕竟元素迁移了
        // 最后将lastRet置为-1
        iterator2.remove();
    }
}
System.out.println(nums);
```