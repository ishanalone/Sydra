//
//  Task+CoreDataProperties.h
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "Task+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Task (CoreDataProperties)

+ (NSFetchRequest<Task *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *taskColor;
@property (nullable, nonatomic, copy) NSString *taskDate;
@property (nullable, nonatomic, copy) NSString *taskDetail;
@property (nullable, nonatomic, copy) NSString *taskId;
@property (nullable, nonatomic, copy) NSString *taskLocation;
@property (nullable, nonatomic, copy) NSString *taskTime;
@property (nullable, nonatomic, copy) NSString *taskCordinates;
@property (nonatomic) BOOL taskState;

@end

NS_ASSUME_NONNULL_END
