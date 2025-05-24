//
//  OCCloudKitSchemaGenerator.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/7/25.
//

#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitSchemaGenerator : NSObject
+ (id)representativeValueFor:(id)value __attribute__((objc_direct));
+ (CKRecord *)newRepresentativeRecordForStaticFieldsInEntity:(NSEntityDescription *)entity inZoneWithID:(CKRecordZoneID *)zoneID __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
