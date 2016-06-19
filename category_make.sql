#id��U��
CREATE TABLE id_noun(id int(10) AUTO_INCREMENT NOT NULL, PRIMARY KEY(id)) SELECT * FROM noun
#�ŗL�����݂̂̃��X�g���쐬
CREATE TABLE proper_noun (SELECT idn.id, idn.noun_name, idn.cate1, idn.cate2, idn.cate3, idn.cate4 FROM id_noun as idn WHERE idn.type1 = "����" AND idn.type2 = "�ŗL����")

#�J�e�S����,�L�����݂̂ɂ���
CREATE TABLE wiki_links (SELECT c.cl_to as category, SUBSTRING_INDEX(c.cl_sortkey, '\n', -1) as article FROM categorylinks as c);

DELETE FROM wiki_links WHERE article LIKE '%(�B�������)%';
DELETE FROM wiki_links WHERE category LIKE '%�L��%' OR category LIKE 'User%';
DELETE FROM wiki_links WHERE category='�����l��' OR category LIKE '%�E�B�L%' OR category LIKE '%�y�[�W' OR category LIKE '%����';
DELETE FROM wiki_links WHERE category=article OR category LIKE "%�B�������%";
DELETE FROM wiki_links WHERE category LIKE "%�N�v" OR category LIKE "%�N��" OR category LIKE "%�X�^�u" OR category LIKE "%�y�[�W%";
DELETE FROM wiki_links WHERE category LIKE "%�ꗗ%" OR category LIKE "%����%";
DELETE FROM wiki_links WHERE article LIKE "%JPG" OR category LIKE "%�t�@�C��" OR article LIKE "%PNG";
DELETE FROM wiki_links WHERE category="���LIP�A�h���X";
DELETE FROM wiki_links WHERE article LIKE "%�ꗗ%";
DELETE FROM wiki_links WHERE category LIKE "%�o�T";
DELETE FROM wiki_links WHERE article LIKE "��˒[%";
DELETE FROM wiki_links WHERE category LIKE "%��v" OR category LIKE "%�㐶" OR category LIKE "%���[�U�[" OR category LIKE "%�N��" OR category LIKE "%�N" OR category LIKE "%���I��" OR category LIKE "%���I�v";
DELETE FROM wiki_links WHERE category LIKE "%�N�I" OR category LIKE "%�̊e��";
DELETE FROM wiki_links WHERE category LIKE "�e���v���[�g����";
DELETE FROM wiki_links WHERE article LIKE "%������%" OR article LIKE "%�|��r��%";

#"���於_��"�Ȃǂ�"_��"���폜
CREATE TABLE wiki_links2 (SELECT * FROM wiki_links as w WHERE w.category NOT LIKE "%\__");
INSERT INTO wiki_links2 (category, article, article_pron) SELECT SUBSTRING_INDEX(w.category, '_', 1), w.article, w.article_pron FROM wiki_links as w WHERE w.category LIKE "%\__";
#A_(B)�̕���
CREATE TABLE wiki_links3 (SELECT * FROM wiki_links2 as w WHERE w.category NOT LIKE "%\_(%");
INSERT INTO wiki_links3 (category, article, article_pron) SELECT SUBSTRING_INDEX(w.category, '_(', 1), w.article, w.article_pron FROM wiki_links2 as w WHERE w.category LIKE "%\_(%";
INSERT INTO wiki_links3 (category, article, article_pron) SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(w.category, '_(', -1), ')', 1), w.article, w.article_pron FROM wiki_links2 as w WHERE w.category LIKE "%\_(%";
#A��B��C��....�̕���
#�s�v�c�̍��̃A���X�Ƃ����̉w�Ƃ����̎s�Ƃ����؂�Ă��܂�
CREATE TABLE wiki_links4 (SELECT REPLACE(w.category, "���̑�", "sonota") as category, w.article FROM wiki_links3 as w);
CREATE TABLE wiki_links5 (SELECT * FROM wiki_links4 as w WHERE w.category NOT LIKE "_%��_%��_%��_%");
INSERT INTO wiki_links5 (category, article) SELECT SUBSTRING_INDEX(w.category, '��', 1), w.article FROM wiki_links4 as w WHERE w.category LIKE "_%��_%��_%��_%";
INSERT INTO wiki_links5 (category, article) SELECT SUBSTRING_INDEX(w.category, '��', -3), w.article FROM wiki_links4 as w WHERE w.category LIKE "_%��_%��_%��_%";
CREATE TABLE wiki_links6 (SELECT * FROM wiki_links5 as w WHERE w.category NOT LIKE "_%��_%��_%");
INSERT INTO wiki_links6 (category, article) SELECT SUBSTRING_INDEX(w.category, '��', 1), w.article FROM wiki_links5 as w WHERE w.category LIKE "_%��_%��_%";
INSERT INTO wiki_links6 (category, article) SELECT SUBSTRING_INDEX(w.category, '��', -2), w.article FROM wiki_links5 as w WHERE w.category LIKE "_%��_%��_%";
CREATE TABLE wiki_links7 (SELECT * FROM wiki_links6 as w WHERE w.category NOT LIKE "_%��_%");
INSERT INTO wiki_links7 (category, article) SELECT SUBSTRING_INDEX(w.category, '��', 1), w.article FROM wiki_links6 as w WHERE w.category LIKE "_%��_%";
INSERT INTO wiki_links7 (category, article) SELECT SUBSTRING_INDEX(w.category, '��', -1), w.article FROM wiki_links6 as w WHERE w.category LIKE "_%��_%";
DELETE FROM wiki_links7 WHERE category="�l��";
DELETE FROM wiki_links7 WHERE category="�e��";
DELETE FROM wiki_links7 WHERE category LIKE "%�N�v" OR category LIKE "%�N��" OR category LIKE "%�N";
CREATE TABLE split_wlinks (SELECT REPLACE(w.category, "sonota", "���̑�") as category, w.article FROM wiki_links7 as w);
DELETE FROM split_wlinks WHERE category LIKE "%,%";
DELETE FROM split_wlinks WHERE category LIKE "�o�T%";
DELETE FROM split_wlinks WHERE category LIKE "�L�q";
DELETE FROM split_wlinks WHERE category="";
DELETE FROM split_wlinks WHERE category IN ("�e���e���v���[�g","�摜�񋟈˗�","����","�Q�ƕ��@","�摜","GFDL�摜","�J�e�S��","����摜","���N���L��","�����l��","�N���G�C�e�B�u�E�R�����Y_�\��_-_�p��_3.0","���đ��݂������{","���LIP�A�h���X","�e�A�[�e�B�X�g","���v�N�s��","�W������","�B���J�e�S��","Least_concern","���N�s��","�s�K�؂Ƃ��ē��e�u���b�N���󂯂����[�U�[��","�R�����Y�Əd�����Ă��郁�f�B�A","�p����","���đ��݂�������","�v�N�s��","���g�p");
ALTER TABLE `split_wlinks` ADD INDEX(`article`);

#join
CREATE TABLE proper_cate (
    SELECT pn.id, split_wlinks.category
    FROM proper_noun as pn JOIN split_wlinks ON pn.noun_name=split_wlinks.article
    WHERE pn.cate2 != "��" OR pn.cate2 != "��"
);
ALTER TABLE `proper_cate` ADD INDEX( `id`, `category`);
#�d���폜
CREATE TABLE distinct_pc (SELECT DISTINCT * FROM proper_cate);
#3655532�̃y�A���ł���



#cate2,cate3,cate4�̐ݒ�
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


#���ʂ�join
CREATE TABLE create_noun2 (
    SELECT idn.noun_name, idn.kazu1, idn.kazu2, idn.kazu3, idn.type1, idn.type2, idn.cate1, cn.cate2, cn.cate3, cn.cate4, idn.yomi1, idn.yomi2, idn.yomi3 FROM id_noun as idn
    JOIN create_noun as cn ON cn.id = idn.id
);
INSERT INTO create_noun2 (noun_name, kazu1, kazu2, kazu3, type1, type2, cate1, cate2, cate3, cate4, yomi1, yomi2, yomi3)
    SELECT idn.noun_name, idn.kazu1, idn.kazu2, idn.kazu3, idn.type1, idn.type2, idn.cate1, idn.cate2, idn.cate3, idn.cate4, idn.yomi1, idn.yomi2, idn.yomi3 FROM id_noun as idn
	LEFT JOIN create_noun as cn ON cn.id = idn.id
    WHERE cn.id IS NULL;
#725084�̌�b�ɒǉ��̈Ӗ��𑝂₵��

