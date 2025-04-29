//
//  OCCloudKitMetadataValueTransformer.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <OpenCloudData/OCCloudKitMetadataValueTransformer.h>

@implementation OCCloudKitMetadataValueTransformer

+ (NSArray<Class> *)allowedTopLevelClasses {
    NSMutableArray<Class> *result = [[NSMutableArray alloc] initWithArray:[super allowedTopLevelClasses]];
    
    NSArray<Class> *toBeAddedClasses = @[
        [CKRecord class], // original : getCloudKitCKRecordClass
        [CKShare class], // original : getCloudKitCKShareClass
        [CKRecordID class], // original : getCloudKitCKRecordIDClass
        [CKRecordZoneID class], // original : getCloudKitCKRecordZoneIDClass
        [CKServerChangeToken class], // original : getCloudKitCKServerChangeTokenClass
        [CKNotificationInfo class], // original : getCloudKitCKNotificationInfoClass
        [NSPersistentHistoryToken class]
    ];
    
    for (Class _class in toBeAddedClasses) {
        [result addObject:_class];
    }
    
    return [result autorelease];
}

@end
