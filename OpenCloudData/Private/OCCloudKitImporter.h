//
//  OCCloudKitImporter.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import <OpenCloudData/OCCloudKitImporterOptions.h>
#import <OpenCloudData/OCCloudKitMirroringRequest.h>
#import <OpenCloudData/OCCloudKitMirroringResult.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitImporter : NSObject
- (instancetype)initWithOptions:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringRequest *)request;
- (void)importIfNecessaryWithCompletion:(void (^)(OCCloudKitMirroringResult *result))completion __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
