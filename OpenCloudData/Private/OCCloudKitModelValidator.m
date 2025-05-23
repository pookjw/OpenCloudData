//
//  OCCloudKitModelValidator.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/23/25.
//

#import "OpenCloudData/Private/OCCloudKitModelValidator.h"

@implementation OCCloudKitModelValidator

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel configuration:(NSString *)configuration mirroringDelegateOptions:(OCCloudKitMirroringDelegateOptions *)delegateOptions {
    /*
     managedObjectModel = x22
     configuration = x20
     delegateOptions = x19
     */
    if (self = [super init]) {
        // self = x20
        _model = [managedObjectModel retain];
        _configurationName = [configuration retain];
        _options = [delegateOptions retain];
    }
    
    return self;
}

- (void)dealloc {
    [_model release];
    _model = nil;
    
    [_configurationName release];
    _configurationName = nil;
    
    [_options release];
    _options = nil;
    
    [super dealloc];
}

- (BOOL)_validateManagedObjectModel:(NSManagedObjectModel *)managedObjectModel error:(NSError * _Nullable *)error {
    abort();
}

@end
