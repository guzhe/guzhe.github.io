---
title: ftl模版表格中根据条件合并行（AI版）
categories: 开发
tags:
  - java
  - 工具
  - AI
cover: https://www.helloimg.com/i/2025/03/31/67ea05a04629e.jpg
# aplayer: true
date: 2025-10-19 21:25:08
---

#### 提示词  
> 你是个java资深程序员，帮我写个工具类。 需求如下:
场景: 后端java有个集合数据，例如 List<AreaTop10VacancyModel> areaTop10List,前端是ftl模板文件展示表格数据
需求: 后端java经过工具类处理areaTop10List，使得前端ftl模板中的表格数据能够将一样的数据自动合并行。
请检查一下FTL语法问题后输出后端java工具类代码 

经过不断的调试和优化后，最终代码如下：
改进后的FTL模板
```html
<table border="1">
    <thead>
        <tr>
            <#list fieldIndexMap?keys as field>
                <#if field == "area"><th>区域</th>
                <#elseif field == "building"><th>楼宇</th>
                <#elseif field == "vacancyRate"><th>空置率</th>
                <#else><th>${field}</th></#if>
            </#list>
        </tr>
    </thead>
    <tbody>
        <#list dataList as row>
            <tr>
                <#list fieldIndexMap?keys as field>
                    <#assign cellMergeInfo = mergeInfo[row?index][field]>
                    <#if cellMergeInfo.rowspan gt 0>
                        <td rowspan="${cellMergeInfo.rowspan}">
                            <#if field == "area">${row.area!''}
                            <#elseif field == "building">${row.building!''}
                            <#elseif field == "vacancyRate">${row.vacancyRate!''}
                            <#else>${row[field]!''}</#if>
                        </td>
                    </#if>
                </#list>
            </tr>
        </#list>
    </tbody>
</table>
```

#### 改进后的工具类
```java
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 表格行合并工具类（支持字段名自动映射）
 * 用于处理前端表格中相同数据的行合并
 */
public class TableRowMergeUtil {

    /**
     * 合并信息对象
     */
    public static class MergeInfo {
        private int row;        // 行索引
        private String field;   // 字段名
        private int rowspan;    // 合并的行数

        public MergeInfo(int row, String field, int rowspan) {
            this.row = row;
            this.field = field;
            this.rowspan = rowspan;
        }

        // Getter方法
        public int getRow() { return row; }
        public String getField() { return field; }
        public int getRowspan() { return rowspan; }
    }

    /**
     * 合并结果包装类
     */
    public static class MergeResult<T> {
        private List<T> dataList;           // 原始数据列表
        private List<Map<String, MergeInfo>> mergeInfo; // 按字段名组织的合并信息
        private Map<String, Integer> fieldIndexMap; // 字段名到显示顺序的映射

        public MergeResult(List<T> dataList, List<Map<String, MergeInfo>> mergeInfo, 
                          Map<String, Integer> fieldIndexMap) {
            this.dataList = dataList;
            this.mergeInfo = mergeInfo;
            this.fieldIndexMap = fieldIndexMap;
        }

        // Getter方法
        public List<T> getDataList() { return dataList; }
        public List<Map<String, MergeInfo>> getMergeInfo() { return mergeInfo; }
        public Map<String, Integer> getFieldIndexMap() { return fieldIndexMap; }
        
        /**
         * 获取指定行和字段的合并信息
         */
        public MergeInfo getMergeInfo(int row, String field) {
            if (row < mergeInfo.size()) {
                return mergeInfo.get(row).get(field);
            }
            return null;
        }
    }

    /**
     * 自动合并所有指定字段的行
     * @param dataList 原始数据列表
     * @param fieldNames 需要合并的字段名数组（按显示顺序）
     * @param <T> 数据类型
     * @return 包含合并信息的结果对象
     */
    public static <T> MergeResult<T> mergeRows(List<T> dataList, String[] fieldNames) {
        if (dataList == null || dataList.isEmpty() || fieldNames == null || fieldNames.length == 0) {
            return new MergeResult<>(dataList, new ArrayList<>(), new HashMap<>());
        }

        // 创建字段名到显示顺序的映射
        Map<String, Integer> fieldIndexMap = new HashMap<>();
        for (int i = 0; i < fieldNames.length; i++) {
            fieldIndexMap.put(fieldNames[i], i);
        }

        // 初始化合并信息列表（每行一个Map，key为字段名）
        List<Map<String, MergeInfo>> mergeInfo = initializeMergeInfo(dataList.size(), fieldNames);
        
        // 为每个字段计算合并信息
        for (String field : fieldNames) {
            calculateMergeInfoForField(dataList, field, mergeInfo);
        }

        return new MergeResult<>(dataList, mergeInfo, fieldIndexMap);
    }

    /**
     * 初始化合并信息列表
     */
    private static List<Map<String, MergeInfo>> initializeMergeInfo(int rowCount, String[] fieldNames) {
        List<Map<String, MergeInfo>> mergeInfo = new ArrayList<>();
        for (int i = 0; i < rowCount; i++) {
            Map<String, MergeInfo> rowInfo = new HashMap<>();
            for (String field : fieldNames) {
                rowInfo.put(field, new MergeInfo(i, field, 1)); // 默认每个单元格rowspan=1
            }
            mergeInfo.add(rowInfo);
        }
        return mergeInfo;
    }

    /**
     * 计算指定字段的合并信息
     */
    private static <T> void calculateMergeInfoForField(List<T> dataList, String field, 
                                                      List<Map<String, MergeInfo>> mergeInfo) {
        int startRow = 0;
        int currentRow = 1;
        
        while (currentRow < dataList.size()) {
            Object prevValue = getFieldValue(dataList.get(startRow), field);
            Object currValue = getFieldValue(dataList.get(currentRow), field);
            
            if (isEqual(prevValue, currValue)) {
                // 值相同，继续向下查找
                currentRow++;
            } else {
                // 值不同，处理合并
                if (currentRow - startRow > 1) {
                    setRowspanForField(mergeInfo, startRow, field, currentRow - startRow);
                }
                startRow = currentRow;
                currentRow++;
            }
        }
        
        // 处理最后一组相同值
        if (currentRow - startRow > 1) {
            setRowspanForField(mergeInfo, startRow, field, currentRow - startRow);
        }
    }

    /**
     * 设置指定字段的合并信息
     */
    private static void setRowspanForField(List<Map<String, MergeInfo>> mergeInfo, 
                                         int row, String field, int rowspan) {
        mergeInfo.get(row).get(field).rowspan = rowspan;
        
        // 将被合并的行对应的单元格rowspan设为0（表示不显示）
        for (int i = row + 1; i < row + rowspan; i++) {
            mergeInfo.get(i).get(field).rowspan = 0;
        }
    }

    /**
     * 获取对象的字段值（使用反射）
     */
    private static Object getFieldValue(Object obj, String fieldName) {
        try {
            java.lang.reflect.Field field = obj.getClass().getDeclaredField(fieldName);
            field.setAccessible(true);
            return field.get(obj);
        } catch (Exception e) {
            throw new RuntimeException("获取字段值失败: " + fieldName, e);
        }
    }

    /**
     * 比较两个对象是否相等（处理null值）
     */
    private static boolean isEqual(Object obj1, Object obj2) {
        if (obj1 == null && obj2 == null) return true;
        if (obj1 == null || obj2 == null) return false;
        return obj1.equals(obj2);
    }
}
```

#### mock示例
```
@Controller
public class MyController {
    
    @RequestMapping("/areaData")
    public String getAreaData(Model model) {
        // 获取原始数据
        List<AreaTop10VacancyModel> areaTop10List = getMockData();
        
        // 指定需要合并的字段（顺序决定前端显示顺序）
        String[] mergeFields = {"area", "building", "vacancyRate"};
        
        // 使用工具类处理数据
        TableRowMergeUtil.MergeResult<AreaTop10VacancyModel> result = 
            TableRowMergeUtil.mergeRows(areaTop10List, mergeFields);
        
        // 将结果添加到模型
        model.addAttribute("dataList", result.getDataList());
        model.addAttribute("mergeInfo", result.getMergeInfo());
        model.addAttribute("fieldIndexMap", result.getFieldIndexMap());
        
        return "areaDataTemplate";
    }
    
    private List<AreaTop10VacancyModel> getMockData() {
        List<AreaTop10VacancyModel> areaTop10List = new ArrayList<>();
        
        AreaTop10VacancyModel areaTop10Model1 = new AreaTop10VacancyModel();
        areaTop10Model1.setArea("广州");
        areaTop10Model1.setBuilding("中山大学");
        areaTop10Model1.setVacancyRate(10);
        areaTop10List.add(areaTop10Model1);
        
        AreaTop10VacancyModel areaTop10Model2 = new AreaTop10VacancyModel();
        areaTop10Model2.setArea("广州");
        areaTop10Model2.setBuilding("中山大学111");
        areaTop10Model2.setVacancyRate(10);
        areaTop10List.add(areaTop10Model2);
        
        AreaTop10VacancyModel areaTop10Model3 = new AreaTop10VacancyModel();
        areaTop10Model3.setArea("深圳");
        areaTop10Model3.setBuilding("南山区");
        areaTop10Model3.setVacancyRate(20);
        areaTop10List.add(areaTop10Model3);
        
        return areaTop10List;
    }
}
```