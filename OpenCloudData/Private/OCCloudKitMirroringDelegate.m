//
//  OCCloudKitMirroringDelegate.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <OpenCloudData/OCCloudKitMirroringDelegate.h>

@implementation OCCloudKitMirroringDelegate

+ (NSValueTransformerName)cloudKitMetadataTransformerName {
    // original : com.apple.CoreData.cloudkit.metadata.transformer
#warning TODO : NSCloudKitMirroringDelegate과 호환성을 가지려면 original을 써야 할 수도 있음
    return @"com.pookjw.OpenCloudData.cloudkit.metadata.transformer";
}

- (void)dealloc {
    [_options release];
    [_currentUserRecordID release];
    [super dealloc];
}

@end
