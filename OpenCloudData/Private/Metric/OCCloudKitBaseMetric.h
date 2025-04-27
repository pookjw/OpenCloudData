//
//  OCCloudKitBaseMetric.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitBaseMetric : NSObject {
    NSString *_containerIdentifier; // 0x8
    NSString *_processName; // 0x10
}
@property (retain, nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSDictionary<NSString *, id> *payload;
- (instancetype)initWithContainerIdentifier:(NSString *)containerIdentifier;
@end

NS_ASSUME_NONNULL_END
