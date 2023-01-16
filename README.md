# 591租屋網「租屋補助」分析專案 Part2-MYSQL資料處理　　
  
## 專案背景
　　身為經營管理專員，我為了加強自己在數據分析領域的工具與技能，自學基礎的Python、MYSQL程式語言，以及Power BI視覺化工具。同時，身為社工師的親友經常需要協助案主找尋合適且適用「租金補助」申請的租屋，並致力於弱勢租屋議題的研討。因此藉此機會，我希望能運用所學的基礎能力，實作關於「租金補助」的程式專案，**分析租屋市場樣貌，並在過程中學習解決程式問題並產出成果的能力，累積經驗與作品**。  
    
## 分析目的
　　為瞭解適用「租金補助」之案件在租屋市場上與一般租屋之樣貌差異，截取2022年12月20日591租屋網上的台北市與新北市的租屋案件作為分析資料。後續按以下三種租屋類別進行分析：　　
1. **一般租屋**：包含全部資料，意為租屋市場整體樣貌。
2. **租補**：包含在「標題」與「屋主說」中有租補相關關鍵字之資料，意為能申請租補之案件的整體樣貌。
3. **租補且非社宅**：因租補與社會住宅屬性不同，但在租屋網上常有同時存在或混用的狀況，因此將社會住宅篩除，以「租補且非社宅」類別分析較純粹的租補樣貌。  
    
## 作法架構  
1. [資料取得與儲存：Python](https://github.com/dujun101620/591RENT-PART1-Web_Crawler)
2. **資料清理與處理：MYSQL (本篇內容)**
3. 視覺化圖表分析：Power BI
    
## 程式內容──資料清理與處理：MYSQL
前篇已使用Pyhton將爬取到的資料共21,937筆匯入MYSQL「591rent」資料庫中的「591rent_taipei」表格(台北)與「591rent_newtaipei」表格(新北)，接下來使用MYSQL進行資料處理，以產出可分析的欄位並清理異常資料。
    
### 一、確認從Python導入的資料概觀
觀察格式、資料筆數、各欄位資料概觀是否正常。

```sql
USE `591rent`;
DESCRIBE TABLE `591rent_taipei`;
SELECT COUNT(*) FROM `591rent_taipei`;
SELECT * FROM `591rent_taipei` LIMIT 10;
DESCRIBE TABLE `591rent_newtaipei`;
SELECT COUNT(*) FROM `591rent_newtaipei`;
SELECT * FROM `591rent_newtaipei` LIMIT 10;
```
    
### 二、備份原檔
將Python導入的資料備份，避免表格修改錯誤，此步驟可省略。

```sql
CREATE TABLE `591rent_taipei_1220` LIKE `591rent_taipei`;
INSERT INTO `591rent_taipei_1220` SELECT * FROM `591rent_taipei`;
DESCRIBE TABLE `591rent_taipei_1220`;
SELECT COUNT(*) FROM `591rent_taipei_1220`;
CREATE TABLE `591rent_newtaipei_1220` LIKE `591rent_taipei`;
INSERT INTO `591rent_newtaipei_1220` SELECT * FROM `591rent_newtaipei`;
DESCRIBE TABLE `591rent_newtaipei_1220`;
SELECT COUNT(*) FROM `591rent_newtaipei_1220`;
```
    
### 三、將台北與新北資料合併
將台北市表格與新北市表格合併為591rent_all單一表格處理。

```sql
CREATE TABLE `591rent_all` LIKE `591rent_taipei`;
INSERT INTO `591rent_all` SELECT * FROM `591rent_taipei`;
INSERT INTO `591rent_all` SELECT * FROM `591rent_newtaipei`;
DESCRIBE TABLE `591rent_all`;
SELECT COUNT(*) FROM `591rent_all`;
SELECT * FROM `591rent_all` LIMIT 10;
```
    
### 四、資料清理
#### 1. 排除ID重複資料

```sql
SELECT `ID` FROM `591rent_all` GROUP BY `ID` HAVING COUNT(*) > 1;
CREATE TABLE `591rent_all_2` LIKE `591rent_all`;

INSERT INTO `591rent_all_2`(
`ID`,`地區`,`標題`,`地址`,`坪數`,
`房型`,`價格`,`租金含`,`押金`,`樓層`,
`建築種類`,`緯度`,`經度`,`租住說明`,`房屋守則`,
`冰箱`,`洗衣機`,`電視`,`冷氣`,`床`,
`衣櫃`,`網路`,`電梯`,`屋主說`,`網址`
) SELECT DISTINCT 
`ID`,`地區`,`標題`,`地址`,`坪數`,
`房型`,`價格`,`租金含`,`押金`,`樓層`,
`建築種類`,`緯度`,`經度`,`租住說明`,`房屋守則`,
`冰箱`,`洗衣機`,`電視`,`冷氣`,`床`,
`衣櫃`,`網路`,`電梯`,`屋主說`,`網址` 
FROM `591rent_all`;

SELECT `ID` FROM `591rent_all_2` GROUP BY `ID` HAVING COUNT(*) > 1;
DROP TABLE `591rent_all`;
ALTER TABLE `591rent_all_2` RENAME TO `591rent_all`;
SELECT COUNT(*) FROM `591rent_all`;
```

#### 2. 排除除了ID跟網址以外其他欄位都重複的資料

```sql
SELECT * FROM `591rent_all` GROUP BY `地區`,`標題`,`地址`,`坪數`,
`房型`,`價格`,`租金含`,`押金`,`樓層`,
`建築種類`,`緯度`,`經度`,`租住說明`,`房屋守則`,
`冰箱`,`洗衣機`,`電視`,`冷氣`,`床`,
`衣櫃`,`網路`,`電梯`,`屋主說` HAVING COUNT(*) > 1;

CREATE TABLE `591rent_all_3` LIKE `591rent_all`;

INSERT INTO `591rent_all_3` (`ID`,`地區`,`標題`,`地址`,`坪數`,
`房型`,`價格`,`租金含`,`押金`,`樓層`,
`建築種類`,`緯度`,`經度`,`租住說明`,`房屋守則`,
`冰箱`,`洗衣機`,`電視`,`冷氣`,`床`,
`衣櫃`,`網路`,`電梯`,`屋主說`,`網址`)
SELECT `ID`,`地區`,`標題`,`地址`,`坪數`,
`房型`,`價格`,`租金含`,`押金`,`樓層`,
`建築種類`,`緯度`,`經度`,`租住說明`,`房屋守則`,
`冰箱`,`洗衣機`,`電視`,`冷氣`,`床`,
`衣櫃`,`網路`,`電梯`,`屋主說`,`網址`
FROM `591rent_all`
GROUP BY `地區`,`標題`,`地址`,`坪數`,
`房型`,`價格`,`租金含`,`押金`,`樓層`,
`建築種類`,`緯度`,`經度`,`租住說明`,`房屋守則`,
`冰箱`,`洗衣機`,`電視`,`冷氣`,`床`,
`衣櫃`,`網路`,`電梯`,`屋主說`;

SELECT * FROM `591rent_all_3` GROUP BY `地區`,`標題`,`地址`,`坪數`,
`房型`,`價格`,`租金含`,`押金`,`樓層`,
`建築種類`,`緯度`,`經度`,`租住說明`,`房屋守則`,
`冰箱`,`洗衣機`,`電視`,`冷氣`,`床`,
`衣櫃`,`網路`,`電梯`,`屋主說` HAVING COUNT(*) > 1;
DROP TABLE `591rent_all`;

ALTER TABLE `591rent_all_3` RENAME TO `591rent_all`;
SELECT COUNT(*) FROM `591rent_all`;
```

#### 3. 排除異常值
包含：地區不屬於雙北、為車位出租(房型為車位、樓層為0F或平面式/機械式)、非住屋性質(建築種類及標題為店面、商辦、倉庫)

```sql
SET SQL_SAFE_UPDATES=0;
SELECT * FROM `591rent_all` WHERE `地區` <> '台北市' AND `地區` <> '新北市' LIMIT 10;
DELETE FROM `591rent_all` WHERE `地區` <> '台北市' AND `地區` <> '新北市' LIMIT 10;
SELECT * FROM `591rent_all` WHERE `房型` = '車位' LIMIT 10;
DELETE FROM `591rent_all` WHERE `房型` = '車位';
SELECT * FROM `591rent_all` WHERE `樓層` = '0F/0F' LIMIT 10;
DELETE FROM `591rent_all` WHERE `樓層` = '0F/0F';
SELECT * FROM `591rent_all` WHERE `樓層` = '平面式' LIMIT 10;
SELECT * FROM `591rent_all` WHERE `樓層` = '機械式' LIMIT 10;
SELECT * FROM `591rent_all` WHERE `建築種類` = '店面（店鋪）';
DELETE FROM `591rent_all` WHERE `建築種類` = '店面（店鋪）';
SELECT * FROM `591rent_all` WHERE `建築種類` = '辦公商業大樓';
DELETE FROM `591rent_all` WHERE `建築種類` = '辦公商業大樓';
SELECT * FROM `591rent_all` WHERE `建築種類` = '倉庫';
DELETE FROM `591rent_all` WHERE `建築種類` = '倉庫';
SELECT * FROM `591rent_all` WHERE `標題` LIKE '%店面%';
DELETE FROM `591rent_all` WHERE `標題` LIKE '%店面%';
SELECT * FROM `591rent_all` WHERE `標題` LIKE '%倉庫%';
DELETE FROM `591rent_all` WHERE `標題` LIKE '%倉庫%';
SELECT COUNT(*) FROM `591rent_all`;
```
    
### 五、資料處理-新增分析用欄位
#### 1. 押金(區間)
由於原始資料的押金有的是租金月數，有的是金額絕對值，為方便後續分析，將資料轉換成租金月數，並設定為區間。

```sql
ALTER TABLE `591rent_all` ADD `押金(月)` VARCHAR(100);
UPDATE `591rent_all` SET `押金(月)` = REPLACE(`押金`,'元','');
UPDATE `591rent_all` SET `押金(月)` =
(CASE 
	WHEN `押金(月)` NOT REGEXP '[^0-9]' THEN `押金(月)`/`價格`
    ELSE `押金`
END);
SELECT `押金(月)` FROM `591rent_all` GROUP BY `押金(月)`;

ALTER TABLE `591rent_all` ADD `押金(區間)` VARCHAR(100);
UPDATE `591rent_all` SET `押金(區間)`=
(CASE
	WHEN `押金(月)` REGEXP '[^0-9.]' THEN `押金`
    WHEN `押金(月)` > 3 THEN '3個月以上'
    WHEN `押金(月)` <= 3 AND `押金(月)` > 2 THEN '2~3個月(含)'
    WHEN `押金(月)` <= 2 AND `押金(月)` > 1 THEN '1~2個月(含)'
    WHEN `押金(月)` <= 1 AND `押金(月)` > 0 THEN '1個月(含)以下'
    WHEN `押金(月)` <= 0 THEN '無'
END);

UPDATE `591rent_all` SET `押金(區間)` = REPLACE(`押金(區間)`,'二個月','1~2個月(含)');
UPDATE `591rent_all` SET `押金(區間)` = REPLACE(`押金(區間)`,'一個月','1個月(含)以下');
SELECT `押金(區間)` FROM `591rent_all` GROUP BY `押金(區間)`;
```

#### 2. 租屋樓層與總樓層
原始資料以「*F/*F」表達租屋在共幾層樓的第幾樓，為方便分析，將總樓層及租屋所在樓層拆分為兩欄資料，並將「頂樓加蓋」的租屋樓層設定為總樓層+1樓，以及將「整棟」的租屋樓層設定為總樓層。

```sql
ALTER TABLE `591rent_all` ADD `租屋樓層` VARCHAR(100);
UPDATE `591rent_all` SET `租屋樓層` = LEFT(`樓層`,LOCATE('/',`樓層`));
UPDATE `591rent_all` SET `租屋樓層` = REPLACE(`租屋樓層`,'/','');
UPDATE `591rent_all` SET `租屋樓層` = REPLACE(`租屋樓層`,'F','');
UPDATE `591rent_all` SET `租屋樓層` = REPLACE(`租屋樓層`,'4~5','5');
SELECT `租屋樓層` FROM `591rent_all` GROUP BY `租屋樓層`;

ALTER TABLE `591rent_all` ADD `總樓層` VARCHAR(100);
UPDATE `591rent_all` SET `總樓層` = SUBSTRING(`樓層`,LOCATE('/',`樓層`));
UPDATE `591rent_all` SET `總樓層` = REPLACE(`總樓層`,'/','');
UPDATE `591rent_all` SET `總樓層` = REPLACE(`總樓層`,'F','');
SELECT `總樓層` FROM `591rent_all` GROUP BY `總樓層`;
SELECT `總樓層` FROM `591rent_all` WHERE `總樓層` REGEXP '[^0-9]' GROUP BY `總樓層`;

UPDATE `591rent_all` SET `租屋樓層` = REPLACE(`租屋樓層`,'頂層加蓋',`總樓層`+1);
UPDATE `591rent_all` SET `租屋樓層` = REPLACE(`租屋樓層`,'整棟',`總樓層`);
SELECT `租屋樓層` FROM `591rent_all` WHERE `租屋樓層` REGEXP '[^0-9]' GROUP BY `租屋樓層`;
```

#### 3. 從「租住說明」欄位中截取關於最短租期限制的說明並設定為區間以利分析。

```sql
ALTER TABLE `591rent_all` ADD `最短租期` VARCHAR(100);

UPDATE `591rent_all` SET `最短租期` = SUBSTRING(
`租住說明`,LOCATE('最短租期',`租住說明`),
(LOCATE('，',`租住說明`)-LOCATE('最短租期',`租住說明`)));

UPDATE `591rent_all` SET `最短租期` = REPLACE(`最短租期`,'最短租期','');
SELECT `最短租期` FROM `591rent_all` GROUP BY `最短租期`;

UPDATE `591rent_all` SET `最短租期` =
(CASE
	WHEN `最短租期` = '3年' OR `最短租期` = '5年' OR `最短租期` = '99年' THEN '2年以上'
    WHEN `最短租期` = '兩年' OR `最短租期` = '2年' OR `最短租期` = '18月' THEN '1~2年(含)'
    WHEN `最短租期` = '一年' OR `最短租期` = '1年' OR `最短租期` = '10月' OR `最短租期` = '12月' OR `最短租期` = '9月' OR `最短租期` = '10月' OR `最短租期` = '7月' THEN '半年~1年(含)'
    WHEN `最短租期` = '半年' OR `最短租期` = '三個月' OR `最短租期` = '3月' OR `最短租期` = '2月' OR `最短租期` = '4月' OR `最短租期` = '6月' THEN '1個月~半年(含)'
    WHEN `最短租期` = '1月' OR `最短租期` = '30天' OR `最短租期` = '15天' OR `最短租期` = '7天' OR `最短租期` = '20天' THEN '1個月(含)以下'
    ELSE '無'
END);

SELECT `最短租期` FROM `591rent_all` GROUP BY `最短租期`;
```

#### 4. 從「房屋守則」欄位中截取關於性別限制的說明。

```sql
ALTER TABLE `591rent_all` ADD `性別限制` VARCHAR(100);
UPDATE `591rent_all` SET `性別限制` = SUBSTRING(
`房屋守則`,LOCATE('此房屋',`房屋守則`),
(LOCATE('租住',`房屋守則`)-LOCATE('此房屋',`房屋守則`)));
UPDATE `591rent_all` SET `性別限制` = REPLACE(`性別限制`,'此房屋','');
UPDATE `591rent_all` SET `性別限制` = '無說明' WHERE `性別限制`='';
SELECT `性別限制` FROM `591rent_all` GROUP BY `性別限制`;
```
    
### 六、篩選提供租金補助的樣本:租補(含社宅)
#### 1. 先移除「帶看屋、享租屋補助」字樣，此為簽名檔非關鍵字

```sql
UPDATE `591rent_all` SET `屋主說` = REPLACE(`屋主說`,'帶看屋、享租屋補助','');
```

#### 2. 判斷標準
標題或屋主說當中包含關鍵字「租屋補助」、「租金補助」、「租屋補貼」、「租金補貼」或「租補」。

```sql
ALTER TABLE `591rent_all` ADD `租補(含社宅)` VARCHAR(100);
UPDATE `591rent_all` SET `租補(含社宅)` = 
IF(
(`標題` LIKE '%租屋補助%') OR 
(`標題` LIKE '%租金補助%') OR
(`標題` LIKE '%租屋補貼%') OR
(`標題` LIKE '%租金補貼%') OR
(`標題` LIKE '%租補%') OR
(`屋主說` LIKE '%租屋補助%')OR
(`屋主說` LIKE '%租金補助%%')OR
(`屋主說` LIKE '%租屋補貼%')OR
(`屋主說` LIKE '%租金補貼%')OR
(`屋主說` LIKE '%租補%'),
'Y','N') ;
SELECT COUNT(*) FROM `591rent_all` WHERE `租補(含社宅)`='Y';
```

#### 3. 再剔除包含否定意味的樣本

```sql
UPDATE `591rent_all` SET `租補(含社宅)` = 
IF(
(`標題` LIKE '%租屋補貼仲介勿擾%')OR
(`屋主說` LIKE '%不可申請租屋補助%')OR
(`屋主說` LIKE '%[禁止]:非法 吸毒  租補貼%')OR
(`屋主說` LIKE '%禁入籍/租屋補助%')OR
(`標題` LIKE '%不能申請租屋補助%')OR
(`屋主說` LIKE '%不接受入籍及申請租屋補貼%')OR
(`屋主說` LIKE '%無法配合申請租屋補助%')OR
(`屋主說` LIKE '%無提供政府租金補助%')OR
(`屋主說` LIKE '%不申請政府租屋補貼%')OR
(`屋主說` LIKE '%無法辦理租金補貼%')OR
(`屋主說` LIKE '%不可申請租屋補貼%')OR
(`屋主說` LIKE '%不申請租屋補貼%')OR
(`屋主說` LIKE '%禁入籍報稅租補%')OR
(`屋主說` LIKE '%婉拒 租屋補助%')OR
(`屋主說` LIKE '%無法申請租屋補助%')OR
(`屋主說` LIKE '%無租屋補%')OR
(`屋主說` LIKE '%不符政府申請租屋補助%')OR
(`屋主說` LIKE '%［不符合］租屋補助%')OR
(`屋主說` LIKE '%不可租屋補助%'),
"N",`租補(含社宅)`) ;
SELECT COUNT(*) FROM `591rent_all` WHERE `租補(含社宅)`='Y';
SELECT `租補(含社宅)` FROM `591rent_all` GROUP BY `租補(含社宅)`;
```
    
### 七、篩選租補中為社會住宅的樣本:租補(為社宅)
#### 1. 判斷標準：標題或屋主說當中包含關鍵字「社會住宅」、「社宅」。

```sql
ALTER TABLE `591rent_all` ADD `租補(為社宅)` VARCHAR(100);
UPDATE `591rent_all` SET `租補(為社宅)` = 
IF(
(`租補(含社宅)`='Y') AND
((`標題` LIKE '%社會住宅%') OR 
(`標題` LIKE '%社宅%') OR
(`屋主說` LIKE '%社會住宅%')OR
(`屋主說` LIKE '%社宅%')),
'Y','N') ;
SELECT COUNT(*) FROM `591rent_all` WHERE `租補(為社宅)`='Y';
SELECT `租補(含社宅)`,`租補(為社宅)` FROM `591rent_all` GROUP BY `租補(含社宅)`,`租補(為社宅)`;
```

#### 2. 再剔除包含否定意味的樣本

```sql
UPDATE `591rent_all` SET `租補(為社宅)` = 
IF(
(`租補(含社宅)`='Y') AND
((`屋主說` LIKE '%非社會住宅%')OR
(`屋主說` LIKE '%社會住宅專員及房仲勿直接電聯%')OR
(`屋主說` LIKE '%社宅勿擾%')OR
(`屋主說` LIKE '%社宅人員勿擾%')OR
(`屋主說` LIKE '%社宅業者煩請勿擾%')),
"N",`租補(為社宅)`) ;
SELECT COUNT(*) FROM `591rent_all` WHERE `租補(為社宅)`='Y';
SELECT `租補(含社宅)`,`租補(為社宅)` FROM `591rent_all` GROUP BY `租補(含社宅)`,`租補(為社宅)`;
```
    
### 八、篩選租補中非社會住宅的樣本:租補(非社宅)

```sql
ALTER TABLE `591rent_all` ADD `租補(非社宅)` VARCHAR(100);

UPDATE `591rent_all` SET `租補(非社宅)` = 
IF(
(`租補(含社宅)`='Y') AND
(`租補(為社宅)`='N'),
'Y','N') ;

SELECT COUNT(*) FROM `591rent_all` WHERE `租補(非社宅)`='Y';
SELECT `租補(含社宅)`,`租補(為社宅)`,`租補(非社宅)` FROM `591rent_all` GROUP BY `租補(含社宅)`,`租補(為社宅)`,`租補(非社宅)`;
SELECT * FROM `591rent_all` LIMIT 10;
```
    
### 九、匯出csv檔
先將「屋主說」欄位中的;和\r\n取代，避免資料分割錯誤，再用;作為分隔符號、/r/n作為換行符號，匯出成csv檔後以記事本開啟並複製貼到xlsx，進行資料剖析分割即完成。

```sql
UPDATE `591rent_all` SET `屋主說` = REPLACE(`屋主說`,'\r\n',' ');
UPDATE `591rent_all` SET `屋主說` = REPLACE(`屋主說`,'\r',' ');
UPDATE `591rent_all` SET `屋主說` = REPLACE(`屋主說`,';',',');
UPDATE `591rent_all` SET `標題` = REPLACE(`標題`,';',',');
SET SQL_SAFE_UPDATES=1;

SELECT 'ID','地區','標題','地址','坪數',
'房型','價格','租金含','押金','樓層',
'建築種類','緯度','經度','租住說明','房屋守則',
'冰箱','洗衣機','電視','冷氣','床',
'衣櫃','網路','電梯','屋主說','網址',
'押金(月)','押金(區間)','租屋樓層','總樓層','最短租期',
'性別限制','租補(含社宅)','租補(為社宅)','租補(非社宅)'
UNION ALL
SELECT * FROM `591rent_all`
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/591RENT.csv'
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n';
```
    
## 完成xlsx檔如下圖
![匯出EXCEL示意圖-1](https://github.com/dujun101620/591RENT-PART2-Data_Processing/blob/main/%E5%8C%AF%E5%87%BAEXCEL-1.png?raw=true)
    
![匯出EXCEL示意圖-2](https://github.com/dujun101620/591RENT-PART2-Data_Processing/blob/main/%E5%8C%AF%E5%87%BAEXCEL-2.png?raw=true)

    
## 資料數統計如下圖
![資料數統計](https://github.com/dujun101620/591RENT-PART2-Data_Processing/blob/main/%E8%B3%87%E6%96%99%E7%B5%B1%E8%A8%88.png?raw=true)
    

