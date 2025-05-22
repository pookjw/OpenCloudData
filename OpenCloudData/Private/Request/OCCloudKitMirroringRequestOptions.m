//
//  OCCloudKitMirroringRequestOptions.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequestOptions.h"

@implementation OCCloudKitMirroringRequestOptions

- (instancetype)init {
    if (self = [super init]) {
        _operationConfiguration = [self createDefaultOperationConfiguration];
    }
    
    return self;
}

- (void)dealloc {
    [_operationConfiguration release];
    [_vouchers release];
    [super dealloc];
}

- (CKOperationConfiguration *)createDefaultOperationConfiguration {
    // original : _initCloudKitCKOperationConfiguration, _getCloudKitCKOperationConfigurationClass
    CKOperationConfiguration *operationConfiguration = [[CKOperationConfiguration alloc] init];
    operationConfiguration.qualityOfService = NSQualityOfServiceUtility;
    return operationConfiguration;
}

- (id)copy {
    __kindof OCCloudKitMirroringRequestOptions *copy = [[[self class] alloc] init];
    
    if (copy) {
        copy.operationConfiguration = _operationConfiguration;
        copy->_vouchers = [_vouchers retain];
    }
    
    return copy;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [self copy];
}

- (void)setOperationConfiguration:(CKOperationConfiguration *)operationConfiguration {
    CKOperationConfiguration *oldOperationConfiguration = _operationConfiguration;
    if (oldOperationConfiguration == operationConfiguration) return;
    
    [oldOperationConfiguration release];
    _operationConfiguration = operationConfiguration;
    
    if (operationConfiguration == nil) {
        [operationConfiguration retain];
    }
}

- (void)applyToOperation:(__kindof CKOperation *)operation {
    CKOperationConfiguration * _Nullable operationConfiguration = (_vouchers.lastObject == nil) ? _operationConfiguration : _vouchers.lastObject.operationConfiguration;
    operation.configuration = operationConfiguration;
}

- (void)setAllowsCellularAccess:(BOOL)allowsCellularAccess {
    _operationConfiguration.allowsCellularAccess = allowsCellularAccess;
}

- (BOOL)allowsCellularAccess {
    return _operationConfiguration.allowsCellularAccess;
}

- (NSQualityOfService)qualityOfService {
    return _operationConfiguration.qualityOfService;
}

- (void)setQualityOfService:(NSQualityOfService)qualityOfService {
    // NOP
}

@end
