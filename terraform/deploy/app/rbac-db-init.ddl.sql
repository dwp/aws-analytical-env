CREATE TABLE IF NOT EXISTS `User` (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR (256) NOT NULL,
    accountname VARCHAR(256),
    active TINYINT(1) DEFAULT TRUE NOT NULL,
    UNIQUE INDEX(username)
);

CREATE TABLE IF NOT EXISTS `Group` (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    groupname VARCHAR(256) NOT NULL
);

CREATE TABLE IF NOT EXISTS `UserGroup` (
    userId INT UNSIGNED NOT NULL,
    groupId INT UNSIGNED NOT NULL,
    PRIMARY KEY (userId, groupId),
    FOREIGN KEY (userId) REFERENCES `User`(id),
    FOREIGN KEY (groupId) REFERENCES `Group`(id)
);

CREATE TABLE IF NOT EXISTS `Policy` (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    policyname VARCHAR(256) NOT NULL
);

CREATE TABLE IF NOT EXISTS `GroupPolicy` (
    groupId INT UNSIGNED NOT NULL,
    policyId INT UNSIGNED NOT NULL,
    PRIMARY KEY (groupId, policyId),
    FOREIGN KEY (groupId) REFERENCES `Group`(id),
    FOREIGN KEY (policyId) REFERENCES `Policy`(id)
);

CREATE TABLE IF NOT EXISTS `ToolingPermission` (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    permissionName VARCHAR(256) NOT NULL,
    UNIQUE INDEX(permissionName)
);

CREATE TABLE IF NOT EXISTS `GroupToolingPermission` (
    groupId INT UNSIGNED NOT NULL,
    permissionId INT UNSIGNED NOT NULL,
    effect ENUM('allow', 'deny') NOT NULL,
    validUntil TIMESTAMP,
    PRIMARY KEY (groupId, permissionId),
    FOREIGN KEY (groupId) REFERENCES `Group`(id),
    FOREIGN KEY (permissionId) REFERENCES `ToolingPermission`(id)
);
