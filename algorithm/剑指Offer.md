# 剑指Offer

## 1. [两数相除](https://leetcode.cn/problems/xoh6Oh/)

![image-20250317200503175](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250317200503175.png)

---

由于题目要求只能用加减法，那么自然就是用减法实现除法

用“被减数” 能减去几次 “减数” 来衡量最后的结果

这时候就想到用求 x 的幂次 的快速解法，将 x 成倍的求幂。这里将减数成倍成倍的增加，次数对应也是成倍成倍的增加

比如：a = 23，b = 2

b 的变化 ：2 -> 4 -> 8 -> 16，次数count 的变化：1 -> 2 -> 4 -> 8，最后a - b = 23 - 16 = 7

然后对7再执行一次上述过程：

b：2 -> 4，count：1 -> 2，a - b =  7 - 4 = 3

然后对3再执行一次：
b：2，count：1，a - b = 2 - 1 = 1	

此时1已经小于原b=2了，循环就结束了，最后统计count：8 + 2 + 1 =  11，这就是我们的答案

**注意**

- 为了方便运算，需要将a，b都转为同正或者同负。但是由于`Integer.MIN_VALUE`转正后就越界了，所以只好全部转为负数
- **溢出处理**，当出现 `Integer.MIN_VALUE / (-1)`是就出现溢出了，所以特殊处理，直接根据题目要求输出： `2^31 − 1`
- 最后结果的正负处理

```java
public int divide(int a, int b) {
    if (a == Integer.MIN_VALUE && b == -1) {
		return Integer.MAX_VALUE;
    }
    boolean flag = (a > 0 && b > 0) || (a < 0 && b < 0);
    if (a > 0) {
        a = -a;
    }
    if (b > 0) {
        b = -b;
    }
    int res = 0;
    while (a <= b) {
        int base = b, k = 1;
        // 把 a <= base + base 改成 a - base <= base ，因为 base + base 可能会溢出
        while (a - base <= base) {
            base += base;
            k += k;
        }
        a -= base;
        res += k;
    }
    return flag ? res : -res;
}
```





## [2. 二进制求和](https://leetcode.cn/problems/JFETK5/)

![image-20250317211354639](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250317211354639.png)

---

关键就是这个num

num记录上一次二进制加法计算后的**进位**

```java
public String addBinary(String a, String b) {
    StringBuilder sb = new StringBuilder();
    int indexA = a.length() - 1, indexB = b.length() - 1;
    int num = 0;
    while (indexA >= 0 || indexB >= 0 || num != 0) {
        int i = indexA >= 0 ? a.charAt(indexA--) - '0': 0;
        int j = indexB >= 0 ? b.charAt(indexB--) - '0': 0;
        num += i + j;
        sb.append(num % 2);
        num /= 2;
    }
    return sb.reverse().toString();
}
```



## [3. 比特位计数](https://leetcode.cn/problems/w3tCBm/)

使用动态规划

dp[i] ：非负整数 i 二进制表示中 1 的个数

- 对于偶数而言

  比如 2 ：10，4：100

  发现规律：对于偶数 n 而言，其二进制表示是由 n / 2 左移而来，就是多了一个0，1的个数没变

  所以`dp[i] = dp[i / 2]`

- 对于奇数来说

  比如 1：1，3：11，5：101，7：111

  发现规律：对于奇数 n 而言，其二进制表示是 n / 2左移后加1得到的，那么也就是说

  `dp[i] = dp[i / 2] + 1`

初始化：`dp[0] = 0`





## [4. 只出现一次的数字 II](https://leetcode.cn/problems/WGki4K/)

![image-20250318025130301](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250318025130301.png)

---

在一个数组中，如果只有一个数字出现一次，其他数字都出现两次，可以通过异或运算（`^`）快速找到那个只出现一次的数字。这是因为：

- `a ^ a = 0`
- `a ^ 0 = a`

所以，所有**成对出现的数字会互相抵消**，最终剩下的就是只出现一次的数字。

但是在这个问题中，**其他数字都出现了三次** ，而不再是两次。异或运算在这里就不再适用了，因为：

- 一个数字出现三次时，`a ^ a ^ a = a`，并不会被完全抵消。



**思路：**

既然每个数字都可以表示为二进制形式，我们可以从**二进制位**的角度分析问题。

- 如果某个数字出现了三次，那么**它在每一位上的贡献也会是三的倍数。**
- 只有那个只出现一次的数字会对某些二进制位产生“非三的倍数”的贡献。

因此，我们可以通过**统计每一位上 1 的数量**，并检查这些数量是否是 3 的倍数，从而推断出只出现一次的数字。



假设数组中有以下数字`[3, 3, 3, 10]`，那以二进制形式表示

```java
[0011, 0011, 0011, 1010]
```

- 第 0 位：总共有 3 个 1 和 1 个 0，`total = 3`，是 3 的倍数。
- 第 1 位：总共有 3 个 1 和 1 个 1，`total = 4`，不是 3 的倍数。
- 第 2 位：总共有 3 个 0 和 1 个 0，`total = 0`，是 3 的倍数。
- 第 3 位：总共有 3 个 0 和 1 个 1，`total = 1`，不是 3 的倍数。

通过这种方式可以**确定只出现一次的数字的每一位**

- 如果某一位上 1 的总数 **是 3 的倍数**，那么说明这一位的值是由 **出现三次的数**贡献出来的，与出现一次的无关。（要么3个1，要么没有1，此时都要求出现一次的数字在该二进制位是0）

  对应上面的第0位和第2位

- 如果某一位上 1 的总数**不是 3 的倍数**，那么说明这一位的值是由 **出现一次的数**贡献出来的

  （要么1个3，要么4个3，此时都要求出现一次的数字在该二进制位上是1）

  对应第1位和第3位

```java
public int singleNumber(int[] nums) {
    int res = 0;
    // 遍历每一位二进制位
    for (int i = 0; i < 32; i++) {
		int total = 0;
        for (int num : nums) {
            // 提取数字 num 的第i位（从右往左数，最低位为第0位），并将它累加到 total 中
            total += (num >> i) & 1;
        }
        if (total % 3 != 0) {
            // 将结果变量 ret 的第 i 位设置为 1 
			res |= (1 << i);
        }
    }
    return res;
}
```

### [只出现一次的数字](https://leetcode.cn/problems/single-number/)

![image-20250318032143999](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250318032143999.png)

---

这个用到的是**异或**的性质：相同为0，不同为1

以及异或的**结合律**  `p ⊕ (q ⊕ r) = (p ⊕ q) ⊕ r`

```java
int res = 0;
for (int num : nums) {
    res ^= num;
}
```

比如nums = [4,1,2,1,2]

由于交换律和结合律，异或的先后顺序随便

所以就等于 nums = [4,1,1,2,2]，那么很显然最后的结果是 4



## [5. 最大单词长度乘积](https://leetcode.cn/problems/aseY1I/)

![image-20250318150242827](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250318150242827.png)

---

这道题的核心思想是利用**位运算** 来高效地判断两个字符串是否有重复字符。

1. 每个字符串可以看作是由字母组成的集合。
2. 用一个整数的二进制位表示每个字母是否出现在字符串中：
   - 如果字母 `'a'` 出现，则第 0 位设置为 1；
   - 如果字母 `'b'` 出现，则第 1 位设置为 1。
3. 通过**按位或**操作，将字符串中的每个字母映射到对应的二进制位上。
4. 判断两个字符串是否有重复字符时，只需要对它们的二进制表示进行**按位与**运算 

- 如果结果为 0，则说明两个字符串没有重复字符；
- 如果结果不为 0，则说明两个字符串有重复字符。



第一步：将每个字符串转换为二进制表示

- 遍历每个字符串 `words[i]` 中的每个字符 `words[i].charAt(j)`。

- `words[i].charAt(j) - 'a'` 计算当前字符在字母表中的位置（`'a'` 对应 0，`'b'` 对应 1，依此类推）。

- `1 << (words[i].charAt(j) - 'a')` 将 1 左移到对应的位置，生成一个只有一个位为 1 的整数。

- `nums[i] |= ...` 使用按位或操作将该位设置为 1。

- 字符串 `"abc"` 转换后为 `00000...0111`（最低三位为 1）。

  字符串 `"def"` 转换后为 `00000...111000`（从右往左第 4、5、6 位为 1）。

```java
int[] nums = new int[n];
for (int i = 0; i < n; i++) {
    for (int j = 0; j < words[i].length(); j++) {
        nums[i] |= (1 << (words[i].charAt(j) - 'a'));
    }
}
```

第二步：遍历所有字符串对，计算最大乘积

- 遍历所有字符串对 `(i, j)`。

- 使用按位与运算 

  ```
  nums[i] & nums[j]
  ```

   判断两个字符串是否有重复字符：

  - 如果结果为 0，则说明没有重复字符。

- 如果没有重复字符，计算它们长度的乘积，并更新最大值 `res`。

```java
int res = 0;
for (int i= 0; i < n - 1; i++) {
    for (int j = i + 1; j < n; j++) {
        if ((nums[i] & nums[j]) == 0) {
            res = Math.max(res, words[i].length() * words[j].length());
        }
    }
}
```



## [8. 长度最小的子数组](https://leetcode.cn/problems/2VG8Kg/)

<img src="https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250318164350538.png" alt="image-20250318164350538" style="zoom:67%;" />

用**滑动窗口**的思想，窗口是向右扩张的

一旦出现`sum >= target`的情况，窗口就从左边开始收缩

```java
for (int left = 0, right = 0; right < nums.length; right++) {
    count += nums[right];
    while (left <= right && count >= target) {
        res = Math.min(res, right - left + 1);
        count -= nums[left++];
    }
}
```



## [9. 乘积小于 K 的子数组](https://leetcode.cn/problems/ZVAVXX/)

<img src="https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250318165221578.png" alt="image-20250318165221578" style="zoom: 67%;" />

---

这题和上题思路一样，也是用**滑动窗口**

不过这题求的东西不一样了，这题要求的是满足条件的子数组的个数，而不是最小子数组长度

每一轮的循环，mul代表着以nums[right]为结尾的子数组的乘积之和，因此只有以下情况：

- nums[right]
- nums[right], nums[right - 1]
- nums[right], nums[right - 1], nums[right-2]
- ....
- nums[right], nums[right - 1], nums[right-2],....., nums[left]

这一共有right - left + 1个子数组满足情况

```java
int res = 0, mul = 1;
for (int left = 0, right = 0; right < nums.length; right++) {
    mul *= nums[right];
    while (left <= right && mul >= k) {
        mul /= nums[left++];
    }
    res += right - left + 1;
}
return res;
```





## [10. 和为 K 的子数组](https://leetcode.cn/problems/QTMn0o/)

![image-20250318183737634](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250318183737634.png)

这题允许负数存在，所以不能用滑动窗口（滑动窗口的弊端就是不能用于存在负数的情况）

使用朴素前后缀

已知当前前缀和pre 和 之前的某个前缀和 x

他们的关系是 x + k = pre    ---->  [x, k] = pre

所以x = pre - k，这个x的出现次数 就是 此时 以 nums[i]为结尾的子数组的合法次数

所以要**统计前缀和的出现次数**，使用一个Map集合进行记录

那么 res  +=  map.getOrDefault(pre - k, 0);

初始化：map.put(0, 1)，即不包含任何元素的情况下和为0的次数为1

```java
Map<Integer, Integer> map = new HashMap<>();
int pre = 0, res = 0;
map.put(0, 1);
for (int num : nums) {
    pre += num;
    res += map.getOrDefault(pre - k, 0);
    System.out.println(pre);
    map.put(pre, map.getOrDefault(pre, 0) + 1);
}
```





## [11. 连续数组](https://leetcode.cn/problems/A1NYOS/)

<img src="https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250318213024668.png" alt="image-20250318213024668" style="zoom:67%;" />

---

首先将数组中所有0替换为-1，这样问题就是，在新数组中，找到**和为0的最长子数组的长度**

那么就跟第十题一样了，可以使用最长公共前缀的方法，不过这里求的不是子数组个数，而是最长子数组的长度，那也就是说Map集合的value要更改定义了

这里Map几个的<key, value> = <前缀和，该前缀和首次出现的位置>

接下来还是看前缀和的定义 [k , **s**] = count

**要点**：任何两个位置的前缀和相等，比如`count = k`，那么就说明 s  = 0

```java
for (int i = 0; i < nums.length; i++) {
    count += nums[i];
    if (map.containsKey(count)) {
		res = Math.max(res, i - map.getOrDefault(count, 0));
    } else {
        map.put(count, i);
    }
}
```

**初始化**问题：比如说[-1, 1]，当遍历到 1的时候，子数组的长度 为 1 - map.getOrDefault(0, 0)，它的值应该为2

所以`map.put(0, -1)`



## [12. 寻找数组的中心下标](https://leetcode.cn/problems/tvdfij/)

![image-20250318191041656](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250318191041656.png)

---

也是使用**前缀和思想**

```java
int pre = 0;
for (int i = 0; i < nums.length; i++) {
    int t = sum - nums[i];
    if (t % 2 == 0 && t / 2 == pre) {
        res = i;
        break;
    }
    pre += nums[i];
}
```



## [13. 二维区域和检索 - 矩阵不可变](https://leetcode.cn/problems/O4NDxx/)

![image-20250319201301314](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250319201301314.png)

---

定义一个二维数组

`pre[i][j]`：**第 i  行的前 j 列的前缀和**

显然：`pre[i][j] = martix[i][j] + pre[i][j - 1], j>1`

那么初始化：要初始化第0列，根据定义 `pre[i][0] = martix[i][0]`

```java
for (int i = 0; i < m; i++) {
    for (int j = 0; j < n; j++) {
        if (j == 0) {
            pre[i][j] = martix[i][j];
        } else {
            pre[i][j] = martix[i][j] + pre[i][j - 1];
        }
    }
}
```

最后计算结果就简单了，直接用前缀和数组就完了

```java
public int sumRegion(int row1, int col1, int row2, int col2) {
    int res = 0;
    for (int i = row1; i <= row2; i++) {
        if (col1 == 0) {
            res += pre[i][col2];
        } else {
            res += pre[i][col2] - pre[i][col1];
        }
    }
    return res
}
```



## [14. 字符串的排列](https://leetcode.cn/problems/MPnaiL/)

<img src="https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250319211759527.png" alt="image-20250319211759527" style="zoom: 67%;" />

---

是字母异位字符串的题目，这种题目要用数组、集合、哈希表处理

使用**滑动窗口**，同时维护两个数组

一个数组存 s1 的字母组成，一个数组存窗口内的 字母组成

当两个数组相等的时候就返回true

若遍历结果，还未出现相等的情况，那么返回false

```java
int[] target = new int[26];
for (int i = 0; i < s1.length(); i++) {
    target[s1.charAt(i) - 'a']++;
}

int[] window = new int[26];
for (int left = 0, right = 0; right < s2.length(); right++) {
    window[s2.charAt(right) - 'a']++;
    if (right - left + 1 == s1.length()) {
        if (Arrays.equals(window, target)) {
            return true;
        }
        window[s2.charAt(left++) - 'a']--;
    }
}
return res;
```



## [25. 两数相加 II](https://leetcode.cn/problems/lMSNwu/)

![image-20250320171442872](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250320171442872.png)

---

- 第一种方式：

  将两个链表原地导致，用一个int记录进位，然后加就行了

- 第二种方式：不对链表做反转

  思路：向后递归，递求地位数，归求高位数

  ```java
  public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
      int len1 = length(l1), len2 = length(l2);
      if (len1 > len2) {
          ListNode tn = l1;
          l1 = l2;
          l2 = tn;
          int t = len1;
          len1 = len2;
          len2 = t;
      }
      // len1 <= len2
      ListNode h = new ListNode(0, l2);
      add(h, l1, l2, len1, len2);
      // 最后h节点中可能有后面递归上来的进位，所以要额外判断一下
      return h.val == 0 ? h.next : h;
  }
  
  // pre是结果链表前一个节点
  // 先一直计算每两个节点之和，一只递归到最后一个节点
  // 然后开始从低位往高位进位，因为有pre节点，那么实现就很简单
  private void add(ListNode h, ListNode l1, ListNode l2, int len1, int len2) {
      if (l1 == null && l2 == null) {
          return;
      }
      if (len1 == len2) {
          l2.val += l1.val;
          add(l2, l1.next, l2.next, len1 - 1, len2 - 1);
      // 2. 如果后面商都
      } else {
          add(l2, l1, l2.next, len1, len2 - 1);
      }
      if (l2.val >= 10) {
          h.val++;
          l2.val -= 10;
      }
  
  }
  
  private int length(ListNode node) {
      int res = 0;
      while (node != null) {
          res++;
          node = node.next;
      }
      return res;
  }
  ```

  

## [27. 回文链表](https://leetcode.cn/problems/aMhZSa/)

![image-20250320153607573](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250320153607573.png)

---

1. 先用**快慢指针**找到中间节点

2. 将后半部分链表**原地倒置**

3. 比较前半部分链表和后半部分链表



## [29. 循环有序列表的插入](https://leetcode.cn/problems/4ueAj6/)

![image-20250320203341908](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250320203341908.png)

---

核心思路：找到真正的头节点（最小值），再找插入位置，再插入结点

1. 首先检查这是否是个空链表，如果是空链表，那么直接新建一个结点返回

   ```java
   if (head == null) {
       head = new Node(insertVal, null);
       head.next = head;
       return head;
   }
   ```

2. 找真正的头节点

   注意：可能会出现的情况，就是链表中的值都一样

   ```java
   Node realNode = null;
   Node cur = head, next = head.next;
   while (cur.val <= next.val) {
       cur = cur.next;
       next = next.next;
       // 链表中的值都一样，那么不用再循环了，直接退出
       if (next == head) {
           break;
       }
   }
   realNode = next;
   ```

3. 找插入位置并插入结点

   这个循环有两个特殊情况

   - 插入的值比链表中所有结点的值都要小
   - 插入的值比链表中所有结点的值都要大

   ```java
   // 1. 不执行这个循环，那么说明插入的值比链表中所有结点的值都要小
   while (next.val < insertVal) {
       cur = next;
       next = next.next;
       // 2. 执行一圈了，但还是不行，说明插入的值比链表中所有结点的值都要大
       if (next == head) {
           break;
       }
   }
   
   Node newNode = new Node(insertVal);
   cur.next = newNode;
   newNode.next = next;
   ```

   

## [30. O(1) 时间插入、删除和获取随机元素](https://leetcode.cn/problems/FortPu/)

![image-20250320214137771](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250320214137771.png)

---

使用数组 + map集合

利用数组维护所有插入的元素，map集合记录插入元素在数组中的下标<val, val在数组中的下标>

当删除元素的时候，利用map获得元素下标，然后将数组的最后一个元素覆盖改下标的元素，并删除最后一个元素，同时维护map集合的变化





## [31. LRU 缓存](https://leetcode.cn/problems/OrIXps/)

![image-20250319013417601](https://typora-image-jiege.oss-cn-hangzhou.aliyuncs.com/jiegeisstudyingjava-12581/image-20250319013417601.png)

---

LRU 算法的核心思想可以概括为以下两点：

1. 记录**访问顺序** 

   每次访问一个数据时，将其标记为“最近使用”。

2. 淘汰策略

   当缓存容量达到上限时，优先淘汰**最久未被访问**的数据。

为了高效地实现 LRU 算法，通常会结合两种数据结构：

1. **哈希表**（HashMap） 

   用于快速查找缓存中的数据（时间复杂度 O(1)）。

2. **双向链表**（Doubly Linked List） 

   用于维护数据的**访问顺序**（**最近使用的数据放在链表头部，最久未使用的数据放在链表尾部**）。

**节点**定义

```java
class Node {
    int key, val;
    Node prev, next;
    Node(int key, int val) {
        this.key = key;
        this.val = val;
    }
}
```

**LRU缓存结构**

```java
class LRUCache {
    // Map集合
	private Map<Integer, Node> map;
    // 头尾节点
    private Node head, tail;
    // 缓存容量
    private int capacity;
    
    LRUCache(int capacity) {
        this.map = new HashMap<>();
        this.head = new Node(-1, -1);
        this.tail = new Node(-1, -1);
        this.capacity = capacity;
        head.next = tail;
        tail.prev = head; 
    }
}
```

**操作详情**

- **插入数据**
  - 如果命中缓存，则更新其值，并移到链表头部
  - 如果数据不存在
    - 创建一个新节点，插入到链表头部
    - 将该节点加入到哈希表中
    - 如果缓存已满，则淘汰链表尾部的节点（最久未被访问过的节点）

- **访问数据**
  - 如果数据在缓存中
    - 返回其值
    - 将该节点插入到链表头部（最近使用）
  - 如果数据不在缓存中
    - 返回-1 或者抛异常

- 淘汰策略
  - 当缓存容量达到上限的时候，删除链表尾部的节点，并从哈希表中移除对应的键 

```java
public void put(int key, int val) {
    // 如果缓存中已有该键，那么更新其值，将该节点移动到链表头部
    if (map.containsKey(key)) {
		Node node = map.get(key);
        node.val = val;
        moveToHead(node);
    } else {
        // 如果缓存中没有，那么就将该节点加入到Map集合中，并加入到链表头部
        Node newNode = new Node(key, val);
        map.put(key, newNode);
        addToHead(node);
        // 如果加入该节点后，容量达到上限，那么淘汰链表末尾元素
        if (map.size() > capacity) {
            Node tail = removeTail();
            map.remove(tail.key);
        }
    }
}
```

将节点插入到链表头部

```java
private void addToHead(Node node) {
    node.prev = head;
    node.next = head.next;
    head.next.prev = node;
    head.next = node;
}
```

获取数据

```java
public int get(int key) {
    if (!map.constainsKey(key)) {
        return -1;
    }
    Node node = map.get(key);
    moveToHead(node);
    return node.value;
}
```

删除节点

```java
private void removeNode(Node node) {
    node.prev.next = node.next;
    node.next.prev = node.prev;
}
```

删除末尾节点

```java
private Node removeLast() {
    Node res = tail.prev;
    removeNode(res);
    return res;
}
```

将节点移动到链表首部

```java
private void moveToHead(Node node) {
    removeNode(node);
    addToHead(node);
}
```





```java
// 添加节点到链表头部
private void addToHead(Node node) {
    node.prev = head;
    node.next = head.next;
    head.next.prev = node;
    head.next = node;
}

// 删除节点
private void removeNode(Node node) {
    node.prev.next = node.next;
    node.next.prev = node.prev;
}

// 将节点移到链表头部
```



















你知道吗，这是我今年最开心的一天，我们在玄武湖，在湖畔说着一些有意思的事情，我们一起爬紫金山看日落，相互搀扶着走下台阶，在黑暗中，她，一个没谈过恋爱的人，主动牵我的手，那一刻我是觉得我是那么肮脏、那么的不堪，她却是那么单纯、那么真诚，她是这个春天里最温柔的风、最清澈的水。这是我第一次的如此感受到感情的撕裂，感情不是“喜欢就去追”、“放下就不痛”那么简单，这是一次我真正的经历的，想要又不能要的体验，最美好的瞬间，注定无法拥有。刚才她学我今天说的话，我教她说南京话，我说别学了再学我都没得说了，她说这两句有什么，以后慢慢学......如果世界上的所有美好都可以被持久化占有的话，那么人生就不会有遗憾了，但是现实不是这样，如果我继续沉溺下去的话，我可能会失去所有，不仅伤害她，也伤害lh。我被愧疚、责任、理性撕裂的快要崩溃了。除了你我竟然找不到第二个说话的人，我多希望现在能有个人能不带有色眼睛听完我说的这些话。或许说，这一天的美好就是因为它没有被占有，我要记住她的样子，记住她用手指捏住太阳的样子，记住她对我的笑面如花，记住她把我的手攥在手心的感觉，记住我们在黑暗中牵手的情愫。走出紫金山后，我以看时间的名义，放开了她的手，我觉得我不配享受她的温柔。这是美好的一天，美好的让我无法承受。这一天无法复制，无法重复。今天玄武湖的春风是那么沉醉，山顶的的日落也好美，我们在日落时分约定着，有机会一定来看一次日出，在夏日清凉的凌晨见证一天的开始，我们依偎着看太阳落下，太阳在十分钟之内就完全沉下去了。我问她：“你说太阳去了哪里呢？”她说：“太阳会去他想去的地方。”





我必须承认，要是说对你没感觉那肯定是假的。那一天的经历让我意识到，你是一个特别的人，单纯又温暖。但是，越是这样，我越觉得自己不能轻易对待这份感情。你知道吗，最近我在思考很多关于未来的事情，从短期上来看，我们可以经常空闲时间，去南京或者其他地方玩，我喜欢和你这样。但是从长期角度来看，我接下来的暑期实习、秋招、毕业论文乃至入职，都已经预示着我无法给你足够多的关注和关怀，我知道这有些突然，但是我昨晚一晚都在想这个问题，不是说我看不到与你的未来，而是我自己看不到我自己的未来，也许我明年会去到杭州、上海、深圳工作，这样说的话，我更愿意当成你的最好的朋友，尽管我们认识不久。你的真诚和坦诚让我无法自已，我无法接受我给你的是一个无法确定的未来，你问我大学时候有没有谈过恋爱的时候，我就突然回忆起了我并不想进行一段恋爱关系的想法，我意识到我已经与你在一起度过一整天了，于是我不敢再有半点逾矩行为。我知道这可能不是你想听到的答案，但是我在你的真诚面前无法掩饰半分，我真的想和你成为一个最好的朋友，你叫我什么都行，我永远记得你说的话：“太阳会去到他想去的地方！”



昨晚我想了很多，想跟你认真聊聊

昨天是我这25年来最开心、最特别的一天，我意识到你是一个真诚、单纯、值得珍惜的人。正因为如此，我觉得自己必须更加认真对待这份感情，而不是冲动行事，所以我想坦诚地和你说出我的想法。

我必须承认，我很喜欢和你相处的感觉，这种轻松、真诚的感觉。最近，我在思考很多关于未来的事情，接下来的实习、秋招、论文乃至工作城市都是不确定的，我无法给任何一段感情投入足够的精力，我不想敷衍你的感情。我不想因为现实的变数，让你卷入一段漂浮不定、没有明确方向的关系，那样的话，我会觉得自己在伤害你，我无法接受这样的事情发生。

我知道这肯定不是你一大早想听到的东西，但是我真的希望你能明白，我对你的尊重和珍惜让我必须对你坦诚，我真的希望我们能够以好朋友的方式相处，我知道这在我说出这些话之后也变得很难了，但我还是想说，因为我真切地不想失去你这位朋友，但我也尊重你的想法，不会勉强。如果有一天你觉得可以，我们仍然可以一起去看风景，聊有趣的事情，吃好吃的东西。你昨天说：“太阳会去到他想去的地方。”我在那一瞬间感受到了你的真诚的生命力，感动的我说不出来话来，无论如何，这一天已经刻在了我的脑子里，我想，你也是一样的。



















