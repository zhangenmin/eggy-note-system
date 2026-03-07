-- 笔记系统核心表结构 (MySQL)

CREATE DATABASE IF NOT EXISTS eggy_note DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE eggy_note;

-- 1. 笔记本表
CREATE TABLE IF NOT EXISTS `note_book` (
    `book_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '笔记本ID',
    `name` VARCHAR(255) NOT NULL COMMENT '名称',
    `user_id` BIGINT NOT NULL COMMENT '所属用户ID',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`book_id`)
) ENGINE=InnoDB COMMENT='笔记本表';

-- 2. 笔记主表
CREATE TABLE IF NOT EXISTS `note` (
    `note_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '笔记ID',
    `book_id` BIGINT NOT NULL COMMENT '所属笔记本ID',
    `title` VARCHAR(255) DEFAULT '未命名笔记' COMMENT '标题',
    `type` ENUM('cornell', 'block') DEFAULT 'block' COMMENT '显示模式',
    `summary` TEXT COMMENT '康奈尔总结',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`note_id`),
    CONSTRAINT `fk_note_book` FOREIGN KEY (`book_id`) REFERENCES `note_book` (`book_id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='笔记主表';

-- 3. 笔记块表 (核心)
CREATE TABLE IF NOT EXISTS `note_block` (
    `block_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '块ID',
    `note_id` BIGINT NOT NULL COMMENT '所属笔记ID',
    `parent_block_id` BIGINT DEFAULT NULL COMMENT '父块ID (用于嵌套)',
    `type` ENUM('text', 'image', 'equation', 'heading-1', 'heading-2', 'todo') DEFAULT 'text' COMMENT '块类型',
    `content` TEXT COMMENT '内容',
    `order_num` INT DEFAULT 0 COMMENT '排序',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`block_id`),
    CONSTRAINT `fk_note_block` FOREIGN KEY (`note_id`) REFERENCES `note` (`note_id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='笔记块表';

-- 4. 引用/链接表 (双向链接)
CREATE TABLE IF NOT EXISTS `note_link` (
    `link_id` BIGINT NOT NULL AUTO_INCREMENT,
    `from_block_id` BIGINT NOT NULL COMMENT '来源块',
    `to_note_id` BIGINT NOT NULL COMMENT '指向笔记',
    PRIMARY KEY (`link_id`),
    CONSTRAINT `fk_link_from` FOREIGN KEY (`from_block_id`) REFERENCES `note_block` (`block_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_link_to` FOREIGN KEY (`to_note_id`) REFERENCES `note` (`note_id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='引用关系表';

-- 5. 标签及关联表
CREATE TABLE IF NOT EXISTS `note_tag` (
    `tag_id` BIGINT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) UNIQUE NOT NULL,
    PRIMARY KEY (`tag_id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `note_tag_rel` (
    `note_id` BIGINT NOT NULL,
    `tag_id` BIGINT NOT NULL,
    PRIMARY KEY (`note_id`, `tag_id`),
    FOREIGN KEY (`note_id`) REFERENCES `note` (`note_id`) ON DELETE CASCADE,
    FOREIGN KEY (`tag_id`) REFERENCES `note_tag` (`tag_id`) ON DELETE CASCADE
) ENGINE=InnoDB;
