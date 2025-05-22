//
//  OCPersistentCloudKitContainerOptions.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCPersistentCloudKitContainerOptions : NSObject
@property (copy, readonly) NSString *containerIdentifier;
@property(nonatomic) CKDatabaseScope databaseScope;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithContainerIdentifier:(NSString *)containerIdentifier NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
