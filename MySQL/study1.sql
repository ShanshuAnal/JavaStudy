SELECT * FROM users WHERE NAME = 'ls'

INSERT INTO users VALUE(3, 'ls', 'suzhou')

# 创建数据库
CREATE DATABASE db02


# 删除数据库
DROP DATABASE db02

# 创建一个使用utf8字符集的数据库
CREATE DATABASE db02 CHARACTER SET utf8

# 创建一个使用utf8字符集，并使用校对规则的数据库
CREATE DATABASE db03 
	CHARACTER SET utf8 
	COLLATE utf8_bin
	
	
# 校对规则
# utf8_bin 区分大小写  utf8_general_ci(默认)区分大小写
# t1表没有设置自己的字符集和校对规则，那么就是和数据库一样的，大小写区分
SELECT * FROM t1 WHERE NAME = 'tom'



# 查看当前数据库服务器中的所有数据库
SHOW DATABASES

# 查看前面创建的db02数据库的定义信息
SHOW CREATE DATABASE db02

# 在创建/删除数据库、表的时候，为了规避关键字，可以使用反引号
CREATE DATABASE `create`

# 备份数据库（在DOS命令行中）
# 其实也就是讲该数据库的所有sql语句输出出来，一个sql脚本   
mysqldump -u root -p zhang914 -B db01 > d:\\bsk.sql












