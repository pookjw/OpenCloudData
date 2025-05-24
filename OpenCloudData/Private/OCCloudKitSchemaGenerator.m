//
//  OCCloudKitSchemaGenerator.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/7/25.
//

#import "OpenCloudData/Private/OCCloudKitSchemaGenerator.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#include <objc/runtime.h>

@implementation OCCloudKitSchemaGenerator

+ (id)representativeValueFor:(id)value {
    abort();
}

+ (CKRecord *)newRepresentativeRecordForStaticFieldsInEntity:(NSEntityDescription *)entity inZoneWithID:(CKRecordZoneID *)zoneID {
    // TODO
    return [OCSPIResolver PFCloudKitSchemaGenerator_newRepresentativeRecordForStaticFieldsInEntity_inZoneWithID_:objc_lookUpClass("PFCloudKitSchemaGenerator") x1:entity x2:zoneID];
}

@end
