//
//  OCCKEvent.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <OpenCloudData/OCCKEvent.h>

@implementation OCCKEvent
@dynamic entityPath;
@dynamic eventIdentifier;
@dynamic cloudKitEventType;
@dynamic startedAt;
@dynamic endedAt;
@dynamic succeeded;
@dynamic errorDomain;
@dynamic errorCode;
@dynamic countAffectedObjects;
@dynamic countFinishedObjects;

+ (NSString *)entityPath {
    return @"CloudKit/NSCKEvent";
}

@end
