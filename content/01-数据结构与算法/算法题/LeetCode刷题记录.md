---
title: LeetCode刷题记录
category: 算法
tags:
  - 408
  - 算法
status: published
created: 2026-04-09
updated: 2026-06-26
memory: false
publish: true
---

```cpp
#include <vector>  //库的引用格式，后面不加分号
#include <unordered_map>
using namaspace std;//使用标准命名，语句，后加分号
///定义类
class Solution {

public://成员函数

    vector<int> twoSum(vector<int>& nums, int target) { //返回值为int型容器的twoSum函数（函数输入参数对于nums的引用，目标值）

        unordered_map<int,int> nums_map;//定义一个nums——map的哈希表

        for (int i = 0; i < nums.size();i++){  //for(初始值；循环条件；增量){}注意括号里面都是语句用分号隔开

            int num = nums[i]; //将容器下表为i的数取出来定义整型变量便于计算

            int complement = target - num;

            if (nums_map.find(complement) != nums_map.end()){ //stl标准库语句

                return {nums_map[complement],i};

  

            }

        nums_map[num] = i;

        }

    return {};

   }

  

};
```
```cpp
// 测试示例 
int main() { 
Solution s; 
vector<int> nums = {2, 7, 11, 15}; 
int target = 9; 
vector<int> result = s.twoSum(nums, target); // 输出：0 1 
for (int idx : result)
 { cout << idx << " "; }
  return 0; 
  }
```

## 相关链接
- [[Fibonacci数列]]
- [[杨辉三角]]
- [[滑动窗口相关性模型]]
- [[差分进化与遗传算法]]
- [[蒙特卡洛模拟]]
- [[数据结构]]
