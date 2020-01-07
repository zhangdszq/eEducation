//
//  RolesInfoModel.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/6.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TeacherModel.h"
#import "StudentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RolesStudentInfoModel : NSObject

@property(nonatomic, strong) NSString *attrKey;
@property(nonatomic, strong) StudentModel* studentModel;

@end

@interface RolesInfoModel : NSObject

@property(nonatomic, strong) TeacherModel *teacherModel;
@property(nonatomic, strong) NSArray<RolesStudentInfoModel*> *studentModels;

@end

NS_ASSUME_NONNULL_END
