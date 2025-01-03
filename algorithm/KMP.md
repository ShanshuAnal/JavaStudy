## KMP

### 一 KMP有什么用

KMP的主要思想是**当出现字符串不匹配时，可以知道一部分之前已经匹配的文本内容，可以利用这些信息避免从头再去做匹配了。**

所以如何记录已经匹配的文本内容，是KMP的重点，也是next数组肩负的重任。



#### 二 前缀表

前缀表是用来回退的，它记录了模式串与主串不匹配的时候，**模式串**应该从哪里开始重新匹配。

<img src="https://code-thinking.cdn.bcebos.com/gifs/KMP%E7%B2%BE%E8%AE%B21.gif" alt="KMP详解1" style="zoom:67%;" />

那么什么是前缀表：**记录下标i之前（包括i）的字符串中，有多大长度的相同前缀后缀。**

比如此时相同前缀长度为2，那么就从模式串下标为2的地方开始匹配



#### 三 最长公共前后缀

123456

前缀(12345)是指 以第一个字符开头的 不包含最后一个字符的所有连续子串；

后缀(23456)是指 以最后一个字符结尾的 不包含第一个字符的所有连续子串。

<img src="https://code-thinking.cdn.bcebos.com/pics/KMP%E7%B2%BE%E8%AE%B21.png" alt="KMP精讲1" style="zoom:50%;" />

<img src="https://code-thinking.cdn.bcebos.com/pics/KMP%E7%B2%BE%E8%AE%B22.png" alt="KMP精讲2" style="zoom:50%;" />

下标5之前这部分的字符串（也就是字符串aabaa）的最长相等的前缀 和 后缀字符串是 子字符串aa ，

因为找到了最长相等的前缀和后缀，匹配**失败**的位置是**后缀子串的后面**，那么我们找到与其相同的**前缀的后面重新匹配**就可以了。



##### 为什么用前缀表

前缀表具有告诉我们当前位置匹配失败，跳到之前已经匹配过的地方的能力,





#### 四 如何计算前缀表

长度为1的字符串 a ，最长相同前后缀的长度为0

长度为2的字符串`aa`，最长相同前后缀的长度为1

长度为3的字符串`aab`，最长相同前后缀的长度为0

<img src="https://code-thinking.cdn.bcebos.com/pics/KMP%E7%B2%BE%E8%AE%B28.png" alt="KMP精讲8" style="zoom:50%;" />

匹配过程

<img src="https://code-thinking.cdn.bcebos.com/gifs/KMP%E7%B2%BE%E8%AE%B22.gif" alt="KMP精讲2" style="zoom: 80%;" />

当我们找到不匹配的位置时，我们就要找它的前一个字符的前缀表的数值是多少 ，是多少就从下标为多少的地方开始匹配。

为什么要找前一个字符的呢？因为要找前面字符串的最长相同前后缀，所以要看前一位的前缀表的数值



#### 五 使用next数组来匹配

以下我们以前缀表统一减一之后的next数组来做演示

<img src="https://code-thinking.cdn.bcebos.com/gifs/KMP%E7%B2%BE%E8%AE%B24.gif" alt="KMP精讲4" style="zoom:80%;" />



#### 六 构造next数组

1. 初始化

   定义两个指针， j 指向前缀末尾位置， i 指向后缀末尾位置

   ```java
   int j = -1;
   next[0] = j;
   ```

2.  处理前后缀不同

​	因为 j 初始化为-1，那么 i 就从1开始，进行s[i] 与 s[j+1]的比较

​	如果 s[i] 与 s[j+1]不相同，也就是遇到 前后缀末尾不相同的情况，就要向前回退

​	

​	怎么回退呢？

​	next[j]就是记录着j（包括j）之前的子串的相同前后缀的长度

​	那么 j = next[ j ];

​	因为 j 指向前缀末尾位置，也就是前缀的长度

3. 处理前后缀相同

   如果 s[i] 与 s[j + 1] 相同，那么就同时向后移动i 和j 说明找到了相同的前后缀，

   同时还要将j（前缀的长度）赋给next[i], 因为next[i]要记录相同前后缀的长度。

```java
public void getNext(int[] next, String s) {
    int j = -1;
    next[0] = j;
    for (int i = 1; i < s.length(); i++) {
        // 前后缀不相同了
        while (j >= 0 && s.charAt(j + 1) != s.charAt(i))
            j = next[j];
        // 找到了相同的前后缀
        if (s.charAt(j + 1) == s.charAt(i))
            j++;
       	// 将前缀长度（j）赋值为next[i]
       	next[i] = j;
    }
}
```



#### 七 进行匹配

定义两个下标 j 指向模式串起始位置，i 指向文本串起始位置。

j初始值依然为-1，因为next数组里记录的起始位置为-1

i就从0开始，遍历文本串

接下来就是 s[i] 与 t[j + 1]（因为j从-1开始的）进行比较；

- 如果 s[i] 与 t[j + 1] 不相同，j 就要从next数组里寻找下一个匹配的位置；

- 如果 s[i] 与 t[j + 1] 相同，那么i 和 j 同时向后移动

当 j 指向了模式串 t 的末尾时，那就说明模式串 t 完全匹配文本串 s 中的某个子串

```java
int j = -1;
for (int i = 0; i < s.length(); i++) {
    // 不匹配
    while (j >= 0 && s.charAt(i) == t.charAt(j + 1))
        	j = next[j];
   	if (s.charAt(i) == t.charAt(j))
        	j++;
   	if (j == t.length() - 1)
        	return i - t.length() + 1;
}
```





