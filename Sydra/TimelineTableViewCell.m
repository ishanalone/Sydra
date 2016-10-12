//
//  TimelineTableViewCell.m
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "TimelineTableViewCell.h"
#import "CoreDataHandler.h"

@implementation TimelineTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTaskDone{
   
    
    [[CoreDataHandler sharedInstance] setTaskDone:self.task.taskId];
    
}

@end
