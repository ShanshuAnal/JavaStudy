# 一、Java概述

1. #####  .class文件和.java文件是什么关系

.java文件使开发人员编写的源代码； .class是字节码文件，是.java文件经过 javac 命令编译后生成的文件，也是交给JVM运行的文件



2. #####  java是编译型语言还是解释性语言

Java其实既不是**纯解释型语言**，也不是**纯编译型语言**，而是**“混合型语言”**，因为它结合了两者的特性：

1. **编译阶段**：
   Java的源代码（.java文件）首先被编译器（`javac`）编译成字节码（.class文件）。这个字节码是一种**中间表示形式**，并不是机器能直接执行的。
2. **解释阶段**：
   Java虚拟机（JVM）通过解释器将字节码**逐条翻译**成机器码并执行，这是JVM的基本执行模式。在这一阶段，字节码被动态解析为目标平台上的可执行指令。

​	优点：实现简单，启动速度快

​	缺点：由于每次执行都要对字节码文件进行**逐行解释**，所以执行效率较低

3. **即时编译（JIT）优化**：
   JVM中的即时编译器（Just-In-Time Compiler）会将热点代码（频繁执行的代码段）直接编译为机器码，并缓存起来，直接在硬件上运行，而不需要再次解释，从而提升运行速度。这让Java在运行时可以接近纯编译型语言的性能。

​	值得注意是JIT并不会编译所有字节码，而是**根据一定的策略**，仅仅编译被频繁调用的代码段（热点代码）

Java结合了编译型和解释型语言的优点：

- **编译型特性**：通过编译生成高效的字节码。
- **解释型特性**：跨平台运行，由JVM动态解释或编译。



<img src="https://cdn.tobebetterjavaer.com/stutymore/hello-world-20230408190024.png" alt="img" style="zoom: 50%;" />

在程序运行初期，JVM采用逐行解释，以减少启动时间；随着程序的不断执行，JVM会识别出热点代码并用JIT将其编译成本地机器码，以提高程序执行效率。这种结合策略被称之为混合模式。

也就是说，为了跨平台，Java源代码首先会被编译成字节码，字节码不是机器语言，需要用JVM来解释。有了JVM这个中间层，Java的运行效率就没有直接把代码翻译成机器码的效率来得高了。所以为了提高运行效率，JVM引用了JIT编译器。



# 二、Java语法基础

### 1. Java关键字和保留字

#### **byte**

 用于表示一个 8 位（1 字节）有符号整数。它的值范围是 -128（-2^7）到 127（2^7 - 1）。

由于 byte 类型占用的空间较小，它通常用于处理大量的数据，如文件读写、网络传输等场景，以节省内存空间。



#### **final**

（1）final变量：被 final 修饰的变量无法重新赋值。换句话说，final 变量一旦初始化，就无法更改。

​	另外，final 修饰的成员变量必须有一个默认值，否则编译器将会提醒没有初始化。

​	final 和 static 一起修饰的成员变量叫做常量，常量名必须全部大写。

（2）final方法：被 final 修饰的方法不能被重写。

（3）final类：如果一个类使用了 final 关键字修饰，那么它就无法被继承。

```java
// 1. 一个final类 和 一个类不是final但方法全是final的有什么区别
// 第一个final类是不可继承的，方法无法被重写；第二个是可以被继承的，然后追加一些final方法

// 2. 类是final的，并不意味着类的对象是不可变的
Writer w = new Writer();
w.setName("wxb");
```

​	比如String类就是被设计成final的

​	原因如下：

- 为了实现字符串常量池

​	字符串常量池是 Java 堆内存中一个特殊的存储区域，当创建一个 String 对象时，假如此字符串在常量池中不	存在，那么就创建一个；假如已经存，就不会再创建了，而是直接引用已经存在的对象。这样做能够减少 	JVM 的内存开销，提高效率。

- 为了线程安全

​	String 是不可变的，就可以在多个线程之间共享，不需要同步处理

​	因此，当我们调用 String 类的任何方法（比如说 `trim()`、`substring()`、`toLowerCase()`）时，总会返回	一个新的对象，而不影响之前的值。

```java
String cmower = "沉默王二，一枚有趣的程序员";
cmower.substring(0,4);
System.out.println(cmower);// 沉默王二，一枚有趣的程序员
```

​	虽然调用 `substring()` 方法对 cmower 进行了截取，但 cmower 的值没有改变。除了 String 类，包装器类 	Integer、Long 等也是不可变类

- 为了 HashCode 的不可变性

​	因为字符串是不可变的，所以在它创建的时候，其 hashCode 就被缓存了，因此非常适合作为哈希值（比如	说作为 HashMap的键），多次调用只返回同一个值，来提高效率。



#### **关于不可变类**

一个类的对象在通过构造方法创建后如果状态不会再被改变，那么它就是一个不可变（immutable）类。它的所有成员变量的赋值仅在构造方法中完成，不会提供任何 setter 方法供外部类去修改。

假如说类是不可变的，那么对象的状态就也是不可变的。这样的话，每次修改对象的状态，就会产生一个新的对象供不同的线程使用，我们程序员就不必再担心并发问题了。

四大条件：

- 类是final的，不可被继承
- 所以字段都是final的，只能在构造方法中初始化
- 没有setter()方法
- 如果一个不可变类包含了可变类的对象，那么就要确保返回的是可变对象的副本

```java
public final class Writer {
	private final String name;
    private final Book book;
    
    Writer(String name, Book book) {
    	this.name = name;
        this.book = book;
    }
    
    public String getName() {
        return this.name;
    }
    public Book getBook() {
        return this.book;
    }
}

class Book{
    private String name;
    private int price;
    ....
}

main() {
    Book book = new Book("cmddds", 12);
    Writer writer = new Writer("wxb", book);
    
    // Book{name='cmddds', price=12}
    sout(writer.getBook());
    
    writer.setPrice(10);
    // Book{name='cmddds', price=10}
    sout(writer.getBook());
}
```

结果发现Writer类的不可变性被破坏了，按理说`writer.getBook().setPrice(59)；`执行后，书的价格价格不变的。这是因为`writer.getBook()`返回的是book对象，这个对象虽然是被final修饰的，但这只代表book所引用的Book对象不能变，但这个对象的内部属性是可以变的。

为了解决这个问题，我们需要为不可变类的定义规则追加一条内容：

- 如果一个不可变类中包含了可变类的对象，那么就需要确保**返回的是可变对象的副本**。


.也就是说，Writer 类中的 `getBook()` 方法应该修改为：

```java
public Book getBook() {
	return this.book.clone();
}
```



**native：** [用于声明一个本地方法open in new window](https://tobebetterjavaer.com/oo/native-method.html)，本地方法是指在 Java 代码中声明但在本地代码（通常是 C 或 C++ 代码）中实现的方法，它通常用于与操作系统或其他本地库进行交互。



#### **Java访问权限修饰符**

（1）修饰类

- 默认访问权限（包访问权限）：用来修饰类的话，表示该类只对**同一个包**中的其他类可见。
- public：用来修饰类的话，表示该类对其他**所有**的类都可见。

（2）修饰方法和变量‘

- 默认访问权限（包访问权限）：如果一个类的方法或变量被包访问权限修饰，也就意味着只能在**同一个包**中的其他类中显示地调用该类的方法或者变量，在不同包中的类中不能显式地调用该类的方法或变量。
- public：被 public 修饰的方法或者变量，在**任何地方**都是可见的。
- protected：如果一个类的方法或者变量被 protected 修饰，对于**同一个包**的类，这个类的方法或变量是**可以被访问**的。对于**不同包的类，只有继承于该类的类才可以访问到该类的方法或者变量。**
- private：如果一个类的方法或者变量被 private 修饰，那么这个类的方法或者变量只能在该**类本身中**被访问，在类外以及其他类中都不能显式的进行访问。



#### **transient**

 修饰的**字段**不会被序列化

一个对象只要实现了 Serilizable 接口，它就可以被序列化。

如果一个类的某些字段不需要序列化，比如用户的隐私信息（密码，银行卡号），为了安全起见，不希望网络操作中传输或者持久化到磁盘文件中，那么字写字段就要加上`transient`

被`transient`修饰的成员变量在反序列化的时候会被自动初始化为默认值

注意：

- 一个静态变量不管有没有被transient修饰，它都是不可序列化的

- 在 Java 中，对象的序列化可以通过实现两种接口来实现，如果实现的是 Serializable 接口，则所有的序列化将会自动进行，如果实现的是 Externalizable 接口，则需要在 writeExternal 方法中指定要序列化的字段，与 transient 关键字修饰无关。



**volatile：** 保证不同线程对它修饰的变量进行操作时的[可见性open in new window](https://tobebetterjavaer.com/thread/volatile.html)，即一个线程修改了某个变量的值，新值对其他线程来说是立即可见的。





### 2. 注释

文档注释生成javadoc命令生成代码文档

**第一步**，在该类文件上右键，找到「Open in Terminal」 可以打开命令行窗口。

**第二步**，执行 javadoc 命令 `javadoc Demo.java -encoding utf-8`。`-encoding utf-8` 可以保证中文不发生乱码。

**第三步，**执行 `ls -l` 命令就可以看到生成代码文档时产生的文件，主要是一些可以组成网页的 html、js 和 css 文件。

**第四步**，执行 `open index.html` 命令可以通过默认的浏览器打开文档注释。

注意：`javadoc` 命令只能为 public 和 protected 修饰的字段、方法和类生成文档。



### 3. Java数据类型

- 基本数据类型

byte short int long float double boolean char

- 引用数据类型

除了基本数据类型以外的类型，都是所谓的引用类型。

<img src="https://cdn.tobebetterjavaer.com/tobebetterjavaer/images/core-grammar/nine-01.png" alt="img" style="zoom:50%;" />

变量分为：局部变量（要初始化，存在Java虚拟栈）、成员变量和静态变量（会初始化成默认值，存在堆中）



#### **基本数据类型**

1. boolean

​	只存true和false

2. byte

​	一个字节可以表示2^8=256个不同值，范围[-128, 127]，有符号

​	bit : 信息技术的最基本存储单位，1 字节 = 8 比特。

3. short

​	范围( -32,768, 32,767 ]

4. int

​	范围(-2 ^ 31, 2,147, 2 ^ 31 -1]

5. long

​	范围(-2^63, 2^63 -1]

​	为了和 int 作区分，long 型变量在声明的时候，末尾要带上大写的“L”。

6. float

​	float 是**单精度**的浮点数（单精度浮点数的有效数字大约为 6 到 7 位），32 位（4 字节），遵循 IEEE 754（二进制浮点数算术标准），取值范围为 1.4E-45 到 3.4E+38。float 不适合用于精确的数值。

​	为了和 double 作区分，float 型变量在声明的时候，末尾要带上小写的“f”。

7. double

​	double 是**双精度**浮点数（双精度浮点数的有效数字大约为 15 到 17 位），占 64 位（8 字节），也遵循 IEEE 754 标准，取值范围大约 ±4.9E-324 到 ±1.7976931348623157E308。

​	

在进行金融计算或需要精确小数计算的场景中，可以使用 BigDecimal 类来避免浮点数舍入误差。BigDecimal 可以表示一个任意大小且精度完全准确的浮点数。

> 在实际开发中，如果不是特别大的金额（精确到 0.01 元，也就是一分钱），一般建议乘以 100 转成整型进行处理。



8. char

​	char 用于表示 Unicode 字符，占 16 位（2 字节）的存储空间，取值范围为 0 到 65,535。





**int和char类型互转换**

```java
// int -> char
// 1. 通过强制类型转换，将int转换为char
int i = 8;
char c = (char)i;

char c1 = new String(i).charAt(0);
char c2 = Integer.toString(i).charAt(0);



// 2. Character.forDigit(value, radix)  参数 radix 为基数，十进制为 10，十六进制为 16。
char c = '2';
int i = Character.forDigit(c, 10);

// 这个是获取字符'a'的 ASCII 值，因为 char 本质是一个 16 位的无符号整数。
int a = 'a';
```



#### **包装器类型**

包装器类型允许我们使用基本数据类型提供的各种实用方法，并兼容需要对象类型的场景。

例如，我们可以使用 Integer 类的 parseInt 方法将字符串转换为整数；或使用 Character 类的 isDigit 方法检查字符是否为数字....

从 Java 5 开始，**自动装箱**（Autoboxing）和**自动拆箱**（Unboxing）机制允许我们在基本数据类型和包装器类型之间自动转换，无需显式地调用构造方法或转换方法。



包装器类型和基本类型的不同之处

1. 包装类型可以为null，基本类型不能为null

这使得包装类型可用于POJO（简单无规则的Java对象，只要字段和对应setter、getter）

因为数据库的查询结果可能是null，如果用基本类型的话，在自动装箱的时候就会出现NullPointException空指针异常

**自动拆箱**：将包装类型转为基本类型，比如说把 Integer 对象转换成 int 值；

**自动装箱**就是把基本类型转为包装类型。

```java
// 在 Java 1.5 之前，开发人员要手动进行装拆箱
Integer i = new Integer(10);
int i1 = i.intValue();

// java 1.5后就有了自动装箱和自动拆箱
Integer i = 10;  // Integer i = Integer.valueOf(10);
int i1 = i; 	 // int i1 = i.intValue(); 
```

面试题：

```java
// 1）基本类型和包装类型
int a = 100;
Integer b = 100;
System.out.println(a == b);   // true

// 2）两个包装类型
Integer c = 100;
Integer d = 100;
System.out.println(c == d);   // true

// 3）
c = 200;
d = 200;
System.out.println(c == d);   // false
```

​	1）基本类型和包装类型进行 **==** 比较，这时候 Integer会**自动拆箱**为int，直接和 a 比较值

​	2）3）自动装箱是通过`Integer.valueOf()`完成的，其代码如下

```java
public static Integer valueOf(int i) {
    if (i >= -128 && i <= 127) { // 判断是否在缓存范围内
        return IntegerCache.cache[i + 128]; // 返回缓存中的对象
    }
    return new Integer(i); // 超出范围时创建新对象
}
```

IntegerCache是Integer的一个静态内部类，负责缓存 -128 到 127的整数值。如果值在这之间，那么valueOf方法会直接返回缓存数组IntegerCache.cache中的已有对象，而不是创建一个新的对象，只有在超出缓存范围的时候，valueOf方法才会通过new创建一个新的对象并缓存起来。

所以代码2中 `c` 和`d` 实际上引用的是同一个缓存中的对象，因此 `c` 和 `d` 指向的是同一个内存地址。`==` 比较的是对象的内存地址，而不是值。由于 `c` 和 `d` 是相同的缓存对象，所以结果是 `true`。代码3就是超出了。

> 和POJO类似，还有
>
> - 数据传输对象 DTO（Data Transfer Object，泛指用于展示层与服务层之间的数据传输对象）
> - 视图对象 VO（View Object，把某个页面的数据封装起来）
> - 持久化对象 PO（Persistant Object，可以看成是与数据库中的表映射的 Java 对象）。



2. 包装类型可用于泛型，而基本类型不行

因为泛型在编译的时候会进行类型擦除，只保留原始类型，原始类型只能是Object类及其子类，基本类型不是的



3. 基本类型比包装类型

作为局部变量时，基本类型直接在Java虚拟机栈中存储具体数值

而包装类在栈中存储的是堆中元素的引用地址

<img src="https://cdn.tobebetterjavaer.com/tobebetterjavaer/images/core-points/box-01.png" alt="img" style="zoom:33%;" />

显然，相对于基本类型，包装类型要占更多的内存空间（要存对象和引用）



4. 性能问题

```java
Long sum = 0L;
for (int i = 0; i < Integer.MAX_VALUE;i++) {
    sum += i;
}
```

这段代码性能就很低，因为sum是Long类型的，i是int类型的，所以sum += i；的实际过程是：

i 先被强制转换为long，然后再把sum自动拆箱成long，相加完后再把结果自动装箱为Long并赋值给sum



> 数据存储的地方
>
> 1. 寄存器
>
>    位于CPU内部，运行速度最快，用于暂时存放参与运算的数据和运算结果
>
> 2. 栈
>
>    位于RAM（主存，与CPU直接交换数据的内部编辑器），运行速度仅次于寄存器。在分配内存时，存放在栈中的数据大小和生存周期必须在编译时确定，缺乏灵活性。
>
>    基本**数据类型的值**和**对象的引用**通常都存在这。
>
> 3. 堆
>
>    也位于RAM，可以动态分配内存大小，编译器不必事先知道分配了多大空间和生存周期，Java的垃圾回收器会自动收走不再使用的数据，因此灵活性更高。
>
>    但是运行时动态分配内存和销毁对象都要时间，所以效率低了一点。
>
>    **new出来的对象**通常都存在这
>
> 4. 磁盘（外存）
>
>    存储在磁盘的数据不受程序限制，在程序没有运行的时候也存在。像文件、数据库就是通过持久化的方式，让对象存在磁盘中，有需要的时候，再通过反序列化成程序可以识别的对象



4. 两个包装类型的值可以相同，但却不相等

两个包装类型在使用“==”进行判断的时候，判断的是其指向的地址是否相等，由于是两个对象，所以地址是不同的。要用equals方法



#### **引用数据类型**

- 引用数据类型默认值为null
- 变量名指向的是存储对象的内存地址，在栈上
- 内存地址指向的对象在堆上



### 4. 数据类型转换

#### 自动类型转换

自动类型转换是 Java 编译器在**不需要显式转换**的情况下，将一种基本数据类型自动转换为另一种基本数据类型的过程。这种转换通常发生在表达式求值期间，当不同类型的数据需要相互兼容时。

```java
// byte -> short -> int -> long -> float -> double
// char -> int -> long -> float -> double
long i = 123;

double d = 2.5 * 10;
int i = 'a'
```

注意：char 类型比较特殊，char 自动转换成 int、long、float 和 double，但 byte 和 short 不能自动转换为 char，而且 char 也不能自动转换为 byte 或 short。



#### 强制类型转换

强制类型转换是 Java 中将一种数据类型显式转换为另一种数据类型的过程。强制类型转换可能会导致数据丢失或精度降低，因为目标类型可能无法容纳原始类型的所有可能值。



### 5. Java基本数据类型缓存池（IntegerCache）

```java
// IntegerCache 这个静态内部类的源码
private static class IntegerCache {
    static final int low = -128;
    static final int high;
    static final Integer cache[];

    static {
        // high value may be configured by property
        int h = 127;
        String integerCacheHighPropValue =
                sun.misc.VM.getSavedProperty("java.lang.Integer.IntegerCache.high");
        if (integerCacheHighPropValue != null) {
            try {
                int i = parseInt(integerCacheHighPropValue);
                i = Math.max(i, 127);
                // Maximum array size is Integer.MAX_VALUE
                h = Math.min(i, Integer.MAX_VALUE - (-low) -1);
            } catch( NumberFormatException nfe) {
                // If the property cannot be parsed into an int, ignore it.
            }
        }
        high = h;

        // 关键代码
        cache = new Integer[(high - low) + 1];
        int j = low;
        for(int k = 0; k < cache.length; k++)
            cache[k] = new Integer(j++);

        // range [-128, 127] must be interned (JLS7 5.1.7)
        // 断言机制，如果high >= 127 就没事，反之会抛出异常
        // java -ea com.itwanger.s51.AssertTest 		加上-ea参数
        assert Integer.IntegerCache.high >= 127;
    }

    private IntegerCache() {}
}
```


### 6. 运算符

#### 算术运算符

需要注意的是，当浮点数除以 0 的时候，结果为 Infinity 或者 NaN；

```java
System.out.println(10.0 / 0.0); // Infinity
System.out.println(0.0 / 0.0); // NaN
```

当整数除以 0 的时候），会抛出异常，所以整数在进行除法操作时，要判断除数是否为0



**自增运算符++**

```java
int i = 5;
int res = ++i;
```

编译生成的字节码（通过 `javap -c` 查看）：

```java
0: iconst_5        // 将常量 5 压入操作数栈
1: istore_1        // 将栈顶值存储到局部变量 i

2: iinc 1, 1       // 将局部变量 i 增加 1
5: iload_1         // 将局部变量 i 压入栈（新值）
6: istore_2        // 将栈顶值存储到局部变量 result
```

执行过程：

1. 将常量 `5` 存入变量 `i`。
2. 使用 `iinc 1, 1` 指令对变量 `i` 执行自增操作，直接将 `i` 的值从 `5` 修改为 `6`。
3. 使用 `iload_1` 指令将自增后的值 `6` 压入栈。
4. 将栈顶值 `6` 存储到变量 `result`。

**先自增，在压栈，再赋值**



```java
int i = 5;
int res = i++;
```

编译生成的字节码：

```jav
0: iconst_5        // 将常量 5 压入操作数栈
1: istore_1        // 将栈顶值存储到局部变量 i

2: iload_1         // 将局部变量 i 压入栈（当前值）
3: iinc 1, 1       // 将局部变量 i 增加 1
6: istore_2        // 将栈顶值存储到局部变量 result
```

执行过程：

1. 将常量 `5` 存入变量 `i`。
2. 使用 `iload_1` 指令将当前变量 `i` 的值 `5` 压入栈。
3. 使用 `iinc 1, 1` 指令对变量 `i` 执行自增操作，将值从 `5` 修改为 `6`。
4. 将原值 `5`（之前压入栈的值）存储到变量 `result`。

**先压栈，再自增，再赋值**



#### 关系运算符

<img src="https://cdn.tobebetterjavaer.com/tobebetterjavaer/images/core-grammar/eleven-02.png" alt="img" style="zoom:50%;" />



#### 位运算符

<img src="https://cdn.tobebetterjavaer.com/tobebetterjavaer/images/core-grammar/eleven-03.png" alt="img" style="zoom:50%;" />

位运算符操作的不是整型数值（int、long、short、char、byte）本身，而是整型数值对应的二进制。



#### 逻辑运算符

逻辑与运算符（&&）：多个条件中只要有**一个为 false** 结果就为 false。

逻辑或运算符（||）：多个条件只要有**一个为 true** 结果就为 true。

逻辑非运算符（!）：用来反转条件的结果，如果条件为 true，则逻辑非运算符将得到 false。

单逻辑与运算符（&）：很少用，因为不管第一个条件为 true 还是 false，依然会**检查第二个**。

单逻辑或运算符（|）：也会**检查第二个条件**。



#### 赋值运算符

注意几个问题

- 类型转换问题

```java
short a = 9, b = 1;
a = a + b; // 这里发生编译错误，9 + 1=10变成了int类型的了，要强转
```

- 边界问题

```java
int a = Integer.MAX_VALUE;
int b = 10000;
int c = a * b;
```

这里c算出来是 -10000，显然不是我们要的结果，可以通过右侧表达式强制转换为 long 来解决



#### 三元运算符

```java
int min=(a<b)?a:b;
```





### 7. 控制流程语句

#### if-else(-else if)



#### switch

switch 语句用来判断变量与多个值之间的相等性。变量的类型可以是 byte、short、int 或者 char，或者对应的包装器类型 Byte、Short、Integer、Character，以及**字符串**和**枚举**。

```java
public enum Types {
	TENNIES, BASKETBALL, FOOTBALL
}

public void test(Types type) {
	switch (type) {
        case TENNIES：
            System.out.println(1);
            break;
        case BASKETBALL：
            System.out.println(2);
            break;
        case FOOTBALL：
            System.out.println(3);
            break;
        default:
            throw new ILLegalArgumentException("what's this?" + type)
	}
}
```



#### for、while、do-while



#### break

break 关键字通常用于中断循环或 switch 语句，它在指定条件下中断程序的当前流程。
如果是内部循环，则仅中断内部循环。



#### continue

当我们需要在 for 循环或者while 循环中立即跳转到下一个循环时，就可以使用 continue 关键字，

通常用于跳过指定条件下的循环体，如果循环是嵌套的，仅跳过当前循环。





