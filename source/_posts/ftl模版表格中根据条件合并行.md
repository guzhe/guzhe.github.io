---
title: ftl模版表格中根据条件合并行
categories: 开发
tags:
  - java
  - 工具
cover: https://www.helloimg.com/i/2025/03/31/67ea05a04629e.jpg
# aplayer: true
date: 2025-03-31 21:25:08
---

#### 序章  
> 想到开发中遇到每个ftl模版表格合并行操作时都需要逻辑代码实现比较繁琐，闲着无聊开发个工具解决下。思路是这样的：
每个表格的需要合并列的合并的规则基本一致，也就是数据一样即可在首行的格子设置rowspan，并将除首行外相同数据清空。如以下表格：  
```html
<table border="1">
  <tr>
    <th>年龄</th>
    <th>姓名</th>
  </tr>
  <tr>
    <td>23</td>
    <td>李莉</td>
  </tr>
  <tr>
    <td>23</td>
    <td>王五</td>
  </tr>
   <tr>
    <td>24</td>
    <td>赵四</td>
  </tr>
</table>
```
那这个表格中相同的年龄就可以合并

```html
<table border="1">
  <tr>
    <th>年龄</th>
    <th>姓名</th>
  </tr>
  <tr>
    <!--设置rowspan-->
    <td rowspan="2">23</td>
    <td>李莉</td>
  </tr>
  <tr>
     <!--清空相同的年龄数据-->
    <td></td>
    <td>王五</td>
  </tr>
   <tr>
    <td>24</td>
    <td>赵四</td>
  </tr>
</table>
```
以上，我们理清楚三点：  
1. 需要设置的合并列  
2. 清空的数据列  
3. 设置rowspan的值  
话不多说，开整

#### 步骤1. 新建一个接口RowSpanInterface
```java
public interface RowSpanInterface {
     String rowSpanKey();
     void cleanRowSpanKey();
     void setRowSpan(int row);
}
```

#### 步骤2. 新建ftl模版
```html
<#assign header25="font-size: 11px;font-family: 楷体;text-align: center;font-weight: bold; background-color: #BE0001; color: #FFFFFF;height: 25px;" />
<#assign center9_list_tr="text-align: center;vertical-align: middle;font-size: 10px;font-family: 楷体;height: 25px;" />
<table>
    <caption>战区TOP10</caption>
    <tr style="${header25}">
        <th>临期月</th>
        <th style="border-left-color: #f8e099">top10排名</th>
        <th>园区</th>
        <th>合同编号</th>
        <th>客户名称</th>
        <th>客户集群</th>
        <th>临期未签约面积（m²）</th>
        <th>临期未签约单元</th>
        <th>合同开始日期</th>
        <th>合同结束日期</th>
        <th>合同归属人</th>
        <th>是否KA客户</th>
        <th>客户owner</th>
    </tr>
    <#if areaTop10List??>
        <#list areaTop10List as item>
            <tr style="${center9_list_tr};">
                <#if item.month??>
                    <td rowspan="${item.rowSpan!"1"}">${item.month!""}</td>
                </#if>
                <td>${item.rank!""}</td>
                <td>${item.mallName!""}</td>
                <td>${item.contNo!""}</td>
                <td>${item.customerName!""}</td>
                <td>${item.customerCluster!""}</td>
                <td>${item.unSignedSquare!""}</td>
                <td>${item.unSignedStore!""}</td>
                <td>${item.contStartDate!""}</td>
                <td>${item.contEndDate!""}</td>
                <td>${item.contOwner!""}</td>
                <td>${item.isKACustomer!""}</td>
                <td>${item.customerOwner!""}</td>
            </tr>
        </#list>
    </#if>
```
#### 3. 新建数据模型，并实现接口
```java
@Data
public class AreaTop10VacancyModel implements RowSpanInterface {
    private int rowSpan;
    //临期月
    private String month;
    //top10排名
    private int rank;
    //园区
    private String mallName;
    //合同编号
    private String contNo;
    //客户名称
    private String customerName;
    //客户集群
    private String customerCluster;
    //临期未签约面积
    private String unSignedSquare;
    //临期未签约单元
    private String unSignedStore;
    //合同开始日期
    private String contStartDate;
    //合同结束日期
    private String contEndDate;
    //合同归属人
    private String contOwner;
    //是否KA客户
    private String isKACustomer;
    //客户owner
    private String customerOwner;

    @Override
    public String rowSpanKey() {
        return month;
    }

    @Override
    public void cleanRowSpanKey() {
        this.month = null;
    }
}
```
#### 4. 核心处理类
```java
public class RowSpanHandler {

    public static void handle(List<? super RowSpanInterface> list) {
        // 使用通配符类型进行流操作，避免强制类型转换
        Map<String, Long> countMap = list.stream()
                .map(item -> (RowSpanInterface) item)
                .collect(Collectors.groupingBy(RowSpanInterface::rowSpanKey, Collectors.counting()));
        List<String> cacheKeys = new ArrayList<>();
        for (Object o : list) {
            RowSpanInterface rowSpanInterface = (RowSpanInterface) o;
            int rowSpan = countMap.get(rowSpanInterface.rowSpanKey()).intValue();
            if (cacheKeys.contains(rowSpanInterface.rowSpanKey())) {
                rowSpanInterface.cleanRowSpanKey();
            } else {
                cacheKeys.add(rowSpanInterface.rowSpanKey());
                rowSpanInterface.setRowSpan(rowSpan);
            }
        }
    }
}
```
#### 5. 调用
```java
List<AreaTop10VacancyModel> areaTop10List = getTop10List();
List<? super RowSpanInterface> rowSpanList = new ArrayList<>(areaTop10List);
RowSpanHandler.handle(rowSpanList);
```
至此，相同的临期月排名数据已合并，这个方案后期可以维护升级成多个相同列进行二次合并，如果相同临期月中排名一样的需要再次合并的需求,这里不再赘述
