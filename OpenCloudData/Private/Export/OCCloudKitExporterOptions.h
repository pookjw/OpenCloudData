//
//  OCCloudKitExporterOptions.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CoreData/CoreData.h>
#import "OpenCloudData/Private/OCCloudKitMirroringDelegateOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitExporterOptions : NSObject <NSCopying> {
    @package CKDatabase *_database;
    OCCloudKitMirroringDelegateOptions *_options;
    NSUInteger _perOperationBytesThreshold;
    NSUInteger _perOperationObjectThreshold;
}
- (instancetype)initWithDatabase:(CKDatabase *)database options:(OCCloudKitMirroringDelegateOptions *)options;
@end

NS_ASSUME_NONNULL_END
