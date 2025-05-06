//
//  OCCloudKitSerializer.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/12/25.
//

#import <OpenCloudData/OCCloudKitSerializer.h>
#import <OpenCloudData/OCSPIResolver.h>

@implementation OCCloudKitSerializer

+ (BOOL)shouldTrackProperty:(NSPropertyDescription *)property {
    if (property.isTransient) return NO;
    
    BOOL boolValue = ((NSNumber *)[property.userInfo objectForKey:[OCSPIResolver NSCloudKitMirroringDelegateIgnoredPropertyKey]]).boolValue;
    if (boolValue) return NO;
    
    return YES;
}

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
