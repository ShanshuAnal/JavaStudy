# Iterator 和 Iterable 有什么区别

`Iterator` 是个接口，JDK 1.2 的时候就有了，用来改进 `Enumeration` 接口：

- 允许删除元素（增加了 `remove` 方法）
- 优化了方法名（`Enumeration` 中是 `hasMoreElements` 和 `nextElement`，不简洁）

```java
public interface Iterator<E> {
    boolean hasNext();
    E next();
    default void remove() {
        throw new UnsupportedOperationException("remove");
    }
}
```



在JDK1.8之后，`Iterable`接口中新增了`forEach`方法，接受一个`Consumer`对象作为参数，用于对集合中的每个元素执行响应的操作。

该方法实现的是用`for-each`遍历集合中的元素，对于每个元素，调用`Consumer`对象的`accept`方法执行指定的操作

```java
default void forEach(Consumer<? super T> action) {
    Objects.requireNonNull(action);
    for (T t : this) {
        action.accept(t);
    }
}
```

































