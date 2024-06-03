---
title: poi结合模板引擎导出word
categories: 后端技术 
tags:
  - java
  - poi
  - word
cover: https://vip.helloimg.com/i/2024/02/22/65d6f06278db4.jpg  
date: 2024-03-05 18:15:00
---


#### 前言
最近一期需求开发遇到导出一个复杂的word用代码实现巨难受，特意找了个便捷方法实现  

#### 依赖
~~~maven
 		<dependency>
            <groupId>cn.hutool</groupId>
            <artifactId>hutool-all</artifactId>
            <version>5.7.10</version>
        </dependency>
        <dependency>
            <groupId>cn.afterturn</groupId>
            <artifactId>easypoi-base</artifactId>
            <version>4.4.0</version>
        </dependency>
~~~
#### 代码实现

~~~java
  public static void main(String[] args) throws Exception {
        StringWriter writer = new StringWriter();
        JSONObject json = new JSONObject();
        json.put("name", "张三");
        // 创建模板引擎
        TemplateEngine templateEngine = TemplateUtil.createEngine();
        Template template = templateEngine.getTemplate(getContent());
        // 合并模板和数据
        template.render(json, writer);
        String templateContent = writer.toString();
        htmlToWord(templateContent);
    }

    public static void htmlToWord(String htmlString) throws Exception {


        FileOutputStream out = new FileOutputStream(new File("D:/wordWrite.doc"));
        InputStream is = new ByteArrayInputStream(htmlString.getBytes("UTF-8"));
        POIFSFileSystem fs = new POIFSFileSystem();
        //对应于org.apache.poi.hdf.extractor.WordDocument
        fs.createDocument(is, "WordDocument");
        fs.writeFilesystem(out);
        is.close();
        out.close();
    }

    private static String getContent() {
        String s = "<!DOCTYPE html>\n" +
                "<html lang=\"en\">\n" +
                "<head>\n" +
                "    <meta charset=\"UTF-8\">\n" +
                "    <title>Title</title>\n" +
                "</head>\n" +
                "<body>\n" +
                "    <P>${name} 这是名字</P>\n" +
                "</body>\n" +
                "</html>";
        return s;
    }
~~~

#### 一些表单html简单示例
* 收据
~~~html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>收据</title>
</head>
<body>
    <style>
        * {
            margin: 0;
            padding: 0;
        }
        .container {
            height: 100%;
            margin: 10px;
        }
        .title {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 20px;
            width: 100%;
            text-align: center;
        }
        .table,
        .table-title {
            margin-top: 20px;
        }
        .on {
            display: block;
        }
        .off {
            display: none;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
    </style>
    <div class="container">
        <div class="title">收据</div>
            <table>
                <tr>
                    <td>收据日期：${receiptDate}</td>
                    <td style="text-align: right;" class="${display}">收款对象：${customerName}</td>
                </tr>
            </table>
            <div class="table-title">费用明细：</div>
            <table border="1">
                <thead>
                    <tr>
                        <th>项目</th>
                        <th>单价</th>
                        <th>数量</th>
                        <th>金额</th>
                    </tr>
                </thead>
                <tbody>
                <#list costList as cost>
                <tr>
                    <td>${cost.name}</div>
                    <td>${cost.price}</div>
                    <td>${cost.amount}</div>
                    <td>${cost.money}</div>
                </tr>
                </#list>
            </table>
            <table style="margin-top:20px">
                <tr>
                    <td>收款单位：${companyName}</td>
                    <td style="text-align: right;">交款人：${payer}</td>
                </tr>
            </table>
</body>
</html>
~~~

#### 总结
以上就是代码示例内容，只要掌握html和css就可以基本解决word的复杂样式内容

***但请注意以下几点问题***

1. html 格式导出的word格式为doc,只有doc格式支持，docx不支持html,如需要转换docx可引入其他工具类进行转换
 > ps:*（word软件自身就可以转换没必要去实现这个，产品非得要实现纯属于故意为之~）*  
2. html 中尽量使用table,p,span等元素标签 

3. html 中的引用使用ftl模版引擎

4. css样式有些并不支持，比如flex,div中设置width=百分比等等


终于不用为调样式而烦恼了🥰~  



