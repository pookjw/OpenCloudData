//
//  OCSPIResolver.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/30/25.
//

#import <OpenCloudData/OCSPIResolver.h>
@import ellekit;

__attribute__((objc_direct_members))
@interface OCSPIResolver ()
@property (class, nonatomic, readonly, getter=_cdImage) const void *cdImage;
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

+ (const void *)_addressForSymbol:(const char *)symbol {
    return MSFindSymbol(OCSPIResolver.cdImage, symbol);
}

+ (void)NSSQLCore_dispatchRequest_withRetries_:(NSSQLCore *)x0 x1:(NSSQLBlockRequestContext *)x1 x2:(NSUInteger)x2 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLCore dispatchRequest:withRetries:]"];
    ((void (*)(id, id, NSUInteger))addr)(x0, x1, x2);
}

+ (BOOL)NSSQLiteConnection__hasTableWithName_isTemp:(NSSQLiteConnection *)x0 x1:(NSString *)x1 x2:(BOOL)x2 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection _hasTableWithName:isTemp:]"];
    return ((BOOL (*)(id, id, BOOL))addr)(x0, x1, x2);
}

+ (void)NSSQLiteConnection_connect:(NSSQLiteConnection *)x0 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection connect]"];
    ((void (*)(id))addr)(x0);
}

+ (void)NSSQLiteConnection_beginTransaction:(NSSQLiteConnection *)x0 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection beginTransaction]"];
    ((void (*)(id))addr)(x0);
}

+ (void)NSSQLiteConnection_dedupeRowsForUniqueConstraintsInCloudKitMetadataEntity_:(NSSQLiteConnection *)x0 x1:(NSSQLEntity *)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection dedupeRowsForUniqueConstraintsInCloudKitMetadataEntity:]"];
    ((void (*)(id, id))addr)(x0, x1);
}

+ (void)NSSQLiteConnection_prepareAndExecuteSQLStatement_:(NSSQLiteConnection *)x0 x1:(NSSQLiteStatement *)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection prepareAndExecuteSQLStatement:]"];
    ((void (*)(id, id))addr)(x0, x1);
}

+ (void)NSSQLiteConnection_createTablesForEntities_:(NSSQLiteConnection *)x0 x1:(NSArray<NSSQLEntity *> *)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection createTablesForEntities:]"];
    ((void (*)(id, id))addr)(x0, x1);
}

+ (void)NSSQLiteConnection_commitTransaction:(NSSQLiteConnection *)x0 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection commitTransaction]"];
    ((void (*)(id))addr)(x0);
}

+ (void)NSSQLiteConnection_endFetchAndRecycleStatement_:(NSSQLiteConnection *)x0 x1:(BOOL)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection endFetchAndRecycleStatement:]"];
    ((void (*)(id, BOOL))addr)(x0, x1);
}

+ (void)NSSQLiteConnection_rollbackTransaction:(NSSQLiteConnection *)x0 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection rollbackTransaction]"];
    ((void (*)(id))addr)(x0);
}

+ (void)NSSQLiteConnection_disconnect:(NSSQLiteConnection *)x0 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection disconnect]"];
    ((void (*)(id))addr)(x0);
}

+ (BOOL)NSSQLiteConnection__tableHasRows_:(NSSQLiteConnection *)x0 x1:(NSString *)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection _tableHasRows:]"];
    return ((BOOL (*)(id, id))addr)(x0, x1);
}

+ (NSArray<NSArray<NSString *> *> *)NSSQLiteConnection_fetchTableCreationSQLContaining_:(NSSQLiteConnection *)x0 x1:(NSString *)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection fetchTableCreationSQLContaining:]"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSArray<NSArray<NSNumber *> *> *)NSSQLiteConnection_createArrayOfPrimaryKeysAndEntityIDsForRowsWithoutRecordMetadataWithEntity_metadataEntity_:(NSSQLiteConnection *)x0 x1:(NSSQLEntity *)x1 x2:(NSSQLEntity *)x2 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteConnection createArrayOfPrimaryKeysAndEntityIDsForRowsWithoutRecordMetadataWithEntity:metadataEntity:]"];
    return ((id (*)(id, id, id))addr)(x0, x1, x2);
}

+ (NSSQLiteStatement *)NSSQLiteAdapter_newCreateTableStatementForManyToMany_:(NSSQLiteAdapter *)x0 x1:(NSRelationshipDescription *)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteAdapter newCreateTableStatementForManyToMany:]"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSSQLiteStatement *)NSSQLiteAdapter_newCreateTableStatementForEntity_:(NSSQLiteAdapter *)x0 x1:(NSSQLEntity *)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteAdapter newCreateTableStatementForEntity:]"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSSQLiteStatement *)NSSQLiteAdapter_newPrimaryKeyInitializeStatementForEntity_withInitialMaxPK_:(NSSQLiteAdapter *)x0 x1:(NSSQLEntity *)x1 x2:(uint)x2 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteAdapter newPrimaryKeyInitializeStatementForEntity:withInitialMaxPK:]"];
    return ((id (*)(id, id, uint))addr)(x0, x1, x2);
}

+ (NSSQLiteStatement *)NSSQLiteAdapter_newSimplePrimaryKeyUpdateStatementForEntity_:(NSSQLiteAdapter *)x0 x1:(NSSQLEntity *)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteAdapter newSimplePrimaryKeyUpdateStatementForEntity:]"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSSQLiteStatement *)NSSQLiteAdapter_newDropTableStatementForTableNamed_:(NSSQLiteAdapter *)x0 x1:(NSString *)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteAdapter newDropTableStatementForTableNamed:]"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSArray<NSSQLiteStatement *> *)NSSQLiteAdapter_newCreateIndexStatementsForEntity_defaultIndicesOnly_:(NSSQLiteAdapter *)x0 x1:(NSSQLEntity *)x1 x2:(BOOL)x2 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteAdapter newCreateIndexStatementsForEntity:defaultIndicesOnly:]"];
    return ((id (*)(id, id, BOOL))addr)(x0, x1, x2);
}

+ (NSString *)NSSQLiteAdapter_typeStringForColumn_:(NSSQLiteAdapter *)x0 x1:(NSSQLColumn *)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSSQLiteAdapter typeStringForColumn:]"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSInteger)NSManagedObjectContext__countForFetchRequest__error_:(NSManagedObjectContext *)x0 x1:(NSFetchRequest *)x1 x2:(NSError * _Nullable *)x2 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[NSManagedObjectContext _countForFetchRequest_:error:]"];
    return ((NSInteger (*)(id, id, id *))addr)(x0, x1, x2);
}

+ (NSSQLEntity *)_sqlCoreLookupSQLEntityForEntityID:(NSSQLCore *)x0 x1:(NSUInteger)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"__sqlCoreLookupSQLEntityForEntityID"];
    return ((id (*)(id, NSUInteger))addr)(x0, x1);
}

+ (NSSQLEntity *)_sqlEntityForEntityDescription:(NSEntityDescription *)x0 x1:(NSSQLModel *)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"__sqlEntityForEntityDescription"];
    return ((id (*)(id, id))addr)(x0, x1);
}

+ (NSNumber *)_PFRoutines__getPFBundleVersionNumber:(Class)x0 {
    const void *addr = [OCSPIResolver _addressForSymbol:"+[_PFRoutines _getPFBundleVersionNumber]"];
    return ((id (*)(Class))addr)(x0);
}

+ (void)_PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:(Class)x0 x1:(NSFetchRequest *)x1 x2:(NSManagedObjectContext *)x2 x3:(void (^ NS_NOESCAPE)(NSArray<__kindof NSManagedObject *> * _Nullable, NSError * _Nullable, BOOL * _Nonnull, BOOL * _Nonnull))x3 {
    const void *addr = [OCSPIResolver _addressForSymbol:"+[_PFRoutines efficientlyEnumerateManagedObjectsInFetchRequest:usingManagedObjectContext:andApplyBlock:]"];
    ((void (*)(Class, id, id, id))addr)(x0, x1, x2, x3);
}

+ (BOOL)_PFRoutines__isInMemoryStore_:(Class)x0 x1:(NSPersistentStore *)x1 {
    const void *addr = [OCSPIResolver _addressForSymbol:"+[_PFRoutines _isInMemoryStore:]"];
    return ((BOOL (*)(Class, id))addr)(x0, x1);
}

+ (__kindof PFHistoryAnalyzerContext *)PFHistoryAnalyzer_newAnalyzerContextForStore_sinceLastHistoryToken_inManagedObjectContext_error_:(__kindof PFHistoryAnalyzer *)x0 x1:(NSPersistentStore *)x1 x2:(NSPersistentHistoryToken *)x2 x3:(NSManagedObjectContext *)x3 x4:(NSError * _Nullable *)x4 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-[PFHistoryAnalyzer newAnalyzerContextForStore:sinceLastHistoryToken:inManagedObjectContext:error:]"];
    return ((id (*)(id, id, id, id, id *))addr)(x0, x1, x2, x3, x4);
}

+ (NSString *)_PFModelMapPathForEntity:(NSEntityDescription *)x0 {
    const void *addr = [OCSPIResolver _addressForSymbol:"-__PFModelMapPathForEntity"];
    return ((id (*)(id))addr)(x0);
}

@end
