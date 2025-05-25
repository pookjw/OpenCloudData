//
//  OCPersistentCloudKitContainerActivityVoucher.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCPersistentCloudKitContainerActivityVoucher : NSObject <NSSecureCoding, NSCopying> {
    NSString *_processName; // 0x8
    NSString *_bundleIdentifier; // 0x10
    NSString *_label; // 0x18
    NSInteger _eventType; // 0x20
    NSFetchRequest *_fetchRequest; // 0x28
    CKOperationConfiguration *_operationConfiguration; // 0x30
}
@property (copy, nonatomic, readonly) NSString *processName;
@property (copy, nonatomic, readonly) NSString *bundleIdentifier;
@property (copy, nonatomic, readonly) NSString *label;
@property (assign, nonatomic, readonly) NSInteger eventType;
@property (copy, nonatomic, readonly) NSFetchRequest *fetchRequest;
@property (copy, nonatomic, readonly, nullable) CKOperationConfiguration *operationConfiguration;
+ (NSString *)describeConfiguration:(CKOperationConfiguration * _Nullable)configuration;
+ (NSString *)describeConfigurationWithoutPointer:(CKOperationConfiguration * _Nullable)configuration;
+ (NSString *)stringForQoS:(NSQualityOfService)qualityOfService;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithLabel:(NSString *)label forEventsOfType:(NSInteger)eventType withConfiguration:(CKOperationConfiguration *)configuration affectingObjectsMatching:(NSFetchRequest *)fetchRequest;
@end

NS_ASSUME_NONNULL_END
