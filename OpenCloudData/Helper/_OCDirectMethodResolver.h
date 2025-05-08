//
//  _OCDirectMethodResolver.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/8/25.
//

#import <OpenCloudData/OCCloudKitHistoryAnalyzerOptions.h>
#import <OpenCloudData/OCCloudKitSerializer.h>

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
+ (NSSet<NSManagedObjectID *> *)OCCloudKitSerializer:(Class)x0 createSetOfObjectIDsRelatedToObject:(NSManagedObject *)x1;
@end

NS_ASSUME_NONNULL_END
