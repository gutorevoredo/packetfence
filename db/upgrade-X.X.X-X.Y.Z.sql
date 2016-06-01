--
-- PacketFence SQL schema upgrade from X.X.X to X.Y.Z
--

--
-- Additionnal fields for the Fingerbank integration
--

ALTER TABLE node ADD COLUMN `device_version` varchar(255) DEFAULT NULL AFTER `device_class`;
ALTER TABLE node ADD COLUMN `device_score` varchar(255) DEFAULT NULL AFTER `device_version`;

--
-- Setting the major/minor/sub-minor version of the DB
--

SET @MAJOR_VERSION = 6;
SET @MINOR_VERSION = 2;
SET @SUBMINOR_VERSION = 9;

--
-- The VERSION_INT to ensure proper ordering of the version in queries
--

SET @VERSION_INT = @MAJOR_VERSION << 16 | @MINOR_VERSION << 8 | @SUBMINOR_VERSION;

--
-- Add 'callingstationid' index to radacct table
--

ALTER TABLE radacct ADD KEY `callingstationid` (`callingstationid`);

--
-- Creating radippool table
--

CREATE TABLE radippool (
  id                    int(11) unsigned NOT NULL auto_increment,
  pool_name             varchar(30) NOT NULL,
  framedipaddress       varchar(15) NOT NULL default '',
  nasipaddress          varchar(15) NOT NULL default '',
  calledstationid       VARCHAR(30) NOT NULL,
  callingstationid      VARCHAR(30) NOT NULL,
  expiry_time           DATETIME NULL default NULL,
  start_time            DATETIME NULL default NULL,
  username              varchar(64) NOT NULL default '',
  pool_key              varchar(30) NOT NULL,
  lease_time            varchar(30) NULL,
  PRIMARY KEY (id),
  UNIQUE (framedipaddress),
  KEY radippool_poolname_expire (pool_name, expiry_time),
  KEY callingstationid (callingstationid),
  KEY radippool_framedipaddress (framedipaddress),
  KEY radippool_nasip_poolkey_ipaddress (nasipaddress, pool_key, framedipaddress),
  KEY radippool_callingstationid_expiry (callingstationid, expiry_time),
  KEY radippool_framedipaddress_expiry (framedipaddress, expiry_time)
) ENGINE=InnoDB;
