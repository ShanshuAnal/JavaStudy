# LinkedHashMap

`LinkedHashMap` 是 `HashMap` 的一个子类，维护了一个**双向链表**，记录键值对的插入顺序或访问顺序。相比于 `HashMap`，它保留了元素的顺序，可以更高效地实现按插入或访问顺序的遍历。

- 底层是**双向链表 + 哈希表**
- 支持按插入顺序或访问顺序（通过 `accessOrder` 参数控制）
- key 有序且可重复
- 遍历时的顺序是确定的，通常优于 `HashMap`



**LinkedHashMap = HashMap + 插入/访问顺序维护**

`LinkedHashMap` 没有改变 `HashMap` 的哈希存储逻辑，它只是额外增加了链表结构。数据依然存储在 `table` 数组中。

---

### 1. 核心结构

- 哈希表的作用：键值对的实际存储位置，可用通过哈希值快速查询。
- 双向链表的作用：通过 `before` 和 `after` 指针**维护插入顺序或访问顺序**，它并不负责存储数据

每个节点即使哈希表中的一个桶，也是双向链表的一个节点。

```java
public class LinkedHashMap<K,V> extends HashMap<K,V> implements SequencedMap<K,V> {
    
    static class Entry<K,V> extends HashMap.Node<K,V> {
        // 前驱和后继节点的指针
        Entry<K,V> before, after;
        
        Entry(int hash, K key, V value, Node<K,V> next) {
            super(hash, key, value, next);
        }
    }
	// 链表头节点
    transient LinkedHashMap.Entry<K,V> head;
	// 链表尾节点
    transient LinkedHashMap.Entry<K,V> tail;
    // 用于控制顺序
    final boolean accessOrder;
}
```

布尔属性 **`accessOrder`** 用于控制顺序模式，默认为false。

- `false`

  **插入顺序**模式。节点总是追加到链表尾部，保持插入顺序

- `true`

  **访问顺序**模式。**最近被访问的节点会被移动到链表尾部**，形成基于访问频率的顺序（适合 **LRU** 缓存）。



### 2. 插入顺序

`LinkedHashMap` 是可以维持插入顺序的，它并没有重写`HashMap`的`put`方法，因为实际存储在table数组中，不需要重写put方法，只要额外维护一个双向链表，所以重写的是内部方法`newNode`

在`HashMap`中是直接返回一个新的节点对象，这里是先新建一个双向链表节点，然后将其插入到这个**链表尾部**，然后再返回这个节点对象

```java
// 这个方法在put中新建节点的时候被调用
HashMap.Node<K,V> newNode(int hash, K key, V value, HashMap.Node<K,V> e) {
    LinkedHashMap.Entry<K,V> p = new LinkedHashMap.Entry<>(hash, key, value, e);
    linkNodeLast(p);
    return p;
}
```

`linkNodeLast`就是负责将新建节点插入到双向链表，就是一个双向链表的插入操作

```java
private void linkNodeAtEnd(LinkedHashMap.Entry<K,V> p) {
    // 将节点插在链表头部
    if (putMode == PUT_FIRST) {
        LinkedHashMap.Entry<K,V> first = head;
        head = p;
        if (first == null)
            tail = p;
        else {
            p.after = first;
            first.before = p;
        }
        
    // 将节点插入在链表尾部
    } else {
        LinkedHashMap.Entry<K,V> last = tail;
        tail = p;
        if (last == null)
            head = p;
        else {
            p.before = last;
            last.after = p;
        }
    }
}
```

所以整个插入的流程就是：使用`put`方法添加键值对，然后创建新节点调用`newNode`，在`newNode`中进行创建，然后调用`linkNodeEnd`把它插入到双向链表的尾部，并更新before和after属性。接着就进行`put`剩下的操作，把节点插入到`table`数组中



### 3. 访问顺序

例子，便于理解什么是访问逻辑

```java
Map<String, String> linkedHashMap = new LinkedHashMap<>(16, .75f, true);
linkedHashMap.put("沉", "沉默王二");
linkedHashMap.put("默", "沉默王二");
linkedHashMap.put("王", "沉默王二");
linkedHashMap.put("二", "沉默王二");

System.out.println(linkedHashMap);

linkedHashMap.get("默");
System.out.println(linkedHashMap);

linkedHashMap.get("王");
System.out.println(linkedHashMap);
-----------------------------------------------------------------------------
{沉=沉默王二, 默=沉默王二, 王=沉默王二, 二=沉默王二}
{沉=沉默王二, 王=沉默王二, 二=沉默王二, 默=沉默王二}
{沉=沉默王二, 二=沉默王二, 默=沉默王二, 王=沉默王二}
```



如果说要指定双链表维护的是访问顺序，那么就要将`accessOrder`在构造时指定为true

```java
LinkedHashMap<String, String> map = new LinkedHashMap<>(16, .75f, true);
```



主要用于维护访问顺序的的核心方法是`afterNodeAceess`。

- 每次调用`put`方法进行键值对更新时会调用（第一次插入某个节点不会调用，因为`newNode`方法会调用`LinkNodeEnd`将其插入在双链表尾部）

  在`HashMap`里面是空方法体

  ```java
  // putVal()
  if (e != null) { // existing mapping for key
      V oldValue = e.value;
      if (!onlyIfAbsent || oldValue == null)
          e.value = value;
      afterNodeAccess(e);
      return oldValue;
  }
  ```

- 每次调用`get`方法时会调用

  ```java
  public V get(Object key) {
      Node<K,V> e;
      // getNode就是HashMap里的
      if ((e = getNode(key)) == null)
          return null;
      // 这里的accessOrder为true
      if (accessOrder)
          afterNodeAccess(e);
      return e.value;
  }
  ```

  就是将双链表的某个节点插入尾部的操作

  ```java
  void afterNodeAccess(Node<K,V> e) {
      LinkedHashMap.Entry<K,V> last;
      // 如果是访问顺序且节点不在尾部
      if (accessOrder && (last = tail) != e) { 
          LinkedHashMap.Entry<K,V> p = (LinkedHashMap.Entry<K,V>) e;
          
          // 获取前驱后继节点
          LinkedHashMap.Entry<K,V> b = p.before, a = p.after;
          
          // 从链表中移除当前节点
          p.after = null;
          if (b == null)
              head = a; // 如果是头节点，更新 head 指针
          else
              b.after = a;
          if (a != null)
              a.before = b; // 如果有后继节点，更新其 before 指针
          
          // 将节点插入到链表尾部
          if (last == null)
              head = p; // 链表为空时，头尾均指向当前节点
          else {
              p.before = last; // 当前节点的 before 指向尾部节点
              last.after = p;  // 尾部节点的 after 指向当前节点
          }
          tail = p; // 更新尾部指针
          ++modCount;
      }
  }
  
  ```



如果想要删除某一个节点，那么在删除操作完成之后，会调用`afterNodeRemoval`方法，这个方法会在双链表中删除这个节点。

这就是一个双链表删除节点的操作

```java
void afterNodeRemoval(Node<K,V> e) { // unlink
    LinkedHashMap.Entry<K,V> p = (LinkedHashMap.Entry<K,V>)e;
    // 获取前驱后继节点
    LinkedHashMap.Entry<K,V> b = p.before, a = p.after;
    p.before = p.after = null;
    
    // 删除的是头节点，更新head
    if (b == null)
        head = a;
    // 否则更新前驱节点
    else
        b.after = a;
    
    // 删除的是尾节点，更新tail
    if (a == null)
        tail = b;
    // 否则更新后继节点
    else
        a.before = b;
}
```

















