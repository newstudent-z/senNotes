-- sen笔记 数据库初始化脚本
CREATE DATABASE IF NOT EXISTS kamanote_tech DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE kamanote_tech;

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
    `user_id`       BIGINT       NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `account`       VARCHAR(50)  NOT NULL COMMENT '账号',
    `username`      VARCHAR(50)  NOT NULL COMMENT '用户名',
    `password`      VARCHAR(255) NOT NULL COMMENT '加密密码',
    `gender`        TINYINT      DEFAULT 3 COMMENT '性别: 1-男, 2-女, 3-保密',
    `birthday`      DATE         DEFAULT NULL COMMENT '生日',
    `avatar_url`    VARCHAR(255) DEFAULT NULL COMMENT '头像地址',
    `email`         VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    `school`        VARCHAR(100) DEFAULT NULL COMMENT '学校',
    `signature`     VARCHAR(255) DEFAULT NULL COMMENT '签名',
    `is_banned`     TINYINT      DEFAULT 0 COMMENT '封禁: 0-否, 1-是',
    `is_admin`      TINYINT      DEFAULT 0 COMMENT '管理员: 0-否, 1-是',
    `last_login_at` DATETIME     DEFAULT NULL COMMENT '最后登录时间',
    `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`user_id`),
    UNIQUE KEY `uk_account` (`account`),
    KEY `idx_search` (`username`, `account`, `email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 分类表
CREATE TABLE IF NOT EXISTS `category` (
    `category_id`       INT      NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    `name`              VARCHAR(100) NOT NULL COMMENT '分类名称',
    `parent_category_id` INT     DEFAULT 0 COMMENT '上级分类ID',
    `created_at`        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='分类表';

-- 问题表
CREATE TABLE IF NOT EXISTS `question` (
    `question_id` INT          NOT NULL AUTO_INCREMENT COMMENT '问题ID',
    `category_id` INT          NOT NULL COMMENT '分类ID',
    `title`       VARCHAR(255) NOT NULL COMMENT '标题',
    `difficulty`  TINYINT      DEFAULT 1 COMMENT '难度: 1-简单, 2-中等, 3-困难',
    `exam_point`  TEXT         DEFAULT NULL COMMENT '考点',
    `view_count`  INT          DEFAULT 0 COMMENT '浏览量',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`question_id`),
    KEY `idx_category_id` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='问题表';

-- 笔记表
CREATE TABLE IF NOT EXISTS `note` (
    `note_id`       INT      NOT NULL AUTO_INCREMENT COMMENT '笔记ID',
    `author_id`     BIGINT   NOT NULL COMMENT '作者ID',
    `question_id`   INT      DEFAULT NULL COMMENT '问题ID',
    `content`       TEXT     NOT NULL COMMENT '笔记内容',
    `like_count`    INT      DEFAULT 0 COMMENT '点赞数',
    `comment_count` INT      DEFAULT 0 COMMENT '评论数',
    `collect_count` INT      DEFAULT 0 COMMENT '收藏数',
    `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`note_id`),
    KEY `idx_author_id` (`author_id`),
    KEY `idx_question_id` (`question_id`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='笔记表';

-- 笔记搜索向量（支持全文检索）
ALTER TABLE note ADD COLUMN IF NOT EXISTS search_vector TEXT GENERATED ALWAYS AS (CONCAT_WS(' ', content)) STORED;
ALTER TABLE note ADD FULLTEXT INDEX IF NOT EXISTS idx_note_search(search_vector);

-- 收藏夹表
CREATE TABLE IF NOT EXISTS `collection` (
    `collection_id` INT          NOT NULL AUTO_INCREMENT COMMENT '收藏夹ID',
    `name`          VARCHAR(100) NOT NULL COMMENT '收藏夹名称',
    `description`   TEXT         DEFAULT NULL COMMENT '描述',
    `creator_id`    BIGINT       NOT NULL COMMENT '创建者ID',
    `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`collection_id`),
    KEY `idx_creator_id` (`creator_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏夹表';

-- 收藏夹-笔记关联表
CREATE TABLE IF NOT EXISTS `collection_note` (
    `collection_id` INT      NOT NULL COMMENT '收藏夹ID',
    `note_id`       INT      NOT NULL COMMENT '笔记ID',
    `created_at`    DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`collection_id`, `note_id`),
    KEY `idx_note_id` (`note_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏夹笔记关联表';

-- 笔记点赞表
CREATE TABLE IF NOT EXISTS `note_like` (
    `note_id`    INT      NOT NULL COMMENT '笔记ID',
    `user_id`    BIGINT   NOT NULL COMMENT '用户ID',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`note_id`, `user_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='笔记点赞表';

-- 笔记收藏表
CREATE TABLE IF NOT EXISTS `note_collect` (
    `collect_id` INT      NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
    `note_id`    INT      NOT NULL COMMENT '笔记ID',
    `user_id`    BIGINT   NOT NULL COMMENT '用户ID',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`collect_id`),
    UNIQUE KEY `uk_note_user` (`note_id`, `user_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='笔记收藏表';

-- 评论表
CREATE TABLE IF NOT EXISTS `comment` (
    `comment_id`  INT          NOT NULL AUTO_INCREMENT COMMENT '评论ID',
    `note_id`     INT UNSIGNED NOT NULL COMMENT '笔记ID',
    `author_id`   BIGINT UNSIGNED NOT NULL COMMENT '作者ID',
    `parent_id`   INT          DEFAULT NULL COMMENT '父评论ID',
    `content`     TEXT         NOT NULL COMMENT '评论内容',
    `like_count`  INT          NOT NULL DEFAULT 0 COMMENT '点赞数',
    `reply_count` INT          NOT NULL DEFAULT 0 COMMENT '回复数',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`comment_id`),
    KEY `idx_note_id` (`note_id`),
    KEY `idx_author_id` (`author_id`),
    KEY `idx_parent_id` (`parent_id`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- 评论点赞表
CREATE TABLE IF NOT EXISTS `comment_like` (
    `comment_like_id` INT      NOT NULL AUTO_INCREMENT COMMENT '评论点赞ID',
    `comment_id`      INT      NOT NULL COMMENT '评论ID',
    `user_id`         BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
    `created_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`comment_like_id`),
    UNIQUE KEY `uk_comment_user` (`comment_id`, `user_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论点赞表';

-- 消息表
CREATE TABLE IF NOT EXISTS `message` (
    `message_id`  INT          NOT NULL AUTO_INCREMENT COMMENT '消息ID',
    `receiver_id` BIGINT UNSIGNED NOT NULL COMMENT '接收者ID',
    `sender_id`   BIGINT UNSIGNED NOT NULL COMMENT '发送者ID',
    `type`        VARCHAR(20)  NOT NULL COMMENT '消息类型',
    `target_id`   INT          NOT NULL COMMENT '目标ID',
    `target_type` INT          DEFAULT NULL COMMENT '目标类型',
    `content`     TEXT         NOT NULL COMMENT '消息内容',
    `is_read`     TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '是否已读: 0-未读, 1-已读',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`message_id`),
    KEY `idx_receiver_id` (`receiver_id`),
    KEY `idx_sender_id` (`sender_id`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息表';

-- 题单表
CREATE TABLE IF NOT EXISTS `question_list` (
    `question_list_id` INT          NOT NULL AUTO_INCREMENT COMMENT '题单ID',
    `name`             VARCHAR(100) NOT NULL COMMENT '题单名称',
    `type`             TINYINT      DEFAULT 1 COMMENT '题单类型',
    `description`      TEXT         DEFAULT NULL COMMENT '描述',
    PRIMARY KEY (`question_list_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题单表';

-- 题单项表
CREATE TABLE IF NOT EXISTS `question_list_item` (
    `question_list_id` INT      NOT NULL COMMENT '题单ID',
    `question_id`      INT      NOT NULL COMMENT '题目ID',
    `rank`             INT      NOT NULL COMMENT '排序',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`question_list_id`, `question_id`),
    KEY `idx_question_id` (`question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题单项表';

-- 标签表
CREATE TABLE IF NOT EXISTS `tag` (
    `id`         INT          NOT NULL AUTO_INCREMENT COMMENT '标签ID',
    `name`       VARCHAR(50)  NOT NULL COMMENT '标签名称',
    `user_id`    BIGINT UNSIGNED DEFAULT NULL COMMENT '用户ID',
    `created_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_name` (`name`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签表';

-- 笔记标签关联表
CREATE TABLE IF NOT EXISTS `note_tag` (
    `id`         INT       NOT NULL AUTO_INCREMENT COMMENT '关联ID',
    `note_id`    INT       NOT NULL COMMENT '笔记ID',
    `tag_id`     INT       NOT NULL COMMENT '标签ID',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_note_tag` (`note_id`, `tag_id`),
    KEY `idx_tag_id` (`tag_id`),
    KEY `idx_note_id` (`note_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='笔记标签关联表';

-- 统计表
CREATE TABLE IF NOT EXISTS `statistic` (
    `id`                   INT  NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `login_count`          INT  DEFAULT 0 COMMENT '登录次数',
    `register_count`       INT  DEFAULT 0 COMMENT '注册人数',
    `total_register_count` INT  DEFAULT 0 COMMENT '累计注册人数',
    `note_count`           INT  DEFAULT 0 COMMENT '笔记数量',
    `submit_note_count`    INT  DEFAULT 0 COMMENT '提交笔记数',
    `total_note_count`     INT  DEFAULT 0 COMMENT '累计笔记数',
    `date`                 DATE NOT NULL COMMENT '统计日期',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='统计表';