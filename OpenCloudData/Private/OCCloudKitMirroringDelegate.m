//
//  OCCloudKitMirroringDelegate.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <OpenCloudData/OCCloudKitMirroringDelegate.h>

@implementation OCCloudKitMirroringDelegate

- (void)dealloc {
    [_options release];
    [_currentUserRecordID release];
    [super dealloc];
}

@end
