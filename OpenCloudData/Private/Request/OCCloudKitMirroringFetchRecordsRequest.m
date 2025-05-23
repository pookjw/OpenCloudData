//
//  OCCloudKitMirroringFetchRecordsRequest.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringFetchRecordsRequest.h"
#import "OpenCloudData/Private/Log.h"

@implementation OCCloudKitMirroringFetchRecordsRequest

- (instancetype)initWithOptions:(OCCloudKitMirroringRequestOptions *)options completionBlock:(void (^)(OCCloudKitMirroringResult * _Nonnull))requestCompletionBlock {
    if (self = [super initWithOptions:options completionBlock:requestCompletionBlock]) {
        _objectIDsToFetch = [[NSArray alloc] init];
        _entityNameToAttributeNamesToFetch = [[NSDictionary alloc] init];
        _entityNameToAttributesToFetch = [[NSDictionary alloc] init];
        _editable = YES;
        _perOperationObjectThreshold = 400;
    }
    
    return self;
}

- (void)dealloc {
    [_entityNameToAttributesToFetch release];
    _entityNameToAttributesToFetch = nil;
    
    [_entityNameToAttributeNamesToFetch release];
    _entityNameToAttributeNamesToFetch = nil;
    
    [_objectIDsToFetch release];
    _objectIDsToFetch = nil;
    
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    // x20
    OCCloudKitMirroringFetchRecordsRequest *copy = [super copyWithZone:zone];
    
    copy->_objectIDsToFetch = [_objectIDsToFetch retain];
    copy->_entityNameToAttributesToFetch = [_entityNameToAttributesToFetch retain];
    copy->_entityNameToAttributeNamesToFetch = [_entityNameToAttributeNamesToFetch retain];
    copy->_editable = _editable;
    copy->_perOperationObjectThreshold = _perOperationObjectThreshold;
    
    return copy;
}

- (void)setEntityNameToAttributeNamesToFetch:(NSDictionary<NSString *, NSArray<NSString *> *> *)entityNameToAttributeNamesToFetch {
    if (!_editable) {
        [self throwNotEditable:_cmd];
        return;
    }
    
    NSDictionary<NSString *, NSArray<NSString *> *> *old_entityNameToAttributeNamesToFetch = self->_entityNameToAttributeNamesToFetch;
    if (old_entityNameToAttributeNamesToFetch == entityNameToAttributeNamesToFetch) {
        return;
    }
    
    [old_entityNameToAttributeNamesToFetch release];
    self->_entityNameToAttributeNamesToFetch = [entityNameToAttributeNamesToFetch copy];
    
    if (self->_entityNameToAttributeNamesToFetch.count == 0) {
        [self->_entityNameToAttributeNamesToFetch release];
        self->_entityNameToAttributeNamesToFetch = [[NSDictionary alloc] init];
    }
}

- (void)setEntityNameToAttributesToFetch:(NSDictionary<NSString *, NSArray<NSAttributeDescription *> *> *)entityNameToAttributesToFetch {
    if (!_editable) {
        [self throwNotEditable:_cmd];
        return;
    }
    
    NSDictionary<NSString *, NSArray<NSAttributeDescription *> *> *old_entityNameToAttributesToFetch = self->_entityNameToAttributesToFetch;
    if (old_entityNameToAttributesToFetch == entityNameToAttributesToFetch) return;
    
    [old_entityNameToAttributesToFetch release];
    self->_entityNameToAttributesToFetch = [entityNameToAttributesToFetch copy];
    
    if (self->_entityNameToAttributesToFetch.count == 0) {
        [self->_entityNameToAttributesToFetch release];
        self->_entityNameToAttributesToFetch = [[NSMutableDictionary alloc] init];
    }
}

- (void)setObjectIDsToFetch:(NSArray<NSManagedObjectID *> *)objectIDsToFetch {
    if (!_editable) {
        [self throwNotEditable:_cmd];
        return;
    }
    
    NSArray<NSManagedObjectID *> *old_objectIDsToFetch = self->_objectIDsToFetch;
    if (old_objectIDsToFetch == objectIDsToFetch) return;
    
    [old_objectIDsToFetch release];
    self->_objectIDsToFetch = [objectIDsToFetch copy];
}

- (void)throwNotEditable:(SEL)aSEL {
    NSString *reason = [NSString stringWithFormat:@"%@ called after the request was sent to %@\\nRequest: %@", NSStringFromSelector(aSEL), NSStringFromSelector(@selector(executeRequest:error:)), self];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

- (BOOL)validateForUseWithStore:(NSSQLCore *)store error:(NSError * _Nullable *)error {
    /*
     self = x22
     store = x23
     error = x19
     */
    // x29, #-0x78
    NSError * _Nullable _error = nil;
    BOOL result = [super validateForUseWithStore:store error:&_error];
    
    if (!result) {
        // <+528>
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
    
    // x20
    NSMutableArray<NSString *> *array = [[NSMutableArray alloc] init];
    // x21
    NSMutableDictionary<NSString *, NSMutableArray<NSAttributeDescription *> *> *dictionary = [[NSMutableDictionary alloc] init];
    // x23
    NSManagedObjectModel *managedObjectModel = store.persistentStoreCoordinator.managedObjectModel;
    
    if (_entityNameToAttributesToFetch.count != 0) {
        // <+164>
        /*
         __72-[NSCloudKitMirroringFetchRecordsRequest validateForUseWithStore:error:]_block_invoke
         managedObjectModel = sp + 0x60 = x21 + 0x20
         dictionary = sp + 0x68 = x21 + 0x28
         array = sp + 0x70 = x21 + 0x30
         */
        [_entityNameToAttributesToFetch enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull entityName, NSArray<NSAttributeDescription *> * _Nonnull attributes, BOOL * _Nonnull stop) {
            /*
             self(block) = x21
             entityName = x19
             attributes = x20
             */
            // x22
            NSEntityDescription *entityDescription = [managedObjectModel.entitiesByName objectForKey:entityName];
            if (entityDescription == nil) {
                // <+208>
                [array addObject:[NSString stringWithFormat:@"%@ - entity not found in model", entityName]];
                return;
            }
            
            // sp + 0x8
            NSMutableArray<NSAttributeDescription *> *_array_2 = [[dictionary objectForKey:entityName] retain];
            if (_array_2 == nil) {
                _array_2 = [[NSMutableArray alloc] init];
                [dictionary setObject:_array_2 forKey:entityName];
            }
            
            /*
             __72-[NSCloudKitMirroringFetchRecordsRequest validateForUseWithStore:error:]_block_invoke_2
             entityDescription = sp + 0x30 = x19 + 0x20
             _array_2 = sp + 0x38 = x19 + 0x28
             array = sp + 0x40 = x19 + 0x30
             entityName = sp + 0x48 = x19 + 0x38
             */
            [attributes enumerateObjectsUsingBlock:^(NSAttributeDescription * _Nonnull attribute, NSUInteger idx, BOOL * _Nonnull stop) {
                /*
                 self(block) = x19
                 attribute = x20
                 */
                NSAttributeDescription *attribute_2 = [entityDescription.attributesByName objectForKey:attribute.name];
                if (attribute_2 == nil) {
                    [array addObject:[NSString stringWithFormat:@"%@.%@ - attribute not found on entity", attribute, attribute.name]];
                } else {
                    [_array_2 addObject:attribute_2];
                }
            }];
            
            [_array_2 release];
        }];
    } else if (_entityNameToAttributeNamesToFetch.count != 0) {
        // <+248>
        /*
         __72-[NSCloudKitMirroringFetchRecordsRequest validateForUseWithStore:error:]_block_invoke_3
         managedObjectModel = sp + 0x28 = x21 + 0x20
         dictionary = sp + 0x30 = x21 + 0x28
         array = sp + 0x38 = x21 + 0x30
         */
        [_entityNameToAttributeNamesToFetch enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull entityName, NSArray<NSString *> * _Nonnull attributeNames, BOOL * _Nonnull stop) {
            /*
             self(block) = x21
             entityName = x19
             attributeNames = x20
             */
            // x22
            NSEntityDescription *entityDescription = [managedObjectModel.entitiesByName objectForKey:entityName];
            if (entityDescription == nil) {
                [array addObject:[NSString stringWithFormat:@"%@ - entity not found in model", entityName]];
                return;
            }
            
            // sp, #0x8
            NSMutableArray<NSAttributeDescription *> *_array_2 = [[dictionary objectForKey:entityName] retain];
            if (_array_2 == nil) {
                _array_2 = [[NSMutableArray alloc] init];
                [dictionary setObject:_array_2 forKey:entityName];
            }
            
            /*
             __72-[NSCloudKitMirroringFetchRecordsRequest validateForUseWithStore:error:]_block_invoke_4
             entityDescription = sp + 0x30 = x20 + 0x20
             _array_2 = sp + 0x38 = x20 + 0x28
             array = sp + 0x40 = x20 + 0x30
             entityName = sp + 0x48 = x20 + 0x38
             */
            [attributeNames enumerateObjectsUsingBlock:^(NSString * _Nonnull attributeName, NSUInteger idx, BOOL * _Nonnull stop) {
                /*
                 self(block) = x20
                 attributeName = x19
                 */
                NSAttributeDescription *attributeDescription = [entityDescription.attributesByName objectForKey:attributeName];
                if (attributeDescription == nil) {
                    [array addObject:[NSString stringWithFormat:@"%@.%@ - attribute not found on entity", entityName, attributeName]];
                    return;
                }
                
                [_array_2 addObject:attributeDescription];
            }];
            
            [_array_2 release];
        }];
    }
    
    // <+312>
    if (array.count != 0) {
        // <+324>
        [array sortUsingSelector:@selector(compare:)];
        // x22
        NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"Invalid '%@'. The following validation failures occured:", NSStringFromClass([self class])];
        [string appendFormat:@"\n%@", [array componentsJoinedByString:@"\n"]];
        _error = [NSError errorWithDomain:NSCocoaErrorDomain code:134070 userInfo:@{
            NSLocalizedFailureReasonErrorKey: string
        }];
        [string release];
        // <+520>
        [dictionary release];
        [array release];
        
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
    
    // <+688>
    // nil이 될 여지는 없음. 아마 무언가의 inline이 있는듯
    if (dictionary == nil) {
        // <+520>
        [dictionary release];
        [array release];
        
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
    
    [_entityNameToAttributesToFetch release];
    _entityNameToAttributesToFetch = [dictionary copy];
    [dictionary release];
    [array release];
    
    return YES;
}

@end
