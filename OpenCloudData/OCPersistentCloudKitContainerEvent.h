//
//  OCPersistentCloudKitContainerEvent.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <Foundation/Foundation.h>
#import <OpenCloudData/OpenCloudDataDefines.h>

NS_ASSUME_NONNULL_BEGIN

OC_EXTERN NSNotificationName const OCPersistentCloudKitContainerEventChangedNotification NS_SWIFT_NAME(OCPersistentCloudKitContainer.eventChangedNotification);
OC_EXTERN NSString * const OCPersistentCloudKitContainerEventUserInfoKey NS_SWIFT_NAME(OCPersistentCloudKitContainer.eventNotificationUserInfoKey);

@interface OCPersistentCloudKitContainerEvent : NSObject <NSCopying>
+ (NSString * _Nullable)eventTypeString:(NSInteger)type;
@property (retain, readonly, nonatomic, nullable) NSUUID *identifier; // original : (readonly, nonatomic)
@property (retain, readonly, nonatomic, nullable) NSString *storeIdentifier; // original : (readonly, nonatomic)
@property (readonly, nonatomic) NSInteger type;
@property (retain, readonly, nonatomic, nullable) NSDate *startDate; // original : (readonly, nonatomic)
@property (retain, readonly, nonatomic, nullable) NSDate *endDate; // original : (readonly, nonatomic)
@property (readonly, nonatomic) BOOL succeeded;
@property (retain, readonly, nonatomic, nullable) NSError *error; // original : (readonly, nonatomic)
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
