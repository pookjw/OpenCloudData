//
//  OCCKEvent.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <CoreData/CoreData.h>
#import "OpenCloudData/Public/OCPersistentCloudKitContainerEvent.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequest.h"
#import "OpenCloudData/Private/OCCloudKitStoreMonitor.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCKEvent : NSManagedObject
@property (class, nonatomic, readonly) NSString *entityPath;
@property (retain, nonatomic, nullable) NSUUID *eventIdentifier;
@property (nonatomic) int64_t cloudKitEventType;
@property (retain, nonatomic, nullable) NSDate *startedAt;
@property (retain, nonatomic, nullable) NSDate *endedAt;
@property (nonatomic) BOOL succeeded;
@property (retain, nonatomic, nullable) NSString *errorDomain;
@property (nonatomic) int64_t errorCode;
@property (nonatomic) int64_t countAffectedObjects;
@property (nonatomic) int64_t countFinishedObjects;
+ (OCPersistentCloudKitContainerEvent * _Nullable)beginEventForRequest:(OCCloudKitMirroringRequest *)request withMonitor:(OCCloudKitStoreMonitor *)monitor error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) NS_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
