//
//  OCCloudKitModelValidator.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/23/25.
//

#import "OpenCloudData/Private/OCCloudKitModelValidator.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/Private/OCCloudKitSerializer.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/SPI/CoreData/NSAttributeDescription+Private.h"
#import "OpenCloudData/SPI/Foundation/NSObject+NSKindOfAdditions.h"

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
    // self = sp, #0x68
    
    // sp + 0x18
    @autoreleasepool {
        // x19
        NSSet<NSEntityDescription *> *entitiesSet = [[NSSet alloc] initWithArray:entities];
        // sp, #0x10
        NSMutableArray *array_1 = [[NSMutableArray alloc] init];
        // sp, #0xb0
        NSMutableArray *array_2 = [[NSMutableArray alloc] init];
        // x25
        NSMutableArray *array_3 = [[NSMutableArray alloc] init];
        // x28
        NSMutableArray *array_4 = [[NSMutableArray alloc] init];
        // sp, #0xa8
        NSMutableArray *array_5 = [[NSMutableArray alloc] init];
        // sp, #0xa0
        NSMutableArray<NSString *> *array_6 = [[NSMutableArray alloc] init];
        // x20
        NSMutableArray<NSString *> *array_7 = [[NSMutableArray alloc] init];
        // x21
        NSMutableArray *array_8 = [[NSMutableArray alloc] init];
        // sp, #0xe0
        NSMutableArray *array_9 = [[NSMutableArray alloc] init];
        // sp, #0x30
        NSMutableArray *array_10 = [[NSMutableArray alloc] init];
        // x23
        NSMutableArray<NSString *> *array_11 = [[NSMutableArray alloc] init];
        // sp, #0xb8
        NSMutableArray<NSString *> *array_12 = [[NSMutableArray alloc] init];
        // sp, #0x78
        NSMutableArray *array_13 = [[NSMutableArray alloc] init];
        // sp, #0x88
        NSMutableArray *array_14 = [[NSMutableArray alloc] init];
        // sp, #0x38
        NSMutableArray<NSString *> *array_15 = [[NSMutableArray alloc] init];
        // sp, #0x90
        NSMutableArray *array_16 = [[NSMutableArray alloc] init];
        // sp, #0x70
        NSMutableArray *array_17 = [[NSMutableArray alloc] init];
        // sp, #0x28
        NSMutableArray *array_18 = [[NSMutableArray alloc] init];
        
        /*
         NSPersistentHistoryTombstoneAttributes = sp + 0x50
         NSPersistentCloudKitContainerEncryptedAttributeKey = x22
         @"%@:%@ - preservesValueInHistoryOnDeletion should be YES" = x26
         */
        // <+364>
        // x27
        for (NSEntityDescription *entity in entitiesSet) {
            // x21
            NSMutableSet<NSString *> *set_1 = [[NSMutableSet alloc] init];
            // x24
            NSMutableSet *set_2 = [[NSMutableSet alloc] init];
            
            // <+560>
            if ([entity.userInfo objectForKey:[OCSPIResolver NSPersistentCloudKitContainerEncryptedAttributeKey]] != nil) {
                // <+580>
                [array_15 addObject:[NSString stringWithFormat:@"%@: %@ cannot be applied to an entity type'", entity.name, [OCSPIResolver NSPersistentCloudKitContainerEncryptedAttributeKey]]];
            }
            
            // <+632>
            /*
             __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke
             self = sp + 0x488 = x20 + 0x20
             array_7 = sp + 0x490 = x20 + 0x28
             entity = sp + 0x498 = x20 + 0x30
             array_6 = sp + 0x4a0 = x20 + 0x38
             array_11 = sp + 0x4a8 = x20 + 0x40
             array_12 = sp + 0x4b0 = x20 + 0x48
             set_1 = sp + 0x4b8 = x20 + 0x50
             array_2 = sp + 0x4c0 = x20 + 0x58
             array_16 = sp + 0x4c8 = x20 + 0x60
             */
            [entity.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, NSAttributeDescription * _Nonnull attribute, BOOL * _Nonnull stop) {
                /*
                 self(block) = x20
                 name = x21
                 attribute = x19
                 */
                if (self->_validateLegacyMetadataAttributes) {
                    if ([OCCloudKitSerializer isPrivateAttribute:attribute]) {
                        // <+1240>
                        return;
                    }
                }
                
                NSAttributeType attributeType = attribute.attributeType;
                switch (attributeType) {
                    case NSDecimalAttributeType:
                    case NSDoubleAttributeType:
                    case NSUUIDAttributeType:
                    case NSURIAttributeType:
                    case NSInteger16AttributeType:
                    case NSInteger32AttributeType:
                    case NSInteger64AttributeType:
                    case NSBooleanAttributeType:
                    case NSDateAttributeType:
                    case NSBinaryDataAttributeType:
                    case NSFloatAttributeType:
                    case NSStringAttributeType:
                    case NSCompositeAttributeType:
                        // nop
                        break;
                    case NSTransformableAttributeType: {
                        // <+264>
                        if (attribute.valueTransformerName.length == 0) {
                            break;
                        }
                        
                        if (self->_skipValueTransformerValidation) {
                            break;
                        }
                        
                        NSValueTransformer * _Nullable valueTransformer = [NSValueTransformer valueTransformerForName:attribute.valueTransformerName];
                        if (valueTransformer == nil) {
                            // <+1364>
                            [array_7 addObject:[NSString stringWithFormat:@"%@: %@ - Cannot locate value transformer with name '%@'", entity.name, name, attribute.valueTransformerName]];
                            break;
                        }
                        
                        if (![[valueTransformer class] allowsReverseTransformation]) {
                            [array_7 addObject:[NSString stringWithFormat:@"%@: %@ - Doesn't allow reverse transformation", entity.name, name]];
                            break;
                        }
                        break;
                    }
                    default:
                        // <+368>
                        [array_6 addObject:[NSString stringWithFormat:@"%@: %@ - Unsupported attribute type (%@)", entity.name, name, [NSAttributeDescription stringForAttributeType:attributeType]]];
                        break;
                }
                
                // <+440>
                NSObject * _Nullable ignoredProperty = [attribute.userInfo objectForKey:[OCSPIResolver NSCloudKitMirroringDelegateIgnoredPropertyKey]];
                if (ignoredProperty == nil) {
                    // nop
                } else {
                    BOOL boolValue;
                    if ([ignoredProperty isNSNumber__]) {
                        boolValue = ((NSNumber *)ignoredProperty).boolValue;
                    } else if ([ignoredProperty isNSString__]) {
                        boolValue = ((NSString *)ignoredProperty).boolValue;
                    } else {
                        // <+552>
                        [array_11 addObject:[NSString stringWithFormat:@"%@: %@ - Value must be an instance of '%@' or '%@' that evalutes to YES or NO using '%@'", entity.name, attribute.name, NSStringFromClass([NSNumber class]), NSStringFromClass([NSString class]), NSStringFromSelector(@selector(boolValue))]];
                        boolValue = NO;
                    }
                    
                    if (boolValue) {
                        // <+504>
                        if (!attribute.optional) {
                            [array_11 addObject:[NSString stringWithFormat:@"%@: %@ - attribute is not optional", entity.name, name]];
                        }
                    }
                }
                
                // <+676>
                // x23
                NSObject * _Nullable encryptedAttribute = [attribute.userInfo objectForKey:[OCSPIResolver NSPersistentCloudKitContainerEncryptedAttributeKey]];
                if (encryptedAttribute == nil) {
                    // nop
                    // <+1012>
                } else {
                    if (!([encryptedAttribute isNSNumber__]) && !([encryptedAttribute isNSString__])) {
                        // <+732>
                        [array_12 addObject:[NSString stringWithFormat:@"%@: %@ - Value for %@ must be an instance of '%@' or '%@' that evalutes to YES or NO using '%@'", entity.name, attribute.name, [OCSPIResolver NSPersistentCloudKitContainerEncryptedAttributeKey], NSStringFromClass([NSNumber class]), NSStringFromClass([NSString class]), NSStringFromSelector(@selector(boolValue))]];
                    }
                    
                    // <+856>
                    if (attribute.allowsCloudEncryption) {
                        // <+868>
                        [array_12 addObject:[NSString stringWithFormat:@"%@:%@ - Encryption value should be set via -[NSAttributeDescription allowsCloudEncryption], please remove usage of 'NSPersistentCloudKitContainerEncryptedAttributeKey'", entity.name, attribute.name]];
                    }
                    
                    if (self->_options.useDeviceToDeviceEncryption) {
                        // <+948>
                        [array_12 addObject:[NSString stringWithFormat:@"%@:%@ - Partial encryption cannot be used with device-to-device encryption", entity.name, attribute.name]];
                    }
                }
                
                // <+1012>
                if (self->_options.useDeviceToDeviceEncryption && attribute.allowsCloudEncryption) {
                    [array_12 addObject:[NSString stringWithFormat:@"%@:%@ - Device-to-Device encryption cannot be used with partial encryption", entity.name, attribute.name]];
                }
                
                // <+1104>
                if (attribute.preservesValueInHistoryOnDeletion) {
                    [set_1 addObject:name];
                }
                
                if (!attribute.optional && (attribute.defaultValue == nil)) {
                    // <+1152>
                    [array_2 addObject:[NSString stringWithFormat:@"%@: %@", entity.name, attribute.name]];
                }
                
                if (attribute.usesMergeableStorage) {
                    [array_16 addObject:[NSString stringWithFormat:@"Attributes that use mergeable storage (%@: %@) are unsupported in CloudKit. Please file a radar to Core Data to request support.", entity.name, attribute.name]];
                }
            }];
            
            // <+740>
            /*
             __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_2
             */
            [entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, NSRelationshipDescription * _Nonnull relationship, BOOL * _Nonnull stop) {
                abort();
            }];
            
            // <+844>
            abort();
        }
    }
    abort();
}

@end
