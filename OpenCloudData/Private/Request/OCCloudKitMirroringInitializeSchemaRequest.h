//
//  OCCloudKitMirroringInitializeSchemaRequest.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequest.h"
#import "OpenCloudData/Public/OCPersistentCloudKitContainer.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringInitializeSchemaRequest : OCCloudKitMirroringRequest {
    OCPersistentCloudKitContainerSchemaInitializationOptions _schemaInitializationOptions; // 0x50
}
@property (assign, nonatomic) OCPersistentCloudKitContainerSchemaInitializationOptions schemaInitializationOptions;
@end

NS_ASSUME_NONNULL_END
