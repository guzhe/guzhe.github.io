---
title: FineReport报表技巧
author: guz
tags:
  - FineReport
categories:
  - 开发
cover: https://www.helloimg.com/i/2024/02/22/65d6f0622075b.jpg
date: 2024-10-30 13:21:15
---
#### 数据集拼装动态sql条件

${if(len(控件名称) == 0,"","and a.bill_code like '%"+控件名称+"%'")}

#### 常见公式

| 功能描述                                 | 功能实现                              |
| ---------------------------------------- | ------------------------------------- |
| 将日期框组件设置默认值为当前日期         | TODATE()                              |
| 将日期框组件设置默认值为当前月份最后一天 | DATEINMONTH(TODAY(),-1)               |
| 将列汇总                                 | sum(A2)                               |
| 四舍五入，保留2位                        | round(A2, 2)                          |
| 字符串截取                               | left(字符串,位数)，right(字符串,位数) |
| .....                                    | .....                                 |

#### 行交替色设置

![](https://www.helloimg.com/i/2024/10/30/67219ed7c537f.png)





#### 按钮清空所有

在按钮的控件设置中，找到事件，添加一事件，选择JavaScript脚本，脚本内容如下：

~~~
$.each(this.options.form.name_widgets, function(i, item) {
    if(item.options.type !== 'label') {
        item.setValue("");
        item.setText("");
        item.reset();
    }
});
~~~



#### 表格字段过长详情展示方式

1. ##### 公共模态框方式

   新建一个公共模态框报表 ibp_show_field_modal.cpt,接着如下图设置表格字段链接到公共模态框报表中

![](https://www.helloimg.com/i/2024/10/30/6721a239a5c17.png)



2. ##### 鼠标浮动展示

   1. 双击需要展示的A2格子自定义显示中输入：  if(len($$$)>长度,left($$$,长度)+'...',$$$)
   2. 在单元格其他属性，内容提示设置为：=$$$ 即可实现效果

3. ##### js实现

   点击「模板>模板web>分页预览设置」，添加「加载结束事件」 JS 代码如下：

   ~~~
   $("td[title^=cut]").each(function(){
   //获取属性的值
   var str = $(this).attr('title');
   //定义分隔符号
   var length = parseInt(str.split(":")[1]);
   //判断长度
   if($(this).text().length > length){
         $(this).attr('title',$(this).text());
         $(this).text($(this).text().substring(0,length)+'...');
         }else{
         $(this).removeAttr('title');
         }
   })
   ~~~

   在 A2 单元格其他属性，内容提示输入：cut_+A2+:+5 即可实现效果

4. ##### html 实现

   在单元格「形态」处给单元格设置公式形态，公式为：

   ~~~
   "<span style='white-space: nowrap;text-overflow:ellipsis; overflow:hidden; display: inline-block;width:100%;'>"+$$$+"</span>"
   ~~~

   

   当单元格内容超过当前单元格宽度后，显示内容超过的部分会变成省略号(...)，当单元格内容不超过当前单元格宽度时，显示全部内容。

​		在「单元格属性>其他」中，显示内容设置为 「用 HTML 显现内容」，内容提示设置为：=$$$，如下图所示：

5. ##### 控制行高实现

   方式1 ：方式一：点击「单元格>单元格属性>样式>对齐」，设置文本控制为「单行显示」

   方式2：方式二：点击「单元格>单元格属性>其他」，设置为「不自动调整」

> 该方式可直接应用于 JS 或 HTML 控制省略显示时，优点是该列内容仍然会换行显示，导出文档时单元格也是内容换行的样式，并且保证了分页预览时可以根据其他单元格自适应行高。若确有需，在使用该方式的基础上也可以再使用方式一控制内容为单行显示。