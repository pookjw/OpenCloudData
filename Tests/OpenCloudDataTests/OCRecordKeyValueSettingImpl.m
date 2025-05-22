//
//  OCRecordKeyValueSettingImpl.m
//  OpenCloudDataTests
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import "OCRecordKeyValueSettingImpl.h"

@interface OCRecordKeyValueSettingImpl () {
    NSMutableDictionary<CKRecordFieldKey, id<CKRecordValue>> *_values;
}
@end

@implementation OCRecordKeyValueSettingImpl

- (instancetype)init {
    if (self = [super init]) {
        _values = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_values release];
    [super dealloc];
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    
    return [_values isEqualToDictionary:((OCRecordKeyValueSettingImpl *)other)->_values];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", [super description], _values];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    OCRecordKeyValueSettingImpl *copy = [[[self class] alloc] init];
    copy->_values = [_values mutableCopy];
    return copy;
}

- (nullable __kindof id<CKRecordValue>)objectForKey:(CKRecordFieldKey)key {
    return [_values objectForKey:key];
}

- (void)setObject:(nullable __kindof id<CKRecordValue>)object forKey:(CKRecordFieldKey)key {
    [_values setObject:object forKey:key];
}

- (nullable __kindof id<CKRecordValue>)objectForKeyedSubscript:(CKRecordFieldKey)key {
    return _values[key];;
}

- (void)setObject:(nullable __kindof id<CKRecordValue>)object forKeyedSubscript:(CKRecordFieldKey)key {
    _values[key] = object;
}

- (NSArray<CKRecordFieldKey> *)allKeys {
    return _values.allKeys;;
}

- (NSArray<CKRecordFieldKey> *)changedKeys {
    return _values.allKeys;;
}

@end
