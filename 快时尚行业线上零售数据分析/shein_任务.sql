-- 创建数据库
create database shein;

-- 打开数据库
use shein;

-- 查看数据库中的数据表
show tables in shein;

-- -------------------------------------------------------------
-- 在 MySQL 8 中，控制 LOAD DATA INFILE 可以读取的文件位置的主要设置是secure_file_priv系统变量。

-- 1) 查看当前设置
-- 要查看secure_file_priv的当前值，可以执行以下 SQL 语句：
SHOW VARIABLES LIKE 'secure_file_priv';

-- 这个变量的可能取值含义：
-- -- 如果值为某个目录路径（如 C:\ProgramData\MySQL\MySQL Server 8.0\Uploads），表示只能从该目录加载文件
-- -- 如果值为NULL，表示禁止使用 LOAD DATA INFILE
-- -- 如果值为空字符串''，表示可以从任意位置加载文件

-- 2) 修改设置以允许从任意位置导入
-- 要修改这个设置，需要修改 MySQL 配置文件（通常是my.cnf或my.ini）：
-- -- 通常位于 MySQL 安装目录的my.ini（例如C:\ProgramData\MySQL\MySQL Server 8.0\my.ini）
-- -- 注意：ProgramData 文件夹可能是隐藏的，需要先开启 "显示隐藏文件"
-- 编辑配置文件my.ini，在[mysqld]部分添加或修改以下行：secure_file_priv = ""。（空字符串表示允许从任意位置导入文件）
-- 重启 MySQL 服务使配置生效：
-- -- Linux 系统通常使用：systemctl restart mysqld 或 service mysql restart。
-- -- Windows 系统可以在服务管理器中重启 MySQL 服务。（按下Win + R，输入services.msc打开服务管理器；找到MySQL80服务（名称可能因版本略有不同）；右键选择 "重启"）

-- 3) 再次执行SHOW VARIABLES LIKE 'secure_file_priv';确认设置已生效

-- --------------------------------------------------------------------------------------------------------
-- 1）注册用户表customers
create table customers(
	id varchar(15) primary key,
    full_name varchar(30),
    created_at int
);

-- load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.2\\Uploads\\customers.csv"
load data infile "E:\\shein\\data\\customers.csv"
into table customers 
fields terminated by ',' 
ignore 1 lines;

-- 验证数据
select * from customers limit 10;
-- 统计数据量
select count(*) from customers;      -- 44661

-- 删除数据表
-- drop table customers;

-- 将时间戳转换标准的日期格式，并保存到新表
-- 使用CTAS语法
create table customers_new as
select 
    id,
    full_name,
    date(from_unixtime(created_at)) as created_date 
from customers;

select * from customers_new limit 100;

-- 2）访问记录表login_log
create table login_log(
	id varchar(5) primary key,
    customer_id varchar(15),
    login_date date
);

-- load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.2\\Uploads\\login_log.csv"
load data infile "E:\\shein\\data\\login_log.csv"
into table login_log 
fields terminated by ',' 
ignore 1 lines;

select * from login_log limit 10;
select count(*) from login_log;    -- 915

-- drop table login_log;

-- 3）订单主表orders
create table orders(
	id varchar(15) primary key,
    created_at date,
    closed_at date,
    cancelled_at date,
    customer_id varchar(15),
    country char,
    province varchar(4),
    city varchar(4),
    district varchar(4),
    address varchar(100),
    financial_status varchar(20),
    fulfillment_status varchar(10),
    processed_at date,
    total_price decimal(6,2),
    shipping_rate decimal(6,2),
    subtotal_price decimal(6,2),
    total_discounts decimal(6,2),
    total_line_items_price decimal(6,2)
);

-- load data in-- file "C:\\ProgramData\\MySQL\\MySQL Server 8.2\\Uploads\\orders.csv" 
load data infile "E:\\shein\\data\\orders.csv"
into table orders 
fields terminated by ','
ignore 1 lines;

select * from orders limit 10;
select count(*) from orders;    -- 21358

-- drop table orders;

-- 4）订单详情表orders_items
create table orders_items(
	id varchar(15) primary key,
    order_id varchar(15),
    product_style varchar(50),
    variant_id varchar(15),
    fulfillment_status varchar(10),
    price decimal(6,2),
    quantity int
);

-- load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.2\\Uploads\\orders_items.csv" 
load data infile "E:\\shein\\data\\orders_items.csv"
into table orders_items 
fields terminated by ','
ignore 1 lines;

select * from orders_items limit 10;
select count(*) from orders_items;    -- 36826

-- drop table orders_items;

-- 5）商品主表products
create table products(
	id varchar(15) primary key,
    title varchar(50),
    product_type varchar(15),
    created_at date,
    published_at date
);

-- load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.2\\Uploads\\products.csv"
load data infile "E:\\shein\\data\\products.csv"
into table products 
fields terminated by ',' 
ignore 1 lines;

select * from products limit 10;
select count(*) from products;       -- 247

-- drop table products;

-- 6）商品详情表products_skus
create table products_skus(
	id varchar(15) primary key,
    product_id varchar(15),
    product_style varchar(50),
    sku varchar(50),
    created_at date,
    price decimal(6,2)
);

-- load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.2\\Uploads\\products_skus.csv" 
load data infile "E:\\shein\\data\\products_skus.csv"
into table products_skus 
fields terminated by ',' 
ignore 1 lines;

select * from products_skus limit 10;
select count(*) from products_skus;		-- 1356

-- drop table products_skus;

-- 区域表regioninfo
create table regioninfo(
	regionid varchar(4) primary key,
    parentid varchar(4),
    regionname varchar(20),
    regiontype char
);

-- load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.2\\Uploads\\regioninfo.csv"
load data infile "E:\\shein\\data\\regioninfo.csv"
into table regioninfo 
fields terminated by ',' 
ignore 1 lines;

select * from regioninfo limit 10;
select count(*) from regioninfo;	-- 3415

-- drop table regioninfo;

-- 查看数据表
select * from customers;
select * from orders;
select * from orders_items;
select * from products;
select * from products_skus;
select * from regioninfo;

-- ------------------------------------------------------------------------------------------------------------------------
-- 1）统计各省市的消费金额。
-- 分析：省份、城市、订单总金额
select 
		p.regionname as 省份,
        c.regionname as 城市,
        sum(total_price) as 订单总金额
from orders o 
left join regioninfo p on o.province = p.regionid
left join regioninfo c on o.city = c.regionid
group by p.regionname,c.regionname
order by 订单总金额 desc;

-- 2）统计各省份消费金额在全国总消费金额中的占比。
select
		p.regionname as 省份,
        sum(total_price)/(select sum(total_price) from orders) as 占比
from orders o 
left join regioninfo p on o.province = p.regionid
group by p.regionname;
-- 3）查询2018年3月每天的新增用户数、次日留存率、两日留存率、三日留存率
-- 注：留存率=留存用户数/新增总用户数
/*
-- 概念：用户留存和用户留存率
-- 在用户行为分析和业务数据统计中，用户留存和用户留存率是衡量产品粘性、用户活跃度及长期价值的核心指标，
--      尤其在互联网产品（如 APP、网站、SaaS 工具等）运营中应用广泛。 

-- 一、什么是用户留存？
-- 用户留存指的是 “在某个时间点新增的用户，在后续特定时间点（如次日、7 日后、30 日后）仍然活跃使用产品的现象”。
-- 它反映了产品对用户的吸引力 —— 留存越好，说明用户对产品的需求越稳定，产品价值越被认可。
-- 核心逻辑：
-- -- 以 “新增用户” 为起点（通常称为 “基准用户”），跟踪这些用户在后续时间是否继续使用产品。
-- -- 例如：1 月 1 日新增了 100 个用户，1 月 2 日这 100 人中仍有 30 人使用产品，这 30 人就是 1 月 1 日新增用户的 “次日留存用户”。

-- 二、什么是用户留存率？
-- 用户留存率是留存用户数占基准用户数的比例，计算公式为：用户留存率 = （特定时间点的留存用户数 ÷ 基准用户数）× 100%
-- 常见的留存率类型（按时间维度）：
-- （1）次日留存率：基准用户在新增后第 2 天仍活跃的比例（如 1 月 1 日新增用户，1 月 2 日的留存率）。
-- （2）7 日留存率：基准用户在新增后第 7 天仍活跃的比例（如 1 月 1 日新增用户，1 月 8 日的留存率）。
-- （3）30 日留存率：基准用户在新增后第 30 天仍活跃的比例，常用于衡量长期粘性。
-- 示例：
-- 某 APP 在 5 月 1 日新增了 200 个用户，5 月 2 日有 80 人活跃，5 月 8 日（7 天后）有 40 人活跃。
-- -- 次日留存率 = 80 ÷ 200 × 100% = 40%
-- -- 7 日留存率 = 40 ÷ 200 × 100% = 20%

-- 三、留存率的意义
-- （1）衡量产品价值：高留存率说明产品能满足用户核心需求（如微信的社交需求、抖音的娱乐需求）。
-- （2）优化产品策略：低留存率可能提示产品存在问题（如功能复杂、内容质量低），需针对性改进。
-- （3）指导运营决策：通过对比不同渠道、不同活动带来的用户留存率，判断渠道 / 活动的质量（如 “通过广告 A 新增的用户7日留存率 50%，广告B仅20%”，则优先投入广告 A）。
-- 根据Facebook的40-20-10法则，日留存、周留存、月留存能达到40%、20%、10%即为较佳水平。
*/
select
	created_date,
    count(distinct customers_new.id) as 新增用户数,
    sum(timestampdiff(day,created_date,login_date)=1) as 次日留存用户数,
    sum(timestampdiff(day,created_date,login_date)=1)/count(distinct customers_new.id) as 次日留存率
from 
	customers_new
left join
	login_log on customers_new.id=login_log.customer_id
where
	year(created_date)=2018 and month(created_date)=3
group by
	created_date;

-- 4）查询2017年每月的复购率（每月复购率=每月发生复购的用户数/该月有过购买行为的总用户数）
with t as (
	select
		month(created_at) as 月份,
        customer_id,
        count(*) as 下单次数,
        count(*)>1 as 是否复购
	from orders
    where year(created_at) = 2017
    group by month(created_at),customer_id
)
select
	月份,
    sum(是否复购) as 复购用户数,
    count(是否复购) as 总用户数,
     sum(是否复购)/ count(是否复购) as 复购率
from t
group by 月份;
	
/*
-- 一、复购
-- 复购（Repeat Purchase）指的是同一用户在一定时间内对同一品牌或产品进行多次购买的行为。
-- 它强调 “用户对品牌 / 产品的持续选择”，反映用户对产品的认可程度和长期需求。
-- 示例：
--   消费者 A 在 1 月购买了某品牌的洗发水，3 月再次购买该品牌同款洗发水，这一行为属于复购。
--   （注：复购通常不严格限制购买间隔，只要是同一用户的多次购买即可，时间范围可根据业务场景定义，如 “30 天内”“1 年内” 等。）

-- 二、复购率
-- 复购率（Repeat Purchase Rate）是衡量复购行为的量化指标，指在一定时间内，发生过复购的用户数占总购买用户数的比例。
-- 它反映了用户群体中 “持续购买用户” 的占比，直接体现品牌对用户的留存能力。
-- 1. 计算公式: 复购率 =（一定时间内发生复购的用户数 ÷ 同一时间内有过购买行为的总用户数）× 100%
-- 2. 关键说明
--   “复购用户”：指在统计周期内至少完成 2 次购买的用户（即至少包含 1 次回购）。
--   时间范围：需明确统计周期（如 “30 天”“90 天”“1 年”），不同周期的复购率差异较大（例如快消品的 30 天复购率可能高于耐用品）。
--   总用户数：指统计周期内有过至少 1 次购买的用户总数（包含首次购买用户和复购用户）。
-- 3. 示例
--   某电商平台在 10 月有 1000 个用户产生购买，其中 300 个用户在 10 月内购买了 2 次及以上（即复购用户），则 10 月的复购率为：
--   300 ÷ 1000 × 100% = 30%


-- 三、指标的业务意义
-- 复购：反映用户对产品的信任度和需求稳定性。高复购意味着用户粘性强，可降低获客成本（无需为这些用户重复投入拉新费用）。
-- 复购率：
--（1）是评估产品竞争力的重要指标（复购率高说明产品满足用户核心需求，替代成本高）；
--（2）可用于对比不同用户群体（如新用户 vs 老用户）、不同产品或不同营销活动的效果（如 “活动 A 带来的用户复购率高于活动 B”，说明 A 的用户质量更优）。
*/


