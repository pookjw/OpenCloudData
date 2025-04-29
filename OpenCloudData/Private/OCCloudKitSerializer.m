//
//  OCCloudKitSerializer.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/12/25.
//

#import <OpenCloudData/OCCloudKitSerializer.h>

@implementation OCCloudKitSerializer

+ (size_t)estimateByteSizeOfRecordID:(CKRecordID *)recordID {
    abort();
}

+ (CKRecordType)recordTypeForEntity:(NSEntityDescription *)entity {
    abort();
}

+ (BOOL)isMirroredRelationshipRecordType:(CKRecordType)recordType {
    abort();
}

- (NSArray<CKRecord *> *)newCKRecordsFromObject:(NSManagedObject *)object fullyMaterializeRecords:(BOOL)fullyMaterializeRecords includeRelationships:(BOOL)includeRelationships error:(NSError * _Nullable *)error {
    abort();
}

+ (NSSet<NSManagedObjectID *> *)createSetOfObjectIDsRelatedToObject:(NSManagedObject *)object {
    abort();
}

@end
