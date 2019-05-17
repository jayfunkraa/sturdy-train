DELETE FROM uMasterDataColumn 
WHERE       uMasterData_ID IN 
                (
                    SELECT  ID 
                    FROM    uMasterData
                    WHERE   GroupName = 'Reliability'
                    AND     TableName NOT IN 
                                (
	                                'tRelRepSystemReliability', 
	                                'tRelRepSystemReliability',
	                                'tRelRepSystemReliabilityAlertLevelATAChapter',
	                                'tRelRepSystemReliabilityAlertLevelATASystem',
	                                'tRelRepAlertLevel',
	                                'tRelRepComponentReliability', 
	                                'tRelRepAvailabilityDispatchReliability'
	                            )
                )

DELETE FROM uMasterData
WHERE       GroupName = 'Reliability'
AND         TableName NOT IN 
                (
	                'tRelRepSystemReliability', 
	                'tRelRepSystemReliability',
	                'tRelRepSystemReliabilityAlertLevelATAChapter',
	                'tRelRepSystemReliabilityAlertLevelATASystem',
	                'tRelRepAlertLevel',
	                'tRelRepComponentReliability', 
	                'tRelRepAvailabilityDispatchReliability'
	            )

 DELETE	FROM    tReliabilityDataMapping
 WHERE	        BaseTableName NOT IN 
			        (
				        'tRelRepSystemReliability', 
				        'tRelRepSystemReliability',
				        'tRelRepSystemReliabilityAlertLevelATAChapter',
				        'tRelRepSystemReliabilityAlertLevelATASystem',
				        'tRelRepAlertLevel',
				        'tRelRepComponentReliability', 
				        'tRelRepAvailabilityDispatchReliability'
			        )

IF NOT EXISTS (SELECT 1 FROM uMasterData WHERE TableName = 'tRelRepSystemReliability')
INSERT INTO uMasterData (Code, Description, GroupName, SubGroupName, TableName, IsVisible,IsEditable, IsDefaultVisible, LockOnceUsed)
VALUES ('SYSTEMRELIABILITY', 'System Reliability', 'Reliability', 'System Reliability', 'tRelRepSystemReliability', 1, 1, 1, 0)

IF NOT EXISTS (SELECT 1 FROM uMasterData WHERE TableName = 'tRelRepSystemReliabilityAlertLevelATAChapter')
INSERT INTO uMasterData (Code, Description, GroupName, SubGroupName, TableName, IsVisible,IsEditable, IsDefaultVisible, LockOnceUsed)
VALUES ('SYSTEMRELIABILITYALERTLEVELATACHAPTER', 'Alert Level (ATA Chapter)', 'Reliability', 'System Reliability', 'tRelRepSystemReliabilityAlertLevelATAChapter', 1, 1, 1, 0)

IF NOT EXISTS (SELECT 1 FROM uMasterData WHERE TableName = 'tRelRepSystemReliabilityAlertLevelATASystem')
INSERT INTO uMasterData (Code, Description, GroupName, SubGroupName, TableName, IsVisible,IsEditable, IsDefaultVisible, LockOnceUsed)
VALUES ('SYSTEMRELIABILITYALERTLEVELATASYSTEM', 'Alert Level (ATA System)', 'Reliability', 'System Reliability', 'tRelRepSystemReliabilityAlertLevelATASystem', 1, 1, 1, 0)

IF NOT EXISTS (SELECT 1 FROM uMasterData WHERE TableName = 'tRelRepAlertLevel')
INSERT INTO uMasterData (Code, Description, GroupName, SubGroupName, TableName, IsVisible,IsEditable, IsDefaultVisible, LockOnceUsed)
VALUES ('SYSTEMRELIABILITYALERTLEVEL', 'Alert Level', 'Reliability', 'System Reliability', 'tRelRepAlertLevel', 1, 1, 1, 0)

IF NOT EXISTS (SELECT 1 FROM uMasterData WHERE TableName = 'tRelRepComponentReliability')
INSERT INTO uMasterData (Code, Description, GroupName, SubGroupName, TableName, IsVisible,IsEditable, IsDefaultVisible, LockOnceUsed)
VALUES ('COMPONENTRELIABILITY', 'Component Reliability', 'Reliability', '', 'tRelRepComponentReliability', 1, 1, 1, 0)