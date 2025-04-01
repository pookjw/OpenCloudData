//
//  OCCloudKitMirroringInitializeSchemaRequest.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <OpenCloudData/OCCloudKitMirroringRequest.h>
#import <OpenCloudData/OCPersistentCloudKitContainer.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringInitializeSchemaRequest : OCCloudKitMirroringRequest
@property (nonatomic) OCPersistentCloudKitContainerSchemaInitializationOptions schemaInitializationOptions;
@end

NS_ASSUME_NONNULL_END
