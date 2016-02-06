---
layout: post
title:  JS深度克隆
date:   2016-01-20 
categories: Javascript
tags: [blog]  
summary: 有关JS深度克隆的一些笔记
image: /image/JS.jpg
---
js一般有两种不同数据类型的值： 

　　基本类型（包括undefined,Null,boolean,String,Number），按值传递； 

　　引用类型（包括数组，对象），按址传递，引用类型在值传递的时候是内存中的地址。 

克隆或者拷贝分为2种： 

　　浅度克隆：基本类型为值传递，对象仍为引用传递。 

　　深度克隆：所有元素或属性均完全克隆，并于原引用类型完全独立，即，在后面修改对象的属性的时候，原对象不会被修改。

下面是有关深度克隆的一个例码：
{% highlight ruby %}
 // 使用递归来实现一个深度克隆，可以复制一个目标对象，返回一个完整拷贝
// 被复制的对象类型会被限制为数字、字符串、布尔、日期、数组、Object对象。不会包含函数、正则对象等
function cloneObject(src) {
   var o; //result
   if (Object.prototype.toString.call(src) === "[object Array]") {
   o = []; //判断是否是数组，并赋初始值
   } 
   else {
   o = {};
   }
   for (var i in src) { //遍历这个对象
   if (src.hasOwnProperty(i)) { //排出继承属性
   if (typeof src[i] === "object") {
   o[i] = cloneObject(src[i]); //递归赋值
   } 
   else {
   o[i] = src[i]; //直接赋值
   }
   }
   }
   return o;
}
{% endhighlight%}
