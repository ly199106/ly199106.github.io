---
layout: post
title:  "How to judge whether the input is an array"
date:   2016-01-20 
categories: jekyll update
---
* OK,it is my first note-book blog,I've write in English because currently I don't know how to write jekyll blog in Chinese.When I tried to write something on it in Chinese,I sadly find the part in Chinese can be displayed on the screen.There must be something wrong with my default settings with jekyll(I promise I will solve this problem some days later).Now that it can only be noted in English,I would rather see it as a chance to improve my English writting.

* Well let's back on today's theme.Recent days I've study at Baidu-ife on github.The first task I've jumped over, though I am still a freshman of front-end.I came to task0002,which teaches me lessons of Javascript.The first two question I met is:

 * 1.How to judge whether the input is an array?
 * 2.How to judge whether the input is an array?

   Obviously they are very simple questions, at least at my first look.What I need to do is to write two functions in JS to solve the above.Without much thought,I've write down my codes like the following:
     
    // 判断arr是否为一个数组，返回一个bool值
     function isArray(arr)
    {
    // your implement
	if(arr instanceof Array)
	return true;
	else
	return false;
    }

    // 判断fn是否为一个函数，返回一个bool值
    function isFunction(fn)
    {
    // your implement
	if(typeof fn=== 'function')
	return true;
	else
	return false;
    }

To be continue...
