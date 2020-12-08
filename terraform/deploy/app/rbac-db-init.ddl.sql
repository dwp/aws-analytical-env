CREATE TABLE IF NOT EXISTS `User` (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR (256) NOT NULL,
    accountname VARCHAR(256),
    active TINYINT(1) DEFAULT TRUE NOT NULL
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