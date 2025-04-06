//
//  NSSQLModelProvider.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/7/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/NSSQLModel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NSSQLModelProvider <NSObject>
- (NSSQLModel *)model;
//- (id)ancillaryModels;
//- (id)ancillarySQLModels;
//- (id)configurationName;
//- (id)newObjectIDForEntity:(id)arg1 pk:(long)arg2;
@end

NS_ASSUME_NONNULL_END
