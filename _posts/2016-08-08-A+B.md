---
layout: post
title: A+B Format
date:   2016-08-08
categories: C
tags: [blog]  
summary: PAT甲级题库的第一题
image: /image/PAT.png
---
前言：好久没有更新博客了，因为实习的缘故，自己也懒，我想从今天开始又要开始更新自己的博客了，争取写出高质量的博文

最近两天，看到知乎上[陈越姥姥](https://www.zhihu.com/people/chen-yue-lao-lao)“不遗余力”地宣传PAT考试，我好奇之余又进一步了解了一下PAT考试(虽然之前知道这是浙大主办的一项编程考试)，原来分为三个等级：顶级，甲级，乙级，难度依次递减。

我觉得既然我已经踏进计算机这个门了，那么如果要参加PAT考试想必也是甲级吧，毕竟涉及到初级算法和数据结构那些的，于是我想当然地打开了[官网题库](https://www.patest.cn/contests/pat-a-practise),看到第一题：A+B Format

题目的描述是这样的：Calculate a + b and output the sum in standard format -- that is, the digits must be separated into groups of three by commas (unless there are less than four digits).

Input

Each input file contains one test case. Each case contains a pair of integers a and b where -1000000 <= a, b <= 1000000. The numbers are separated by a space.

Output

For each test case, you should output the sum of a and b in one line. The sum must be written in the standard format.

Sample Input
-1000000 9
Sample Output
-999,991

一开始没有细看题目的要求，我想当然地以为就是简单的a+b编程运算，结果编完提交发现没有通过，原来，这题目要求要用千位格式输出。由于好久没有写C的代码了，我试着在网上找了一段代码：

{% highlight ruby %}
  #include<stdio.h>  
int main()  
{  
  int a,b;  
  int sum;  
  while(scanf("%d%d\n",&a,&b) != EOF){  
    sum = a+b;  
    if(sum < 0){  
    printf("-");  
    sum = -sum;  
    }  
    if(sum>=1000000){  
        printf("%d,%03d,%03d\n",sum/1000000, (sum/1000)%1000, sum%1000);  
    }  
    else if(sum >= 1000){  
        printf("%d,%03d\n",sum/1000,sum%1000);  
    } else{  
        printf("%d\n", sum);  
    }  
  }  
  return 0;  
}
{% endhighlight%}

我不是很明白为什么要用while(scanf("%d%d\n,&a,&b)!=EOF)来包含逻辑代码，并且当删掉while{}后，在10个测试用例中，只有一个能通过的，百度了一下，发现这是在ACM等在线OJ上的特有写法，为的是应付多组输入数据，因为OJ经常要输入很多组的验证数据，并且输入的是一个文件，EOF=End of File,执行程序时，只要有输入并且输入的值格式正确的话都会执行循环里的语句，当输入为空时，返回0。

按网上的指示，我试着输入ctrl+z（撤销）,结果返回0。

第一次见到要采用这样的规定格式才能AC的，看来以后有输入的情况都要这么写了。



