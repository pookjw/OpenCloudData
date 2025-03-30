//
//  OCCKEvent.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <CoreData/CoreData.h>

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
@end

NS_ASSUME_NONNULL_END
