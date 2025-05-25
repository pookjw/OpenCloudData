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
#import "OpenCloudData/Private/OCCloudKitSchemaGenerator.h"
#import "OpenCloudData/SPI/CloudKit/CKRecord+Private.h"
#include <stdlib.h>

@implementation OCCloudKitModelValidator

+ (BOOL)enforceUniqueConstraintChecks {
    // inlined from -[PFCloudKitModelValidator _validateManagedObjectModel:error:] <+856>~<+876>, <+1508>~<+1528>
    
    // __57+[PFCloudKitModelValidator enforceUniqueConstraintChecks]_block_invoke
    static BOOL enforceUniqueConstraintChecks = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([OCSPIResolver z9dsptsiQ80etb9782fsrs98bfdle88]) {
            const char *name = getprogname();
            if (name != NULL) {
                if (strncmp("routined", name, 8) == 0) {
                    enforceUniqueConstraintChecks = YES;
                }
            }
        } else {
            enforceUniqueConstraintChecks = YES;
        }
    });
    return enforceUniqueConstraintChecks;
}

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
    
    BOOL _succeed = YES;
    NSError * _Nullable _error = nil;
    // sp + 0x18
    @autoreleasepool {
        _succeed = [self validateEntities:entities error:&_error];
        [_error retain];
    }
    
    [_error autorelease];
    
    if (!_succeed) {
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
    
    return YES;
}

- (BOOL)validateEntities:(NSArray<NSEntityDescription *> *)entities error:(NSError * _Nullable *)error {
    // inlined from -[PFCloudKitModelValidator _validateManagedObjectModel:error:]
    // self = sp, #0x68
    
    // x19
    NSSet<NSEntityDescription *> *entitiesSet = [[NSSet alloc] initWithArray:entities];
    // sp, #0x10
    NSMutableArray *array_1 = [[NSMutableArray alloc] init];
    // sp, #0xb0
    NSMutableArray<NSString *> *array_2 = [[NSMutableArray alloc] init];
    // x25
    NSMutableArray<NSString *> *array_3 = [[NSMutableArray alloc] init];
    // x28
    NSMutableArray<NSString *> *array_4 = [[NSMutableArray alloc] init];
    // sp, #0xa8
    NSMutableArray<NSString *> *array_5 = [[NSMutableArray alloc] init];
    // sp, #0xa0
    NSMutableArray<NSString *> *array_6 = [[NSMutableArray alloc] init];
    // x20
    NSMutableArray<NSString *> *array_7 = [[NSMutableArray alloc] init];
    // x21
    NSMutableArray<NSString *> *array_8 = [[NSMutableArray alloc] init];
    // sp, #0xe0
    NSMutableArray<NSString *> *array_9 = [[NSMutableArray alloc] init];
    // sp, #0x30
    NSMutableArray<NSString *> *array_10 = [[NSMutableArray alloc] init];
    // x23
    NSMutableArray<NSString *> *array_11 = [[NSMutableArray alloc] init];
    // sp, #0xb8
    NSMutableArray<NSString *> *array_12 = [[NSMutableArray alloc] init];
    // sp, #0x78
    NSMutableArray<NSString *> *array_13 = [[NSMutableArray alloc] init];
    // sp, #0x88
    NSMutableArray<NSString *> *array_14 = [[NSMutableArray alloc] init];
    // sp, #0x38
    NSMutableArray<NSString *> *array_15 = [[NSMutableArray alloc] init];
    // sp, #0x90
    NSMutableArray<NSString *> *array_16 = [[NSMutableArray alloc] init];
    // sp, #0x70
    NSMutableArray<NSString *> *array_17 = [[NSMutableArray alloc] init];
    // sp, #0x28
    NSMutableArray<NSString *> *array_18 = [[NSMutableArray alloc] init];
    
    /*
     NSPersistentHistoryTombstoneAttributes = sp + 0x40
     NSPersistentCloudKitContainerEncryptedAttributeKey = x22
     @"%@:%@ - preservesValueInHistoryOnDeletion should be YES" = x26
     entities = sp, #0xc8
     array_8 = x19
     array_7 = sp, #0x80
     array_8 = sp, #0x98
     array_11 = sp, #0xd0
     array_4 = sp, #0x58
     array_3 = sp, #0x60
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
         array_3 = sp + 0x420 = x20 + 0x20
         entity = sp + 0x428 = x20 + 0x28
         array_4 = sp + 0x430 = x20 + 0x30
         array_5 = sp + 0x438 = x20 + 0x38
         entities = sp + 0x440 = x20 + 0x40
         array_8 = sp + 0x448 = x20 + 0x48
         array_13 = sp + 0x450 = x20 + 0x50
         array_14 = sp + 0x458 = x20 + 0x58
         array_17 = sp + 0x460 = x20 + 0x60
         */
        [entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, NSRelationshipDescription * _Nonnull relationship, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             name = x21
             relationship = x19
             */
            // <+40>
            if (!relationship.optional) {
                [array_3 addObject:[NSString stringWithFormat:@"%@: %@", entity.name, name]];
            }
            
            // <+100>
            if (relationship.inverseRelationship == nil) {
                [array_4 addObject:[NSString stringWithFormat:@"%@: %@", entity.name, name]];
            }
            
            // <+156>
            if (relationship.ordered) {
                [array_5 addObject:[NSString stringWithFormat:@"%@: %@", entity.name, name]];
            }
            
            // <+216>
            if (relationship.destinationEntity != nil) {
                if (![entities containsObject:relationship.destinationEntity]) {
                    [array_8 addObject:[NSString stringWithFormat:@"%@: %@ - %@", entity.name, name, relationship.destinationEntity.name]];
                }
            }
            
            // <+324>
            if ([[relationship.userInfo objectForKey:[OCSPIResolver NSCloudKitMirroringDelegateIgnoredPropertyKey]] boolValue]) {
                [array_13 addObject:[NSString stringWithFormat:@"%@:%@", entity.name, relationship.name]];
            }
            
            // <+416>
            if ([relationship.userInfo objectForKey:[OCSPIResolver NSPersistentCloudKitContainerEncryptedAttributeKey]] != nil) {
                [array_14 addObject:[NSString stringWithFormat:@"%@:%@", entity.name, relationship.name]];
            }
            
            // <+504>
            if (relationship.deleteRule == NSDenyDeleteRule) {
                [array_17 addObject:[NSString stringWithFormat:@"%@:%@ - %@", entity.name, relationship.name, @"Deny"]];
            }
        }];
        
        // <+844>
        if (![OCCloudKitModelValidator enforceUniqueConstraintChecks]) {
            if (entity.uniquenessConstraints.count != 0) {
                /*
                 __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_3
                 entity = sp + 0x3f0 = x20 + 0x20
                 array_18 = sp + 0x3f8 = x20 + 0x28
                 */
                [entity.uniquenessConstraints enumerateObjectsUsingBlock:^(NSArray<id> * _Nonnull uniqueAttributes, NSUInteger idx, BOOL * _Nonnull stop) {
                    /*
                     self(block) = x20
                     uniqueNames = x19
                     */
                    
                    // sp + 0x18
                    NSMutableString *string = [[NSMutableString alloc] init];
                    /*
                     __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_4
                     entity = sp + 0x40 = x19 + 0x20
                     string = sp + 0x50 = x19 + 0x28
                     */
                    [uniqueAttributes enumerateObjectsUsingBlock:^(NSObject * _Nonnull attribute, NSUInteger idx, BOOL * _Nonnull stop) {
                        /*
                         self(block) = x19
                         attribute = x20
                         */
                        if ([attribute isNSString__]) {
                            // <+96>
                            if (string.length != 0) {
                                [string appendString:@", "];
                            }
                            [string appendString:(NSString *)attribute];
                        } else if ([attribute isKindOfClass:[NSAttributeDescription class]]) {
                            // <+84>
                            if (string.length != 0) {
                                [string appendString:@", "];
                            }
                            [string appendString:((NSAttributeDescription *)attribute).name];
                        } else {
                            // <+180>
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: PFCloudKitModelValidator was handed an entity with unique constraints that aren't attributes or strings: %@ - %@\n", entity.name, entity.uniquenessConstraints);
                            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: PFCloudKitModelValidator was handed an entity with unique constraints that aren't attributes or strings: %@ - %@\n", entity.name, entity.uniquenessConstraints);
                        }
                    }];
                    
                    [array_18 addObject:[NSString stringWithFormat:@"%@: %@", entity.name, string]];
                    [string release];
                }];
            }
        }
        
        // <+968>
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke.58
         */
        static NSArray<NSString *> *attributeNames;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            @autoreleasepool {
                attributeNames = [@[
                    [OCSPIResolver NSCKRecordIDAttributeName],
                    [OCSPIResolver NSCKRecordSystemFieldsAttributeName]
                ] retain];
            }
        });
        
        // <+984>
        NSString *tombstoneAttributes = [entity.userInfo objectForKey:[OCSPIResolver NSPersistentHistoryTombstoneAttributes]];
        NSArray<NSString *> *tombstoneAttributesArray = [tombstoneAttributes componentsSeparatedByString:@","];
        if (tombstoneAttributesArray != nil) {
            // tombstoneAttributesArray = x23
            if (tombstoneAttributesArray.count != 0) {
                [array_8 addObjectsFromArray:tombstoneAttributesArray];
            }
            
            // x23
            for (NSString *name in attributeNames) {
                // 이때 set_2는 무조건 비어 있기에 continue가 불림
                if (![set_2 containsObject:name]) continue;
                if (![set_1 containsObject:name]) continue;
                NSString *string = [[NSString alloc] initWithFormat:@"%@:%@ - preservesValueInHistoryOnDeletion should be YES", entity.name, name];
                [array_9 addObject:string];
                [string release];
            }
        }
        
        [set_1 release];
        [set_2 release];
        
        // <+1276>
        // original : getCloudKitCKRecordZoneIDClass, getCloudKitCKCurrentUserDefaultName
        // x21
        CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:@"com.apple.coredata.cloudkit.zone" ownerName:CKCurrentUserDefaultName];
        // x24
        CKRecord *record = [OCCloudKitSchemaGenerator newRepresentativeRecordForStaticFieldsInEntity:entity inZoneWithID:zoneID];
        if (record.size > 700000UL) {
            NSString *string = [[NSString alloc] initWithFormat:@"%@: Estimated size %lu bytes", entity.name, record.size];
            [array_10 addObject:string];
            [string release];
        }
        [record release];
        [zoneID release];
    }
    
    /*
     array_4 = x28
     array_3 = x25
     array_11 = x23
     array_7 = x20
     array_8 = x19
     */
    
    // <+1584>
    // x27
    NSMutableArray<NSString *> *array_19 = [[NSMutableArray alloc] init];
    
    if (array_4.count != 0) {
        [array_4 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithString:@"CloudKit integration requires that all relationships have an inverse, the following do not:"];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_2.74
         string = sp + 0x388 = x20 + 0x20
         */
        [array_4 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+1736>
    // array_5 = x21
    if (array_5.count != 0) {
        [array_5 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithString:@"CloudKit integration does not support ordered relationships. The following relationships are marked ordered:"];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_3.80
         string = sp + 0x360
         */
        [array_5 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+1856>
    if (array_2.count != 0) {
        [array_2 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithString:@"CloudKit integration requires that all attributes be optional, or have a default value set. The following attributes are marked non-optional but do not have a default value:"];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_4.83
         string = sp + 0x338
         */
        [array_2 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+1984>
    // array_6 = x21
    if (array_3.count != 0) {
        [array_3 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithString: @"CloudKit integration requires that all relationships be optional, the following are not:"];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_4.83
         string = sp + 0x310
         */
        [array_3 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+2112>
    if (array_6.count != 0) {
        [array_6 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithString: @"CloudKit integration does not support all attribute types. The following entities have attributes of an unsupported type:"];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_6
         string = sp + 0x2e8
         */
        [array_6 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+2228>
    if (array_7.count != 0) {
        [array_7 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"CloudKit integration requires that the value transformers for transformable attributes are available via +[%@ %@] and allow reverse transformation:", NSStringFromClass([NSValueTransformer class]), NSStringFromSelector(@selector(valueTransformerForName:))];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_7
         string = sp, #0x2c0
         */
        [array_7 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+2388>
    // array_8 = x20
    // array_14 = x21
    if (array_8.count != 0) {
        [array_8 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithString:@"CloudKit integration does not allow relationships to objects that aren't sync'd. The following relationships have destination entities that not in the specified configuration."];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_8
         string = sp, #0x298
         */
        [array_8 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+2512>
    // array_9 = x20
    if (array_9.count != 0) {
        [array_9 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"CloudKit integration requires that all entities tombstone %@ and %@ on delete if configured. The following entities are not properly configured:", [OCSPIResolver NSCKRecordIDAttributeName], [OCSPIResolver NSCKRecordSystemFieldsAttributeName]];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_9
         string = sp, #0x270
         */
        [array_9 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+2660>
    // array_10 = x20
    if (array_10.count != 0) {
        [array_10 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"CloudKit integration requires that all entities can be materialized in a CKRecord of less than %lu bytes. The following entities cannot:", 700000UL];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_10
         string = sp, #0x248
         */
        [array_10 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+2792>
    // array_11 = x26
    if (array_11.count != 0) {
        [array_11 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"The following attributes have invalid values for '%@':", [OCSPIResolver NSCloudKitMirroringDelegateIgnoredPropertyKey]];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_11
         string = sp, #0x220
         */
        [array_11 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+2936>
    // array_13 = x26
    if (array_13.count != 0) {
        [array_13 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithFormat: @"CloudKit integration does not support ignored relationships. The following entities and relationships are marked ignored using '%@':", [OCSPIResolver NSCloudKitMirroringDelegateIgnoredPropertyKey]];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_12
         string = sp, #0x1f8
         */
        [array_13 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+3068>
    // array_15 = x20
    if (array_15.count != 0) {
        [array_15 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithFormat: @"The following entities have invalid values:"];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_13
         string = sp, #0x1d0
         */
        [array_15 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+3192>
    // array_12 = x19
    if (array_12.count != 0) {
        [array_12 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithFormat: @"The following attributes have invalid values:"];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_14
         string = sp, #0x1d0
         */
        [array_12 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+3324>
    if (array_14.count != 0) {
        [array_14 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"CloudKit integration does not support encrypted relationships. The following entities and relationships are marked with '%@':", [OCSPIResolver NSPersistentCloudKitContainerEncryptedAttributeKey]];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_15
         string = sp, #0x180
         */
        [array_14 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+3464>
    // array_19 = x22
    // array_16 = x27
    if (array_16.count != 0) {
        [array_16 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"The following attributes use mergeable storage with CloudKit which is unsupported:"];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_16
         string = sp, #0x158
         */
        [array_14 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+3600>
    // array_17 = x27
    if (array_17.count != 0) {
        [array_17 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"The following relationships are configured with unsupported delete rules:"];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_17
         string = sp, #0x158
         */
        [array_17 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+3732>
    // array_18 = x21
    if (array_18.count != 0) {
        [array_18 sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        // x19
        NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"CloudKit integration does not support unique constraints. The following entities are constrained:"];
        
        /*
         __51-[PFCloudKitModelValidator validateEntities:error:]_block_invoke_18
         string = sp, #0x158
         */
        [array_18 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*
             self(block) = x20
             obj = x19
             */
            [string appendString:@"\n"];
            [string appendString:obj];
        }];
        
        [array_19 addObject:string];
        [string release];
    }
    
    // <+3864>
    // array_1은 안 쓰이는듯?
    [array_1 release];
    [array_2 release];
    [array_3 release];
    [array_4 release];
    [array_5 release];
    [array_6 release];
    [array_7 release];
    [array_8 release];
    [array_9 release];
    [array_10 release];
    [array_11 release];
    [array_14 release];
    [array_13 release];
    [array_12 release];
    [array_15 release];
    [array_16 release];
    [array_17 release];
    [array_18 release];
    
    // array_19 = x24
    if (array_19.count != 0) {
        // error = x22
        NSString *string;
        if (array_19.count < 2) {
            // <+4388>
            string = array_19.lastObject;
        } else {
            // <+4020>
            string = [array_19 componentsJoinedByString:@"\n"];
        }
        
        NSError *_error = [NSError errorWithDomain:NSCocoaErrorDomain code:134060 userInfo:@{NSLocalizedFailureReasonErrorKey: string}];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        
        [array_19 release];
        [entitiesSet release];
        return NO;
    }
    
    // <+4368>
    [array_19 release];
    [entitiesSet release];
    return YES;
}

@end
