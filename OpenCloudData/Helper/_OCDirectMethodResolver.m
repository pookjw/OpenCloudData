//
//  _OCDirectMethodResolver.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/8/25.
//

#import <OpenCloudData/_OCDirectMethodResolver.h>

@implementation _OCDirectMethodResolver

+ (void)OCCloudKitHistoryAnalyzerOptions:(OCCloudKitHistoryAnalyzerOptions *)x0 setIncludePrivateTransactions:(BOOL)x1 {
    x0.includePrivateTransactions = x1;
}

+ (BOOL)OCCloudKitHistoryAnalyzerOptions_includePrivateTransactions:(OCCloudKitHistoryAnalyzerOptions *)x0 {
    return x0.includePrivateTransactions;
}

+ (void)OCCloudKitHistoryAnalyzerOptions:(OCCloudKitHistoryAnalyzerOptions *)x0 setRequest:(OCCloudKitMirroringRequest *)x1 {
    x0.request = x1;
}

+ (OCCloudKitMirroringRequest *)OCCloudKitHistoryAnalyzerOptions_request:(OCCloudKitHistoryAnalyzerOptions *)x0 {
    return x0.request;
}

+ (NSString *)OCCloudKitSerializer:(Class)x0 mtmKeyForObjectWithRecordName:(NSString *)x1 relatedToObjectWithRecordName:(NSString *)x2 byRelationship:(NSRelationshipDescription *)x3 withInverse:(NSRelationshipDescription *)x4 {
    assert(x0 == [OCCloudKitSerializer class]);
    return [OCCloudKitSerializer mtmKeyForObjectWithRecordName:x1 relatedToObjectWithRecordName:x2 byRelationship:x3 withInverse:x4];
}

+ (size_t)OCCloudKitSerializer:(Class)x0 estimateByteSizeOfRecordID:(CKRecordID *)x1 {
    assert(x0 == [OCCloudKitSerializer class]);
    return [OCCloudKitSerializer estimateByteSizeOfRecordID:x1];
}

+ (CKRecordType)OCCloudKitSerializer:(Class)x0 recordTypeForEntity:(NSEntityDescription *)x1 {
    assert(x0 == [OCCloudKitSerializer class]);
    return [OCCloudKitSerializer recordTypeForEntity:x1];
}

+ (BOOL)OCCloudKitSerializer:(Class)x0 isMirroredRelationshipRecordType:(CKRecordType)x1 {
    assert(x0 == [OCCloudKitSerializer class]);
    return [OCCloudKitSerializer isMirroredRelationshipRecordType:x1];
}

+ (NSSet<NSManagedObjectID *> *)OCCloudKitSerializer:(Class)x0 createSetOfObjectIDsRelatedToObject:(NSManagedObject *)x1 {
    assert(x0 == [OCCloudKitSerializer class]);
    return [OCCloudKitSerializer createSetOfObjectIDsRelatedToObject:x1];
}

+ (NSURL *)OCCloudKitSerializer:(Class)x0 generateCKAssetFileURLForObjectInStore:(NSPersistentStore *)x1 {
    assert(x0 == [OCCloudKitSerializer class]);
    return [OCCloudKitSerializer generateCKAssetFileURLForObjectInStore:x1];
}
+ (NSURL *)OCCloudKitSerializer:(Class)x0 assetStorageDirectoryURLForStore:(NSPersistentStore *)x1 {
    assert(x0 == [OCCloudKitSerializer class]);
    return [OCCloudKitSerializer assetStorageDirectoryURLForStore:x1];
}

@end
