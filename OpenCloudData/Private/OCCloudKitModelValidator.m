//
//  OCCloudKitModelValidator.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/23/25.
//

#import "OpenCloudData/Private/OCCloudKitModelValidator.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"

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
    /*
     self = x23
     error = x22
     */
    if (managedObjectModel == nil) {
        NSError *_error = [NSError errorWithDomain:NSCocoaErrorDomain code:134060 userInfo:@{
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Cannot be used without an instance of %@.", NSStringFromClass([NSManagedObjectModel class])]
        }];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        return NO;
    }
    
    // x19
    NSArray<NSEntityDescription *> *entities = [managedObjectModel entitiesForConfiguration:self->_configurationName];
    if (entities == nil) {
        NSError *_error = [NSError errorWithDomain:NSCocoaErrorDomain code:134060 userInfo:@{
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Unable to find a configuration named '%@' in the specified managed object model.", self->_configurationName]
        }];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        return NO;
    }
    
    // <+88>
    if (entities.count == 0) {
        NSError *_error = [NSError errorWithDomain:NSCocoaErrorDomain code:134060 userInfo:@{
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"The configuration named '%@' does not contain any entities.", self->_configurationName]
        }];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        return NO;
    }
    
    // <+100>
    // sp + 0x18
    @autoreleasepool {
        // x19
        NSSet<NSEntityDescription *> *entitiesSet = [[NSSet alloc] initWithArray:entities];
        // sp + 0x10
        NSMutableArray *array_1 = [[NSMutableArray alloc] init];
        // sp + 0xb0
        NSMutableArray *array_2 = [[NSMutableArray alloc] init];
        // x25
        NSMutableArray *array_3 = [[NSMutableArray alloc] init];
        // x28
        NSMutableArray *array_4 = [[NSMutableArray alloc] init];
        // sp + 0xa8
        NSMutableArray *array_5 = [[NSMutableArray alloc] init];
        // sp + 0xa0
        NSMutableArray *array_6 = [[NSMutableArray alloc] init];
        // x20
        NSMutableArray *array_7 = [[NSMutableArray alloc] init];
        // x21
        NSMutableArray *array_8 = [[NSMutableArray alloc] init];
        // sp + 0xe0
        NSMutableArray *array_9 = [[NSMutableArray alloc] init];
        // sp + 0x30
        NSMutableArray *array_10 = [[NSMutableArray alloc] init];
        // x23
        NSMutableArray *array_11 = [[NSMutableArray alloc] init];
        // sp + 0xb8
        NSMutableArray *array_12 = [[NSMutableArray alloc] init];
        // sp + 0x78
        NSMutableArray *array_13 = [[NSMutableArray alloc] init];
        // sp + 0x88
        NSMutableArray *array_14 = [[NSMutableArray alloc] init];
        // sp + 0x38
        NSMutableArray *array_15 = [[NSMutableArray alloc] init];
        // sp + 0x90
        NSMutableArray *array_16 = [[NSMutableArray alloc] init];
        // sp + 0x70
        NSMutableArray *array_17 = [[NSMutableArray alloc] init];
        // sp + 0x28
        NSMutableArray *array_18 = [[NSMutableArray alloc] init];
        
        /*
         NSPersistentHistoryTombstoneAttributes = sp + 0x50
         NSPersistentCloudKitContainerEncryptedAttributeKey = x22
         @"%@:%@ - preservesValueInHistoryOnDeletion should be YES" = x26
         */
        // x27
        for (NSEntityDescription *entity in entitiesSet) {
            // x21
            NSMutableSet *set_1 = [[NSMutableSet alloc] init];
            // x24
            NSMutableSet *set_2 = [[NSMutableSet alloc] init];
            
            // <+560>
            id _Nullable value = [entity.userInfo objectForKey:[OCSPIResolver NSPersistentCloudKitContainerEncryptedAttributeKey]];
            abort();
        }
    }
    abort();
}

@end
