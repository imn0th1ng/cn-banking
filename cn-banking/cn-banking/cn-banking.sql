CREATE TABLE `account_recent` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(40) NOT NULL COLLATE 'utf8mb4_general_ci',
	`sender` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`target` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`label` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
	`amount` INT(11) NOT NULL,
	`iden` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
	`type` VARCHAR(50) NOT NULL DEFAULT 'income' COLLATE 'utf8mb4_general_ci',
	`date` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `İndeks 2` (`id`) USING BTREE,
	INDEX `İndeks 3` (`identifier`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=93
;


ALTER TABLE `users` ADD COLUMN `bankid` LONGTEXT NULL;