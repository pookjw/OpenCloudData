//
//  _OCDirectMethodResolver.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/8/25.
//

#import "OpenCloudData/Private/Analyzer/OCCloudKitHistoryAnalyzerOptions.h"
#import "OpenCloudData/Private/OCCloudKitSerializer.h"
#import "OpenCloudData/Private/MirroredRelationship/OCMirroredOneToManyRelationship.h"

NS_ASSUME_NONNULL_BEGIN

@interface _OCDirectMethodResolver : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (void)OCCloudKitHistoryAnalyzerOptions:(OCCloudKitHistoryAnalyzerOptions *)x0 setIncludePrivateTransactions:(BOOL)x1;
+ (BOOL)OCCloudKitHistoryAnalyzerOptions_includePrivateTransactions:(OCCloudKitHistoryAnalyzerOptions *)x0;
+ (void)OCCloudKitHistoryAnalyzerOptions:(OCCloudKitHistoryAnalyzerOptions *)x0 setRequest:(OCCloudKitMirroringRequest * _Nullable)x1;
+ (OCCloudKitMirroringRequest *)OCCloudKitHistoryAnalyzerOptions_request:(OCCloudKitHistoryAnalyzerOptions *)x0;

+ (NSString *)OCCloudKitSerializer:(Class)x0 mtmKeyForObjectWithRecordName:(NSString *)x1 relatedToObjectWithRecordName:(NSString *)x2 byRelationship:(NSRelationshipDescription *)x3 withInverse:(NSRelationshipDescription *)x4;
+ (size_t)OCCloudKitSerializer:(Class)x0 estimateByteSizeOfRecordID:(CKRecordID *)x1;
+ (CKRecordType)OCCloudKitSerializer:(Class)x0 recordTypeForEntity:(NSEntityDescription *)x1;
+ (BOOL)OCCloudKitSerializer:(Class)x0 isMirroredRelationshipRecordType:(CKRecordType)x1;
+ (NSSet<NSManagedObjectID *> *)OCCloudKitSerializer:(Class)x0 createSetOfObjectIDsRelatedToObject:(NSManagedObject *)x1 NS_RETURNS_RETAINED;
+ (NSURL *)OCCloudKitSerializer:(Class)x0 generateCKAssetFileURLForObjectInStore:(NSPersistentStore *)x1;
+ (NSURL *)OCCloudKitSerializer:(Class)x0 assetStorageDirectoryURLForStore:(NSPersistentStore *)x1;
+ (NSDictionary<NSString *, id> *)OCMirroredOneToManyRelationship_recordTypesToRecordIDs:(OCMirroredOneToManyRelationship *)x0;
+ (CKRecordType)OCMirroredManyToManyRelationship:(Class)x0 ckRecordTypeForOrderedRelationships:(NSArray<NSRelationshipDescription *> *)orderedRelationships;
+ (CKRecordType)OCMirroredManyToManyRelationship:(Class)x0 ckRecordNameForOrderedRecordNames:(NSArray<NSString *> *)orderedRecordNames;
@end

NS_ASSUME_NONNULL_END
