//
//  OCCloudKitMirroringDelegateOptions.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <OpenCloudData/OCCloudKitMirroringDelegateOptions.h>

#warning TODO
// ivar 직접 정의해야 하는 것들이 있음

@implementation OCCloudKitMirroringDelegateOptions

- (instancetype)init {
    abort();
}

- (instancetype)initWithContainerIdentifier:(NSString *)containerIdentifier {
    abort();
}

- (instancetype)initWithCloudKitContainerOptions:(CKContainerOptions *)containerOptions {
    abort();
}

- (void)dealloc {
#warning TODO: ivar 정의 안한거 있고 _archivingUtilities는 안 살펴봄
    [_defaultOperationConfiguration release];
    [_containerIdentifier release];
    [_ckAssetThresholdBytes release];
    [_containerOptions release];
    [_operationMemoryThresholdBytes release];
    [_apsConnectionMachServiceName release];
    [_activityVouchers release];
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    abort();
}

- (void)setActivityVouchers:(NSArray<OCPersistentCloudKitContainerActivityVoucher *> *)activityVouchers {
    abort();
}

@end
