//
//  OCCloudKitMirroringResult.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CoreData/CoreData.h>

@class OCCloudKitMirroringRequest;

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringResult : NSPersistentStoreResult

// original : (readonly, nonatomic)
@property (retain, readonly, nonatomic) NSString* storeIdentifier;

// original : (readonly, nonatomic)
@property (retain, readonly, nonatomic) __kindof OCCloudKitMirroringResult *request;

@property (readonly, nonatomic) BOOL success;
@property (readonly, nonatomic) BOOL madeChanges;

// original : (readonly, nonatomic)
@property (retain, readonly, nonatomic, nullable) NSError* error;

- (instancetype)initWithRequest:(__kindof OCCloudKitMirroringRequest *)request storeIdentifier:(NSString *)storeIdentifier success:(BOOL)success madeChanges:(BOOL)madeChanges error:(NSError * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
