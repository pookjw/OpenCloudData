//
//  OCCloudKitMetadataModel.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <OpenCloudData/OCCloudKitMetadataModel.h>

NSString * const OCCKRecordIDAttributeName = @"ckRecordID";

@implementation OCCloudKitMetadataModel

+ (NSUInteger)ancillaryEntityCount {
    return 14;
}

+ (NSUInteger)ancillaryEntityOffset {
    return 17000;
}

+ (NSString *)ancillaryModelNamespace {
    return @"CloudKit";
}

@end
