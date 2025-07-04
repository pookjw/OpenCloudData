//
//  OCSPIResolver.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/30/25.
//

#import "OpenCloudData/SPI/OCSPIResolver.h"
@import ellekit;

__attribute__((objc_direct_members))
@interface OCSPIResolver ()
@property (class, nonatomic, readonly, getter=_cdImage) const void *cdImage;
@property (class, nonatomic, readonly, getter=_ckImage) const void *ckImage;
@end

@implementation OCSPIResolver

+ (const void *)_cdImage {
    static const void *result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
    });
    return result;
}

+ (const void *)_ckImage {
    static const void *result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = MSGetImageByName("/System/Library/Frameworks/CloudKit.framework/CloudKit");
    });
    return result;
}

+ (const void *)_addressFromCoreDataForSymbol:(const char *)symbol {
    return MSFindSymbol(OCSPIResolver.cdImage, symbol);
}

+ (const void *)_addressFromCloudKitForSymbol:(const char *)symbol {
    return MSFindSymbol(OCSPIResolver.ckImage, symbol);
}

+ (void)NSSQLCore_dispatchRequest_withRetries_:(NSSQLCore *)x0 x1:(NSSQLBlockRequestContext *)x1 x2:(NSUInteger)x2 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLCore dispatchRequest:withRetries:]"];
    ((void (*)(id, id, NSUInteger))addr)(x0, x1, x2);
}

+ (BOOL)NSSQLiteConnection__hasTableWithName_isTemp:(NSSQLiteConnection *)x0 x1:(NSString *)x1 x2:(BOOL)x2 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection _hasTableWithName:isTemp:]"];
    return ((BOOL (*)(id, id, BOOL))addr)(x0, x1, x2);
}

+ (void)NSSQLiteConnection_connect:(NSSQLiteConnection *)x0 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection connect]"];
    ((void (*)(id))addr)(x0);
}

+ (void)NSSQLiteConnection_beginTransaction:(NSSQLiteConnection *)x0 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection beginTransaction]"];
    ((void (*)(id))addr)(x0);
}

+ (void)NSSQLiteConnection_dedupeRowsForUniqueConstraintsInCloudKitMetadataEntity_:(NSSQLiteConnection *)x0 x1:(NSSQLEntity *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection dedupeRowsForUniqueConstraintsInCloudKitMetadataEntity:]"];
    ((void (*)(id, id))addr)(x0, x1);
}

+ (void)NSSQLiteConnection_prepareAndExecuteSQLStatement_:(NSSQLiteConnection *)x0 x1:(NSSQLiteStatement *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection prepareAndExecuteSQLStatement:]"];
    ((void (*)(id, id))addr)(x0, x1);
}

+ (void)NSSQLiteConnection_createTablesForEntities_:(NSSQLiteConnection *)x0 x1:(NSArray<NSSQLEntity *> *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection createTablesForEntities:]"];
    ((void (*)(id, id))addr)(x0, x1);
}

+ (void)NSSQLiteConnection_commitTransaction:(NSSQLiteConnection *)x0 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection commitTransaction]"];
    ((void (*)(id))addr)(x0);
}

+ (void)NSSQLiteConnection_endFetchAndRecycleStatement_:(NSSQLiteConnection *)x0 x1:(BOOL)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection endFetchAndRecycleStatement:]"];
    ((void (*)(id, BOOL))addr)(x0, x1);
}

+ (void)NSSQLiteConnection_rollbackTransaction:(NSSQLiteConnection *)x0 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection rollbackTransaction]"];
    ((void (*)(id))addr)(x0);
}

+ (void)NSSQLiteConnection_disconnect:(NSSQLiteConnection *)x0 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection disconnect]"];
    ((void (*)(id))addr)(x0);
}

+ (BOOL)NSSQLiteConnection__tableHasRows_:(NSSQLiteConnection *)x0 x1:(NSString *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection _tableHasRows:]"];
    return ((BOOL (*)(id, id))addr)(x0, x1);
}

+ (NSArray<NSArray<NSString *> *> *)NSSQLiteConnection_fetchTableCreationSQLContaining_:(NSSQLiteConnection *)x0 x1:(NSString *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection fetchTableCreationSQLContaining:]"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSArray<NSArray<NSNumber *> *> *)NSSQLiteConnection_createArrayOfPrimaryKeysAndEntityIDsForRowsWithoutRecordMetadataWithEntity_metadataEntity_:(NSSQLiteConnection *)x0 x1:(NSSQLEntity *)x1 x2:(NSSQLEntity *)x2 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteConnection createArrayOfPrimaryKeysAndEntityIDsForRowsWithoutRecordMetadataWithEntity:metadataEntity:]"];
    return ((id (*)(id, id, id))addr)(x0, x1, x2);
}

+ (NSSQLiteStatement *)NSSQLiteAdapter_newCreateTableStatementForManyToMany_:(NSSQLiteAdapter *)x0 x1:(NSRelationshipDescription *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteAdapter newCreateTableStatementForManyToMany:]"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSSQLiteStatement *)NSSQLiteAdapter_newCreateTableStatementForEntity_:(NSSQLiteAdapter *)x0 x1:(NSSQLEntity *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteAdapter newCreateTableStatementForEntity:]"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSSQLiteStatement *)NSSQLiteAdapter_newPrimaryKeyInitializeStatementForEntity_withInitialMaxPK_:(NSSQLiteAdapter *)x0 x1:(NSSQLEntity *)x1 x2:(uint)x2 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteAdapter newPrimaryKeyInitializeStatementForEntity:withInitialMaxPK:]"];
    return ((id (*)(id, id, uint))addr)(x0, x1, x2);
}

+ (NSSQLiteStatement *)NSSQLiteAdapter_newSimplePrimaryKeyUpdateStatementForEntity_:(NSSQLiteAdapter *)x0 x1:(NSSQLEntity *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteAdapter newSimplePrimaryKeyUpdateStatementForEntity:]"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSSQLiteStatement *)NSSQLiteAdapter_newDropTableStatementForTableNamed_:(NSSQLiteAdapter *)x0 x1:(NSString *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteAdapter newDropTableStatementForTableNamed:]"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSArray<NSSQLiteStatement *> *)NSSQLiteAdapter_newCreateIndexStatementsForEntity_defaultIndicesOnly_:(NSSQLiteAdapter *)x0 x1:(NSSQLEntity *)x1 x2:(BOOL)x2 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteAdapter newCreateIndexStatementsForEntity:defaultIndicesOnly:]"];
    return ((id (*)(id, id, BOOL))addr)(x0, x1, x2);
}

+ (NSString *)NSSQLiteAdapter_typeStringForColumn_:(NSSQLiteAdapter *)x0 x1:(NSSQLColumn *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSSQLiteAdapter typeStringForColumn:]"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSInteger)NSManagedObjectContext__countForFetchRequest__error_:(NSManagedObjectContext *)x0 x1:(NSFetchRequest *)x1 x2:(NSError * _Nullable *)x2 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[NSManagedObjectContext _countForFetchRequest_:error:]"];
    return ((NSInteger (*)(id, id, id *))addr)(x0, x1, x2);
}

+ (NSSQLEntity *)_sqlCoreLookupSQLEntityForEntityID:(NSSQLCore *)x0 x1:(NSUInteger)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"__sqlCoreLookupSQLEntityForEntityID"];
    return ((id (*)(id, NSUInteger))addr)(x0, x1);
}

+ (NSSQLEntity * _Nullable)_sqlEntityForEntityDescription:(NSSQLModel *)x0 x1:(NSEntityDescription *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"__sqlEntityForEntityDescription"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSNumber *)_PFRoutines__getPFBundleVersionNumber:(Class)x0 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[_PFRoutines _getPFBundleVersionNumber]"];
    return ((id (*)(Class))addr)(x0);
}

+ (NSData *)_NSDataFileBackedFuture__storeMetadata:(_NSDataFileBackedFuture *)x0 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[_NSDataFileBackedFuture _storeMetadata]"];
    return ((id (*)(id))addr)(x0);
}

+ (void)_PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:(Class)x0 x1:(NSFetchRequest *)x1 x2:(NSManagedObjectContext *)x2 x3:(void (^ NS_NOESCAPE)(NSArray<__kindof NSManagedObject *> * _Nullable, NSError * _Nullable, BOOL * _Nonnull, BOOL * _Nonnull))x3 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[_PFRoutines efficientlyEnumerateManagedObjectsInFetchRequest:usingManagedObjectContext:andApplyBlock:]"];
    ((void (*)(Class, id, id, id))addr)(x0, x1, x2, x3);
}

+ (BOOL)_PFRoutines__isInMemoryStore_:(Class)x0 x1:(NSPersistentStore *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[_PFRoutines _isInMemoryStore:]"];
    return ((BOOL (*)(Class, id))addr)(x0, x1);
}

+ (BOOL)_PFRoutines__isInMemoryStoreURL_:(Class)x0 x1:(NSURL *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[_PFRoutines _isInMemoryStoreURL:]"];
    return ((BOOL (*)(Class, id))addr)(x0, x1);
}

+ (NSData *)_PFRoutines_retainedEncodeObjectValue_forTransformableAttribute_:(Class)x0 x1:(id)x1 x2:(NSAttributeDescription *)x2 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[_PFRoutines retainedEncodeObjectValue:forTransformableAttribute:]"];
    return ((id (*)(Class, id, id))addr)(x0, x1, x2);
}

+ (__kindof PFHistoryAnalyzerContext *)PFHistoryAnalyzer_newAnalyzerContextForStore_sinceLastHistoryToken_inManagedObjectContext_error_:(__kindof PFHistoryAnalyzer *)x0 x1:(NSPersistentStore *)x1 x2:(NSPersistentHistoryToken *)x2 x3:(NSManagedObjectContext *)x3 x4:(NSError * _Nullable *)x4 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[PFHistoryAnalyzer newAnalyzerContextForStore:sinceLastHistoryToken:inManagedObjectContext:error:]"];
    return ((id (*)(id, id, id, id, id *))addr)(x0, x1, x2, x3, x4);
}

+ (NSString *)PFCloudKitSerializer_mtmKeyForObjectWithRecordName_relatedToObjectWithRecordName_byRelationship_withInverse_:(Class)x0 x1:(NSString *)x1 x2:(NSString *)x2 x3:(NSRelationshipDescription *)x3 x4:(NSRelationshipDescription *)x4 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFCloudKitSerializer mtmKeyForObjectWithRecordName:relatedToObjectWithRecordName:byRelationship:withInverse:]"];
    return ((id (*)(Class, id, id, id, id))addr)(x0, x1, x2, x3, x4);
}

+ (size_t)PFCloudKitSerializer_estimateByteSizeOfRecordID_:(Class)x0 x1:(CKRecordID *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFCloudKitSerializer estimateByteSizeOfRecordID:]"];
    return ((size_t (*)(Class, id))addr)(x0, x1);
}

+ (CKRecordType)PFCloudKitSerializer_recordTypeForEntity_:(Class)x0 x1:(NSEntityDescription *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFCloudKitSerializer recordTypeForEntity:]"];
    return ((id (*)(Class, id))addr)(x0, x1);
}

+ (BOOL)PFCloudKitSerializer_isMirroredRelationshipRecordType_:(Class)x0 x1:(CKRecordType)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFCloudKitSerializer isMirroredRelationshipRecordType:]"];
    return ((BOOL (*)(Class, id))addr)(x0, x1);
}

+ (NSSet<NSManagedObjectID *> *)PFCloudKitSerializer_createSetOfObjectIDsRelatedToObject_:(Class)x0 x1:(NSManagedObject *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFCloudKitSerializer createSetOfObjectIDsRelatedToObject:]"];
    return ((id (*)(Class, id))addr)(x0, x1);
}

+ (NSURL *)PFCloudKitSerializer_generateCKAssetFileURLForObjectInStore_:(Class)x0 x1:(NSPersistentStore *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFCloudKitSerializer generateCKAssetFileURLForObjectInStore:]"];
    return ((id (*)(Class, id))addr)(x0, x1);
}

+ (NSURL *)PFCloudKitSerializer_assetStorageDirectoryURLForStore_:(Class)x0 x1:(NSPersistentStore *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFCloudKitSerializer assetStorageDirectoryURLForStore:]"];
    return ((id (*)(Class, id))addr)(x0, x1);
}

+ (PFMirroredRelationship *)PFMirroredRelationship_mirroredRelationshipWithManagedObject_withRecordID_relatedToObjectWithRecordID_byRelationship_:(Class)x0 x1:(NSManagedObject *)x1 x2:(CKRecordID *)x2 x3:(CKRecordID *)x3 x4:(NSRelationshipDescription *)x4 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFMirroredRelationship mirroredRelationshipWithManagedObject:withRecordID:relatedToObjectWithRecordID:byRelationship:]"];
    return ((id (*)(Class, id, id, id, id))addr)(x0, x1, x2, x3, x4);
}

+ (PFMirroredManyToManyRelationship *)PFMirroredRelationship_mirroredRelationshipWithManyToManyRecord_values_andManagedObjectModel_:(Class)x0 x1:(CKRecord *)x1 x2:(id<CKRecordKeyValueSetting>)x2 x3:(NSManagedObjectModel *)x3 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFMirroredRelationship mirroredRelationshipWithManagedObject:withRecordID:relatedToObjectWithRecordID:byRelationship:]"];
    return ((id (*)(Class, id, id, id))addr)(x0, x1, x2, x3);
}

+ (NSDictionary<NSString *, NSArray<CKRecordID *> *> *)PFMirroredManyToManyRelationship_recordTypeToRecordID:(PFMirroredManyToManyRelationship *)x0 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[PFMirroredManyToManyRelationship recordTypeToRecordID]"];
    return ((id (*)(id))addr)(x0);
}

+ (PFMirroredManyToManyRelationship *)PFMirroredRelationship_mirroredRelationshipWithDeletedRecordType_recordID_andManagedObjectModel_:(Class)x0 x1:(CKRecordType)x1 x2:(CKRecordID *)x2 x3:(NSManagedObjectModel *)x3 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFMirroredRelationship mirroredRelationshipWithDeletedRecordType:recordID:andManagedObjectModel:]"];
    return ((id (*)(Class, id, id, id))addr)(x0, x1, x2, x3);
}

+ (NSDictionary<NSString *,NSArray<CKRecordID *> *> *)PFMirroredOneToManyRelationship_recordTypesToRecordIDs:(PFMirroredOneToManyRelationship *)x0 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"-[PFMirroredOneToManyRelationship recordTypesToRecordIDs]"];
    return ((id (*)(id))addr)(x0);
}

+ (CKRecordType)PFMirroredManyToManyRelationship_ckRecordTypeForOrderedRelationships_:(Class)x0 x1:(NSArray<NSRelationshipDescription *> *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFMirroredManyToManyRelationship ckRecordTypeForOrderedRelationships:]"];
    return ((id (*)(Class, id))addr)(x0, x1);
}

+ (CKRecordType)PFMirroredManyToManyRelationship_ckRecordNameForOrderedRecordNames_:(Class)x0 x1:(NSArray<NSString *> *)x1 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFMirroredManyToManyRelationship ckRecordNameForOrderedRecordNames:]"];
    return ((id (*)(Class, id))addr)(x0, x1);
}

+ (NSString *)_PFModelMapPathForEntity:(NSEntityDescription *)x0 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"__PFModelMapPathForEntity"];
    return ((id (*)(id))addr)(x0);
}

+ (CKRecord *)PFCloudKitSchemaGenerator_newRepresentativeRecordForStaticFieldsInEntity_inZoneWithID_:(Class)x0 x1:(NSEntityDescription *)x1 x2:(CKRecordZoneID *)x2 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[PFCloudKitSchemaGenerator newRepresentativeRecordForStaticFieldsInEntity:inZoneWithID:]"];
    return ((id (*)(Class, id, id))addr)(x0, x1, x2);
}

+ (NSString *)NSCloudKitMirroringDelegateExportContextName {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateExportContextName"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateImportContextName {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateImportContextName"];
    return *(id *)addr;
}

+ (NSString *)PFCloudKitMetadataNeedsZoneFetchAfterClientMigrationKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_PFCloudKitMetadataNeedsZoneFetchAfterClientMigrationKey"];
    return *(id *)addr;
}

+ (NSString *)NSPersistentStoreMirroringDelegateOptionKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSPersistentStoreMirroringDelegateOptionKey"];
    return *(id *)addr;
}

+ (NSString *)NSSQLPKTableName {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSSQLPKTableName"];
    return *(id *)addr;
}

+ (NSString *)PFCloudKitMetadataFrameworkVersionKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_PFCloudKitMetadataFrameworkVersionKey"];
    return *(id *)addr;
}

+ (NSString *)PFCloudKitMetadataModelVersionHashesKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_PFCloudKitMetadataModelVersionHashesKey"];
    return *(id *)addr;
}

+ (NSString *)PFCloudKitMetadataNeedsMetadataMigrationKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_PFCloudKitMetadataNeedsMetadataMigrationKey"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateLastHistoryTokenKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateLastHistoryTokenKey"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateCKIdentityRecordNameDefaultsKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateCKIdentityRecordNameDefaultsKey"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateCheckedCKIdentityDefaultsKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateCheckedCKIdentityDefaultsKey"];
    return *(id *)addr;
}

+ (NSString *)PFCloudKitMetadataClientVersionHashesKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_PFCloudKitMetadataClientVersionHashesKey"];
    return *(id *)addr;
}

+ (NSString *)NSCKRecordIDAttributeName {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCKRecordIDAttributeName"];
    return *(id *)addr;
}

+ (NSString *)NSCKRecordSystemFieldsAttributeName {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCKRecordSystemFieldsAttributeName"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateResetSyncAuthor {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateResetSyncAuthor"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateBypassHistoryOnExportKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateBypassHistoryOnExportKey"];
    return *(id *)addr;
}

+ (NSString *)PFCloudKitServerChangeTokenKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_PFCloudKitServerChangeTokenKey"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateServerChangeTokensKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateServerChangeTokensKey"];
    return *(id *)addr;
}

+ (NSNotificationName)_NSPersistentStoreCoordinatorPrivateWillRemoveStoreNotification {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"__NSPersistentStoreCoordinatorPrivateWillRemoveStoreNotification"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateMigrationAuthor {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateMigrationAuthor"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateScanForRowsMissingFromHistoryKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateScanForRowsMissingFromHistoryKey"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateIgnoredPropertyKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateIgnoredPropertyKey"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateSetupAuthor {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateSetupAuthor"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateEventAuthor {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateEventAuthor"];
    return *(id *)addr;
}

+ (NSString *)PFCloudKitMirroringDelegateToManyPrefix {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_PFCloudKitMirroringDelegateToManyPrefix"];
    return *(id *)addr;
}

+ (NSString *)NSPersistentCloudKitContainerEncryptedAttributeKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSPersistentCloudKitContainerEncryptedAttributeKey"];
    return *(id *)addr;
}

+ (NSString *)PFCloudKitFakeRecordNamePrefix {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_PFCloudKitFakeRecordNamePrefix"];
    return *(id *)addr;
}

+ (NSNotificationName)NSCloudKitMirroringDelegateWillResetSyncNotificationName {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateWillResetSyncNotificationName"];
    return *(id *)addr;
}

+ (NSNotificationName)NSCloudKitMirroringDelegateDidResetSyncNotificationName {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateDidResetSyncNotificationName"];
    return *(id *)addr;
}

+ (NSString *)NSPersistentHistoryTombstoneAttributes {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSPersistentHistoryTombstoneAttributes"];
    return *(id *)addr;
}

+ (NSNotificationName)NSPersistentCloudKitContainerActivityChangedNotificationName {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSPersistentCloudKitContainerActivityChangedNotificationName"];
    return *(id *)addr;
}

+ (CKSubscriptionID)PFPrivateDatabaseSubscriptionID {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_PFPrivateDatabaseSubscriptionID"];
    return *(id *)addr;
}

+ (CKSubscriptionID)PFPublicDatabaseSubscriptionID {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"PFPublicDatabaseSubscriptionID"];
    return *(id *)addr;
}

+ (CKSubscriptionID)PFSharedDatabaseSubscriptionID {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_PFSharedDatabaseSubscriptionID"];
    return *(id *)addr;
}

+ (NSString *)PFCloudKitOldUserIdentityKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_PFCloudKitOldUserIdentityKey"];
    return *(id *)addr;
}

+ (NSString *)PFCloudKitNewUserIdentityKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_PFCloudKitNewUserIdentityKey"];
    return *(id *)addr;
}

+ (NSString *)NSCloudKitMirroringDelegateResetSyncReasonKey {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSCloudKitMirroringDelegateResetSyncReasonKey"];
    return *(id *)addr;
}

+ (void)_PFModelUtilities_addAttributes_toPropertiesOfEntity:(Class)x0 x1:(NSDictionary<NSString *,NSArray *> *)x1 x2:(NSEntityDescription *)x2 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[_PFModelUtilities addAttributes:toPropertiesOfEntity:]"];
    ((void (*)(Class, id, id))addr)(x0, x1, x2);
}

+ (void)_PFModelUtilities_addRelationships_toPropertiesOfEntity:(Class)x0 x1:(NSDictionary<NSString *,NSArray *> *)x1 x2:(NSEntityDescription *)x2 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"+[_PFModelUtilities addRelationships:toPropertiesOfEntity:]"];
    ((void (*)(Class, id, id))addr)(x0, x1, x2);
}

+ (NSArray *)NSArray_EmptyArray {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSArray_EmptyArray"];
    return *(id *)addr;
}

+ (NSSet *)NSSet_EmptySet {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_NSSet_EmptySet"];
    return *(id *)addr;
}

+ (BOOL)z9dsptsiQ80etb9782fsrs98bfdle88 {
    const void *addr = [OCSPIResolver _addressFromCoreDataForSymbol:"_z9dsptsiQ80etb9782fsrs98bfdle88"];
    return *(BOOL *)addr;
}

@end
