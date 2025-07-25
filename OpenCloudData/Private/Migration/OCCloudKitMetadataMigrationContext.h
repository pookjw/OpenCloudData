//
//  OCCloudKitMetadataMigrationContext.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <CoreData/CoreData.h>
#import "OpenCloudData/SPI/CoreData/NSSQLModel.h"
#import "OpenCloudData/SPI/CoreData/NSSQLiteStatement.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMetadataMigrationContext : NSObject {
    @package NSMutableArray<NSSQLiteStatement *> *_migrationStatements; // 0x8
    @package NSMutableArray<NSSQLEntity *> *_sqlEntitiesToCreate; // 0x10
    @package NSMutableSet<NSSQLEntity *> *_constrainedEntitiesToPreflight; // 0x18
    @package BOOL _hasWorkToDo; // 0x20
    @package BOOL _needsMetdataMigrationToNSCKRecordMetadata; // 0x21
    @package BOOL _needsMirroredRelationshipsLinkedToZone; // 0x23
    @package BOOL _needsOldTableDrop; // 0x22
    @package BOOL _needsImportAfterClientMigration; // 0x24
    @package BOOL _needsBatchUpdateForSystemFieldsAndLastExportedTransaction; // 0x25
    @package BOOL _needsAnalyzedHistoryCheck; // 0x26
    @package BOOL _needsCleanupFromNeedsNewShareInvitationBug; // 0x27
    @package BOOL _needsCleanupFromOrphanedMirroredRelationships; // 0x28
    @package NSManagedObjectModel *_currentModel; // 0x30
    @package NSSQLModel *_sqlModel; // 0x38
    @package NSManagedObjectModel *_storeMetadataModel; // 0x40
    @package NSSQLModel *_storeSQLModel; // 0x48
    @package NSNumber *_storeMetadataVersion; // 0x50
    @package NSDictionary *_storeMetadataVersionHashes; // 0x58
}
@property (strong, nonatomic, nullable, direct) NSManagedObjectModel *currentModel; // 0x30
@property (strong, nonatomic, nullable, direct) NSSQLModel *sqlModel; // 0x38
@property (strong, nonatomic, nullable, direct) NSManagedObjectModel *storeMetadataModel; // 0x40
@property (strong, nonatomic, nullable, direct) NSSQLModel *storeSQLModel; // 0x48
@property (strong, nonatomic, nullable, direct) NSNumber *storeMetadataVersion; // 0x50
@property (strong, nonatomic, nullable, direct) NSDictionary *storeMetadataVersionHashes; // 0x50
- (void)addConstrainedEntityToPreflight:(NSSQLEntity *)entity;
@end

NS_ASSUME_NONNULL_END
