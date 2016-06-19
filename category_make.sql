#idを振る
CREATE TABLE id_noun(id int(10) AUTO_INCREMENT NOT NULL, PRIMARY KEY(id)) SELECT * FROM noun
#固有名詞のみのリストを作成
CREATE TABLE proper_noun (SELECT idn.id, idn.noun_name, idn.cate1, idn.cate2, idn.cate3, idn.cate4 FROM id_noun as idn WHERE idn.type1 = "名詞" AND idn.type2 = "固有名詞")

#カテゴリ名,記事名のみにする
CREATE TABLE wiki_links (SELECT c.cl_to as category, SUBSTRING_INDEX(c.cl_sortkey, '\n', -1) as article FROM categorylinks as c);

DELETE FROM wiki_links WHERE article LIKE '%(曖昧さ回避)%';
DELETE FROM wiki_links WHERE category LIKE '%記事%' OR category LIKE 'User%';
DELETE FROM wiki_links WHERE category='存命人物' OR category LIKE '%ウィキ%' OR category LIKE '%ページ' OR category LIKE '%項目';
DELETE FROM wiki_links WHERE category=article OR category LIKE "%曖昧さ回避%";
DELETE FROM wiki_links WHERE category LIKE "%年没" OR category LIKE "%年生" OR category LIKE "%スタブ" OR category LIKE "%ページ%";
DELETE FROM wiki_links WHERE category LIKE "%一覧%" OR category LIKE "%項目%";
DELETE FROM wiki_links WHERE article LIKE "%JPG" OR category LIKE "%ファイル" OR article LIKE "%PNG";
DELETE FROM wiki_links WHERE category="共有IPアドレス";
DELETE FROM wiki_links WHERE article LIKE "%一覧%";
DELETE FROM wiki_links WHERE category LIKE "%出典";
DELETE FROM wiki_links WHERE article LIKE "井戸端%";
DELETE FROM wiki_links WHERE category LIKE "%代没" OR category LIKE "%代生" OR category LIKE "%ユーザー" OR category LIKE "%年代" OR category LIKE "%年" OR category LIKE "%世紀生" OR category LIKE "%世紀没";
DELETE FROM wiki_links WHERE category LIKE "%年紀" OR category LIKE "%の各国";
DELETE FROM wiki_links WHERE category LIKE "テンプレート文書";
DELETE FROM wiki_links WHERE article LIKE "%下書き%" OR article LIKE "%翻訳途中%";

#"漫画名_あ"などの"_あ"を削除
CREATE TABLE wiki_links2 (SELECT * FROM wiki_links as w WHERE w.category NOT LIKE "%\__");
INSERT INTO wiki_links2 (category, article, article_pron) SELECT SUBSTRING_INDEX(w.category, '_', 1), w.article, w.article_pron FROM wiki_links as w WHERE w.category LIKE "%\__";
#A_(B)の分解
CREATE TABLE wiki_links3 (SELECT * FROM wiki_links2 as w WHERE w.category NOT LIKE "%\_(%");
INSERT INTO wiki_links3 (category, article, article_pron) SELECT SUBSTRING_INDEX(w.category, '_(', 1), w.article, w.article_pron FROM wiki_links2 as w WHERE w.category LIKE "%\_(%";
INSERT INTO wiki_links3 (category, article, article_pron) SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(w.category, '_(', -1), ')', 1), w.article, w.article_pron FROM wiki_links2 as w WHERE w.category LIKE "%\_(%";
#AのBのCの....の分解
#不思議の国のアリスとか道の駅とかたつの市とかが切れてしまう
CREATE TABLE wiki_links4 (SELECT REPLACE(w.category, "その他", "sonota") as category, w.article FROM wiki_links3 as w);
CREATE TABLE wiki_links5 (SELECT * FROM wiki_links4 as w WHERE w.category NOT LIKE "_%の_%の_%の_%");
INSERT INTO wiki_links5 (category, article) SELECT SUBSTRING_INDEX(w.category, 'の', 1), w.article FROM wiki_links4 as w WHERE w.category LIKE "_%の_%の_%の_%";
INSERT INTO wiki_links5 (category, article) SELECT SUBSTRING_INDEX(w.category, 'の', -3), w.article FROM wiki_links4 as w WHERE w.category LIKE "_%の_%の_%の_%";
CREATE TABLE wiki_links6 (SELECT * FROM wiki_links5 as w WHERE w.category NOT LIKE "_%の_%の_%");
INSERT INTO wiki_links6 (category, article) SELECT SUBSTRING_INDEX(w.category, 'の', 1), w.article FROM wiki_links5 as w WHERE w.category LIKE "_%の_%の_%";
INSERT INTO wiki_links6 (category, article) SELECT SUBSTRING_INDEX(w.category, 'の', -2), w.article FROM wiki_links5 as w WHERE w.category LIKE "_%の_%の_%";
CREATE TABLE wiki_links7 (SELECT * FROM wiki_links6 as w WHERE w.category NOT LIKE "_%の_%");
INSERT INTO wiki_links7 (category, article) SELECT SUBSTRING_INDEX(w.category, 'の', 1), w.article FROM wiki_links6 as w WHERE w.category LIKE "_%の_%";
INSERT INTO wiki_links7 (category, article) SELECT SUBSTRING_INDEX(w.category, 'の', -1), w.article FROM wiki_links6 as w WHERE w.category LIKE "_%の_%";
DELETE FROM wiki_links7 WHERE category="人物";
DELETE FROM wiki_links7 WHERE category="各国";
DELETE FROM wiki_links7 WHERE category LIKE "%年没" OR category LIKE "%年生" OR category LIKE "%年";
CREATE TABLE split_wlinks (SELECT REPLACE(w.category, "sonota", "その他") as category, w.article FROM wiki_links7 as w);
DELETE FROM split_wlinks WHERE category LIKE "%,%";
DELETE FROM split_wlinks WHERE category LIKE "出典%";
DELETE FROM split_wlinks WHERE category LIKE "記述";
DELETE FROM split_wlinks WHERE category="";
DELETE FROM split_wlinks WHERE category IN ("各国テンプレート","画像提供依頼","同名","参照方法","画像","GFDL画像","カテゴリ","自作画像","生年未記載","存命人物","クリエイティブ・コモンズ_表示_-_継承_3.0","かつて存在した日本","共有IPアドレス","各アーティスト","生没年不詳","ジャンル","隠しカテゴリ","Least_concern","生年不明","不適切として投稿ブロックを受けたユーザー名","コモンズと重複しているメディア","継続中","かつて存在した中国","没年不明","未使用");
ALTER TABLE `split_wlinks` ADD INDEX(`article`);

#join
CREATE TABLE proper_cate (
    SELECT pn.id, split_wlinks.category
    FROM proper_noun as pn JOIN split_wlinks ON pn.noun_name=split_wlinks.article
    WHERE pn.cate2 != "姓" OR pn.cate2 != "名"
);
ALTER TABLE `proper_cate` ADD INDEX( `id`, `category`);
#重複削除
CREATE TABLE distinct_pc (SELECT DISTINCT * FROM proper_cate);
#3655532のペアができる



#cate2,cate3,cate4の設定
SET @NUM := 0;
CREATE TABLE distinct_pc2 (SELECT (@NUM := @NUM+1) as num, t1.* FROM distinct_pc as t1 ORDER BY id);
ALTER TABLE `distinct_pc2` ADD INDEX(`id`);
ALTER TABLE `distinct_pc2` ADD UNIQUE(`num`);
CREATE TABLE mintemp(SELECT t1.id as id, t1.num as minNUM FROM distinct_pc2 as t1 WHERE t1.num = (SELECT MIN(t2.num) FROM distinct_pc2 as t2 WHERE t1.id = t2.id));
CREATE TABLE create_noun(
    SELECT idn.id, IFNULL(t1.category, "*") as cate2, IFNULL(t2.category, "*") as cate3, IFNULL(t3.category, "*") as cate4 FROM id_noun as idn
    JOIN mintemp as m ON m.id = idn.id
    LEFT OUTER JOIN distinct_pc2 as t1 ON t1.id = idn.id AND t1.num = m.minNUM
    LEFT OUTER JOIN distinct_pc2 as t2 ON t2.id = idn.id AND t2.num = m.minNUM+1
    LEFT OUTER JOIN distinct_pc2 as t3 ON t3.id = idn.id AND t3.num = m.minNUM+2
    );


#結果をjoin
CREATE TABLE create_noun2 (
    SELECT idn.noun_name, idn.kazu1, idn.kazu2, idn.kazu3, idn.type1, idn.type2, idn.cate1, cn.cate2, cn.cate3, cn.cate4, idn.yomi1, idn.yomi2, idn.yomi3 FROM id_noun as idn
    JOIN create_noun as cn ON cn.id = idn.id
);
INSERT INTO create_noun2 (noun_name, kazu1, kazu2, kazu3, type1, type2, cate1, cate2, cate3, cate4, yomi1, yomi2, yomi3)
    SELECT idn.noun_name, idn.kazu1, idn.kazu2, idn.kazu3, idn.type1, idn.type2, idn.cate1, idn.cate2, idn.cate3, idn.cate4, idn.yomi1, idn.yomi2, idn.yomi3 FROM id_noun as idn
	LEFT JOIN create_noun as cn ON cn.id = idn.id
    WHERE cn.id IS NULL;
#725084個の語彙に追加の意味を増やした

