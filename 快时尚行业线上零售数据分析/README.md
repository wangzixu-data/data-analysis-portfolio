# SHEIN 跨境快时尚零售数据分析（课程项目）

## 📌 项目概述
基于 SHEIN 跨境快时尚业务场景，使用 **MySQL 8** 完成从**建库建表 → CSV 数据导入 → 数据清洗 → 多维分析**的完整数据分析链路，识别各省市消费贡献、省份 GMV 占比、用户次日留存与月度复购情况，输出可落地的业务结论。

> 本项目为内蒙古工业大学数据科学与大数据技术专业《数据分析》课程设计，数据为公开/模拟数据集，业务场景为模拟分析；分析逻辑与方法论对标真实电商经营分析工作。

## 🎯 业务问题
1. 各省市的消费金额分布如何？哪些省份是消费主力？
2. 各省份消费金额占全国总消费金额的比例是多少？
3. 2018 年 3 月每日新增用户数、次日留存率分别是多少？
4. 2017 年每月的用户复购率如何变化？

## 📊 数据说明
数据以 **6 张业务表 + 1 张区域字典表**组织（均通过 `LOAL DATA INFILE` 从本地 CSV 导入 MySQL）：

| 表名 | 记录数 | 说明 |
|---|---:|---|
| `customers` | 44,661 | 注册用户（ID / 姓名 / 注册时间戳，转标准日期存 `customers_new`） |
| `login_log` | 915 | 用户访问记录（用于留存计算） |
| `orders` | 21,358 | 订单主表（金额 `total_price` / 省 `province` / 市 `city` / 下单时间） |
| `orders_items` | 36,826 | 订单-商品明细（单价 / 数量，支撑品类/GMV 下钻） |
| `products` | 247 | 商品主表（标题 / 商品类型 `product_type`） |
| `products_skus` | 1,356 | 商品 SKU 详情（款式 / SKU / 价格） |
| `regioninfo` | 3,415 | 省/市/区三级区域字典（`province`/`city`/`district` 关联） |

- **合计约 10.9 万条记录**，覆盖用户 / 订单 / 商品 / 区域全链路。
- 数据文件：`数据集.xlsx`（与 `data/` 目录内容一致）、`数据字典.xlsx`（字段说明）。

## 🛠 技术栈
- **MySQL 8**（编写与运行 SQL）
- DDL 建库建表 + `LOAL DATA INFILE` 导入 CSV
- `CREATE TABLE ... AS SELECT`（CTAS）做时间戳→标准日期转换（`FROM_UNIXTIME` + `DATE`）
- 多表 `JOIN`（`orders` 左连 `regioninfo` 省/市）+ `GROUP BY` 聚合 + 子查询
- 日期/窗口函数：`TIMESTAMPDIFF`、`YEAR`、`MONTH`、`DATE`、`FROM_UNIXTIME`
- 留存/复购口径：留存率 = 留存用户数 ÷ 新增用户数；复购率 = 复购用户数 ÷ 当月有购买行为的总用户数
- 可视化：DataGear 看板（`006.zip` 为 DataGear 看板模板，本地解压导入即可复用）

## 🔍 分析方法
1. **建库与数据接入**：`CREATE DATABASE shein` → 6 张业务表 + 区域表 DDL → `LOAL DATA INFILE` 批量导入 CSV。
2. **多维下钻分析**：
   - 各省市消费金额：orders 关联 regioninfo（省/市），按金额降序。
   - 省份 GMV 占比：子查询计算全国 `SUM(total_price)`，各省占比。
3. **用户行为分析**：
   - 2018-03 每日新增用户 + 次日留存率：`customers_new` 左连 `login_log`，`TIMESTAMPDIFF(DAY, created_date, login_date)=1` 判定次日留存。
   - 2017 年每月复购率：按"月份+用户"聚合下单次数，`COUNT(*)>1` 视为复购用户，复购率 = 复购用户数 ÷ 总购买用户数。

## 📈 核心结论

- **省市消费贡献**：通过省市 GMV 聚合可定位消费主力省份与城市，为区域化运营/仓配布局提供依据。
- **省份占比**：各省份占全国 GMV 的比例可识别"高潜市场"（占比 Top 的省份），支撑市场投放优先级决策。
- **用户留存**：2018-03 每日新增用户与次日留存率可监控新客质量；结合 Facebook 40-20-10 法则（次日为 40% 较佳）评估拉新渠道质量。
- **复购率**：2017 年月度复购率反映用户粘性与品类/活动效果，高复购省份/月份可反向指导复购券策略与品类运营。

## 📁 项目结构
```
s、快时尚线上零售数据分析/
├── README.md                    # 本文件
├── shein_任务.sql               # 核心分析 SQL（建库/建表/导入/4 大分析查询）
├── shein_任务.sql.mwb           # MySQL Workbench 数据库模型工程文件
├── 数据集.xlsx                   # 原始数据集（与 data/ 内容一致）
├── 数据字典.xlsx                 # 字段说明
├── 快时尚行业线上零售数据分析报告.pdf  # 完整业务分析报告
├── 006.zip                      # DataGear 可视化看板模板
├── data/                        # 数据表
└── 可视化看板截图                # 看板截图 
```

## 🚀 如何运行
```bash
# 1) 将 customers.csv / orders.csv / orders_items.csv / products.csv /
#    products_skus.csv / login_log.csv / regioninfo.csv 放入
#    MySQL secure_file_priv 指定目录（或按本机路径修改 LOAD DATA INFILE 路径）
# 2) 用 MySQL Workbench  命令行连接本地 MySQL 8
# 3) 按顺序执行 shein_任务.sql：
#    - 建库 shein → USE shein → 建表 → LOAD DATA INFILE 导入
#    - 创建 customers_new（时间戳转日期）
#    - 执行末尾 4 个业务分析查询，查看结果
```

> 注：`shein_任务.sql` 中 `LOAD DATA INFILE` 路径为本地 Windows 绝对路径，克隆仓库后需按本机 `secure_file_priv` 设置修改路径；详见脚本头部关于 `SHOW VARIABLES LIKE 'secure_file_priv';` 的说明。

## 🖼️ 可视化看板（DataGear）
`006.zip` 为本项目 DataGear 可视化看板模板


## 🗄️ 数据库表结构（ER 图）
`shein_任务.sql.mwb` 为 MySQL Workbench 数据库模型工程文件，可用 MySQL Workbench 打开查看/编辑表关系图（ER 图）。



