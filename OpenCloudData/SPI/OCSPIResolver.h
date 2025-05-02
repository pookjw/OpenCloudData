//
//  OCSPIResolver.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/30/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/NSSQLCore.h>
#import <OpenCloudData/NSSQLiteConnection.h>
#import <OpenCloudData/NSSQLBlockRequestContext.h>
#import <OpenCloudData/NSSQLEntity.h>
#import <OpenCloudData/PFHistoryAnalyzerContext.h>
#import <OpenCloudData/PFHistoryAnalyzer.h>
#import <OpenCloudData/NSSQLiteStatement.h>
#import <OpenCloudData/NSSQLiteAdapter.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface OCSPIResolver : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (void)NSSQLCore_dispatchRequest_withRetries_:(NSSQLCore *)x0 x1:(NSSQLBlockRequestContext *)x1 x2:(NSUInteger)x2;

+ (BOOL)NSSQLiteConnection__hasTableWithName_isTemp:(NSSQLiteConnection *)x0 x1:(NSString *)x1 x2:(BOOL)x2;
+ (void)NSSQLiteConnection_connect:(NSSQLiteConnection *)x0;
+ (void)NSSQLiteConnection_beginTransaction:(NSSQLiteConnection *)x0;
+ (void)NSSQLiteConnection_dedupeRowsForUniqueConstraintsInCloudKitMetadataEntity_:(NSSQLiteConnection *)x0 x1:(NSSQLEntity *)x1;
+ (void)NSSQLiteConnection_prepareAndExecuteSQLStatement_:(NSSQLiteConnection *)x0 x1:(NSSQLiteStatement *)x1;
+ (void)NSSQLiteConnection_createTablesForEntities_:(NSSQLiteConnection *)x0 x1:(NSArray<NSSQLEntity *> *)x1;
+ (void)NSSQLiteConnection_commitTransaction:(NSSQLiteConnection *)x0;
+ (void)NSSQLiteConnection_endFetchAndRecycleStatement_:(NSSQLiteConnection *)x0 x1:(BOOL)x1;
+ (void)NSSQLiteConnection_rollbackTransaction:(NSSQLiteConnection *)x0;
+ (void)NSSQLiteConnection_disconnect:(NSSQLiteConnection *)x0;
+ (NSArray<NSArray<NSNumber *> *> *)NSSQLiteConnection_createArrayOfPrimaryKeysAndEntityIDsForRowsWithoutRecordMetadataWithEntity_metadataEntity_:(NSSQLiteConnection *)x0 x1:(NSSQLEntity *)x1 x2:(NSSQLEntity *)x2;
+ (BOOL)NSSQLiteConnection__tableHasRows_:(NSSQLiteConnection *)x0 x1:(NSString *)x1;
+ (NSArray<NSArray<NSString *> *> *)NSSQLiteConnection_fetchTableCreationSQLContaining_:(NSSQLiteConnection *)x0 x1:(NSString *)x1;

+ (NSSQLiteStatement *)NSSQLiteAdapter_newCreateTableStatementForEntity_:(NSSQLiteAdapter *)x0 x1:(NSSQLEntity *)x1 NS_RETURNS_RETAINED;
+ (NSSQLiteStatement *)NSSQLiteAdapter_newCreateTableStatementForManyToMany_:(NSSQLiteAdapter *)x0 x1:(NSRelationshipDescription *)x1 NS_RETURNS_RETAINED;
+ (NSSQLiteStatement *)NSSQLiteAdapter_newPrimaryKeyInitializeStatementForEntity_withInitialMaxPK_:(NSSQLiteAdapter *)x0 x1:(NSSQLEntity *)x1 x2:(uint)x2 NS_RETURNS_RETAINED;
+ (NSSQLiteStatement *)NSSQLiteAdapter_newSimplePrimaryKeyUpdateStatementForEntity_:(NSSQLiteAdapter *)x0 x1:(NSSQLEntity *)x1 NS_RETURNS_RETAINED;
+ (NSSQLiteStatement *)NSSQLiteAdapter_newDropTableStatementForTableNamed_:(NSSQLiteAdapter *)x0 x1:(NSString *)x1 NS_RETURNS_RETAINED;
+ (NSArray<NSSQLiteStatement *> *)NSSQLiteAdapter_newCreateIndexStatementsForEntity_defaultIndicesOnly_:(NSSQLiteAdapter *)x0 x1:(NSSQLEntity *)x1 x2:(BOOL)x2 NS_RETURNS_RETAINED;

+ (NSInteger)NSManagedObjectContext__countForFetchRequest__error_:(NSManagedObjectContext *)x0 x1:(NSFetchRequest *)x1 x2:(NSError * _Nullable * _Nullable)x2;

+ (NSSQLEntity * _Nullable)_sqlCoreLookupSQLEntityForEntityID:(NSSQLCore *)x0 x1:(NSUInteger)x1;
+ (NSSQLEntity * _Nullable)_sqlEntityForEntityDescription:(NSEntityDescription *)x0 x1:(NSSQLModel *)x1;

+ (NSNumber *)_PFRoutines__getPFBundleVersionNumber:(Class)x0;
+ (void)_PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:(Class)x0 x1:(NSFetchRequest *)x1 x2:(NSManagedObjectContext *)x2 x3:(void (^ NS_NOESCAPE)(NSArray<__kindof NSManagedObject *> * _Nullable objects, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved))x3;
+ (BOOL)_PFRoutines__isInMemoryStore_:(Class)x0 x1:(NSPersistentStore *)x1;

+ (__kindof PFHistoryAnalyzerContext * _Nullable)PFHistoryAnalyzer_newAnalyzerContextForStore_sinceLastHistoryToken_inManagedObjectContext_error_:(__kindof PFHistoryAnalyzer *)x0 x1:(NSPersistentStore *)x1 x2:(NSPersistentHistoryToken *)x2 x3:(NSManagedObjectContext *)x3 x4:(NSError * _Nullable * _Nullable)x4 NS_RETURNS_RETAINED;

+ (NSString *)_PFModelMapPathForEntity:(NSEntityDescription *)x0;

@end

NS_ASSUME_NONNULL_END
