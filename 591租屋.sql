
USE `591rent`;

# 確認從Python導入的資料概觀
DESCRIBE TABLE `591rent_taipei`;
SELECT COUNT(*) FROM `591rent_taipei`;
SELECT * FROM `591rent_taipei` LIMIT 10;
DESCRIBE TABLE `591rent_newtaipei`;
SELECT COUNT(*) FROM `591rent_newtaipei`;
SELECT * FROM `591rent_newtaipei` LIMIT 10;

#備份原檔
CREATE TABLE `591rent_taipei_1220` LIKE `591rent_taipei`;
INSERT INTO `591rent_taipei_1220` SELECT * FROM `591rent_taipei`;
DESCRIBE TABLE `591rent_taipei_1220`;
SELECT COUNT(*) FROM `591rent_taipei_1220`;
CREATE TABLE `591rent_newtaipei_1220` LIKE `591rent_taipei`;
INSERT INTO `591rent_newtaipei_1220` SELECT * FROM `591rent_newtaipei`;
DESCRIBE TABLE `591rent_newtaipei_1220`;
SELECT COUNT(*) FROM `591rent_newtaipei_1220`;

# 將台北與新北資料合併
CREATE TABLE `591rent_all` LIKE `591rent_taipei`;
INSERT INTO `591rent_all` SELECT * FROM `591rent_taipei`;
INSERT INTO `591rent_all` SELECT * FROM `591rent_newtaipei`;
DESCRIBE TABLE `591rent_all`;
SELECT COUNT(*) FROM `591rent_all`;
SELECT * FROM `591rent_all` LIMIT 10;

#資料清理-排除ID重複資料
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

#資料清理-排除除了ID跟網址以外其他欄位都重複的資料
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

#資料清理-排除異常值
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

#資料處理-新增分析用欄位
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

ALTER TABLE `591rent_all` ADD `性別限制` VARCHAR(100);
UPDATE `591rent_all` SET `性別限制` = SUBSTRING(
`房屋守則`,LOCATE('此房屋',`房屋守則`),
(LOCATE('租住',`房屋守則`)-LOCATE('此房屋',`房屋守則`)));
UPDATE `591rent_all` SET `性別限制` = REPLACE(`性別限制`,'此房屋','');
UPDATE `591rent_all` SET `性別限制` = '無說明' WHERE `性別限制`='';
SELECT `性別限制` FROM `591rent_all` GROUP BY `性別限制`;


# 篩選提供租金補助的樣本:租補(含社宅)
# 判斷標準：標題或屋主說當中包含關鍵字「租屋補助」、「租金補助」、「租屋補貼」、「租金補貼」或「租補」。

# 先移除「帶看屋、享租屋補助」字樣，此為簽名檔非關鍵字
UPDATE `591rent_all` SET `屋主說` = REPLACE(`屋主說`,'帶看屋、享租屋補助','');

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

# 再剔除包含否定意味的樣本
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

# 篩選租補中為社會住宅的樣本:租補(為社宅)
# 判斷標準：標題或屋主說當中包含關鍵字「社會住宅」、「社宅」。
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

# 再剔除包含否定意味的樣本
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


# 篩選租補中非社會住宅的樣本:租補(非社宅)
ALTER TABLE `591rent_all` ADD `租補(非社宅)` VARCHAR(100);
UPDATE `591rent_all` SET `租補(非社宅)` = 
IF(
(`租補(含社宅)`='Y') AND
(`租補(為社宅)`='N'),
'Y','N') ;
SELECT COUNT(*) FROM `591rent_all` WHERE `租補(非社宅)`='Y';
SELECT `租補(含社宅)`,`租補(為社宅)`,`租補(非社宅)` FROM `591rent_all` GROUP BY `租補(含社宅)`,`租補(為社宅)`,`租補(非社宅)`;

SELECT * FROM `591rent_all` LIMIT 10;


#匯出csv檔
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