//
//  TimelineViewController.m
//  Sydra
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "TimelineViewController.h"
#import "FSCalendar.h"
#import "CoreDataHandler.h"
#import "TimelineTableViewCell.h"
#import "Task+CoreDataClass.h"
#import "CoreDataHandler.h"
#import "NewTaskViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface TimelineViewController ()<FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>
@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UITableView* timelineTable;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSArray* taskArray;
@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 480 : 330;
   
    self.calendar.dataSource = self;
    self.calendar.delegate = self;
    //    calendar.showsPlaceholders = NO;
    self.calendar.scopeGesture.enabled = YES;
    self.calendar.showsScopeHandle = YES; // important
    self.calendar.backgroundColor = [UIColor whiteColor];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    [self.calendar selectDate:[NSDate date]];
    
    [_calendar setScope:FSCalendarScopeWeek animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [self getAllTaks];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"token"]) {
        [self.navigationController performSegueWithIdentifier:@"PresentLogin" sender:nil];
    }
    self.taskArray = [[CoreDataHandler sharedInstance] getAllTask];
    [self.timelineTable reloadData];
    //[self.calendar reloadData];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}


- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
    _calendarHeightConstraint.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
    [self.timelineTable setFrame:CGRectMake(0, bounds.origin.y + bounds.size.height+60, self.timelineTable.frame.size.width, screenBounds.size.height  - bounds.size.height - 60)];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
    
    NSArray* array = [[CoreDataHandler sharedInstance] getAllDate] ;
    NSInteger index = 0;
    for (int i = 0; i<array.count; i++) {
        NSDictionary* dict = array[i];
        if ([[self.dateFormatter stringFromDate:date] isEqualToString:dict[@"taskDate"]]) {
            index = i;
        }
    }
    if ([self.timelineTable numberOfSections] > 0) {
        CGRect sectionRect = [self.timelineTable rectForSection:index];
        sectionRect.size.height = self.timelineTable.frame.size.height; [self.timelineTable scrollRectToVisible:sectionRect animated:YES];
    }
    
    
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date{
    NSString* dateStr = [self.dateFormatter stringFromDate:date];
    if ([[CoreDataHandler sharedInstance] getallTaskForDate:dateStr].count > 0) {
        return 1;
    }
    return 0;
}

-(NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date{
    return @[[UIColor colorWithRed:251.0f/255.0f green:87.0f/255.0f blue:47.0f/255.0f alpha:1]];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(UIColor*)getColorFromString:(NSString*)str{
    NSArray* rgbArr = [str componentsSeparatedByString:@","];
    UIColor* color = [UIColor colorWithRed:[rgbArr[0] floatValue]/255.0f green:[rgbArr[1] floatValue]/255.0f blue:[rgbArr[2] floatValue]/255.0f alpha:1.0];
    return color;
}

-(IBAction)addNewTask:(id)sender{
    [self performSegueWithIdentifier:@"AddNewTask" sender:sender];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [[CoreDataHandler sharedInstance] getAllDate].count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[CoreDataHandler sharedInstance] getallTaskForDate:[[[[CoreDataHandler sharedInstance] getAllDate] objectAtIndex:section] objectForKey:@"taskDate"]].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TimelineTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TimelineTableViewCell" forIndexPath:indexPath];
    Task* task = [[[CoreDataHandler sharedInstance] getallTaskForDate:[[[[CoreDataHandler sharedInstance] getAllDate] objectAtIndex:indexPath.section] objectForKey:@"taskDate"]] objectAtIndex:indexPath.row];
    cell.desclabel.text = task.taskDetail;
    NSDictionary* colorDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ColorList" ofType:@"plist"]];
    cell.colorView.backgroundColor = [self getColorFromString:colorDictionary[[task.taskColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]]];
    cell.delegate = self;
    cell.timeLabel.text = task.taskTime;
    cell.task = task;
       NSArray* locArray;
    if (cell.task.taskCordinates != nil) {
        locArray = [cell.task.taskCordinates componentsSeparatedByString:@","];
    }
    CLLocation* eventLocation = [[CLLocation alloc] initWithLatitude:[locArray[0] floatValue] longitude:[locArray[1] floatValue]];
    ;
    [self getAddressFromLocation:eventLocation complationBlock:^(NSString * address) {
        if(address) {
            
            [self performSelectorOnMainThread:@selector(updateCellWithAddress:) withObject:@[indexPath,address] waitUntilDone:YES];
        }
    }];
    if (task.taskState) {
        NSMutableAttributedString *strikeThroughString = [[NSMutableAttributedString alloc] initWithString:cell.desclabel.text];
        [strikeThroughString addAttribute:NSStrikethroughStyleAttributeName value:(NSNumber *)kCFBooleanTrue range:NSMakeRange(0, [cell.desclabel.text length])];
        [cell.desclabel setAttributedText:strikeThroughString];
    }
    return cell;
}

-(void)updateCellWithAddress:(NSArray*)addressArra{
    
    TimelineTableViewCell* cell = [self.timelineTable cellForRowAtIndexPath:addressArra[0]];
    cell.locationLabel.text = addressArra[1];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    label.backgroundColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSArray* dateArr = [[CoreDataHandler sharedInstance] getAllDate];
    NSDate* date = [formatter dateFromString:[dateArr[section] objectForKey:@"taskDate"]];
    [formatter setDateFormat:@"EEEE, MMMM d"];
    [label setText:[NSString stringWithFormat:@"      %@",[formatter stringFromDate:date]]];
    [label setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:17]];
    [label setTextColor:[UIColor colorWithRed:80/255.0f green:210/255.0f blue:194/255.0f alpha:1.0]];
    return label;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 107.0f;
}

-(NSArray *) createLeftButtonAtIndexPath: (NSIndexPath*) indexPath
{
    NSMutableArray * result = [NSMutableArray array];
    Task* task = [[[CoreDataHandler sharedInstance] getallTaskForDate:[[[[CoreDataHandler sharedInstance] getAllDate] objectAtIndex:indexPath.section] objectForKey:@"taskDate"]] objectAtIndex:indexPath.row];
    NSDictionary* colorDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ColorList" ofType:@"plist"]];
    UIColor * colors = [self getColorFromString:colorDictionary[[task.taskColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
     UIImage * icons = [UIImage imageNamed:@"done_white.png"];
    
    MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:icons backgroundColor:colors padding:15 callback:^BOOL(MGSwipeTableCell * sender){
       
        return YES;
    }];
        [result addObject:button];
    
    return result;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings;
{
    NSIndexPath* index = [self.timelineTable indexPathForCell:cell];
    Task* task = [[[CoreDataHandler sharedInstance] getallTaskForDate:[[[[CoreDataHandler sharedInstance] getAllDate] objectAtIndex:index.section] objectForKey:@"taskDate"]] objectAtIndex:index.row];
    if (direction == MGSwipeDirectionLeftToRight) {
        if (task.taskState == YES) {
            return nil;
        }
        expansionSettings.buttonIndex = 0;
        expansionSettings.fillOnTrigger = YES;
        return [self createLeftButtonAtIndexPath:index];
    }else {
        expansionSettings.buttonIndex = 0;
        expansionSettings.fillOnTrigger = YES;
        return [self createRightButtonsAtIndexPath:index];
    }
    return nil;
}

-(void)swipeTableCellWillEndSwiping:(MGSwipeTableCell *)cell{
    /**/
}

-(BOOL) swipeTableCell:(nonnull MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    NSIndexPath* indexPath = [self.timelineTable indexPathForCell:cell];
    Task* task = ((TimelineTableViewCell*)cell).task;
    if (direction == MGSwipeDirectionLeftToRight) {
        [self setTaskDone:task AtIndex:indexPath];
        
        return YES;
    }
    if (fromExpansion) {
        [self deleteTask:task AtindexPath:indexPath];
    }else{
        switch (index) {
            case 0:
            {
                [self deleteTask:task AtindexPath:indexPath];
            }
                break; 
            case 1:
                [self createShareActivityWithTask:task];
                break;
            case 2:
                [self performSegueWithIdentifier:@"AddNewTask" sender:cell];
                break;
            default:
                break;
        }
    }
    
    return YES;
}

-(void)deletetaskFromUI:(NSArray*)tastArray {
    Task* task = tastArray[0];
    NSIndexPath* indexPath = tastArray[1];
    BOOL isSingleCellForDate = NO;
    if ([[CoreDataHandler sharedInstance] getallTaskForDate:task.taskDate].count == 1) {
        isSingleCellForDate = YES;
    }
    [[CoreDataHandler sharedInstance] deleteTaskWithId:task.taskId];
    [self.timelineTable beginUpdates];
    if (isSingleCellForDate) {
        [self.timelineTable deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
    }
    [self.timelineTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.timelineTable endUpdates];
    [self.calendar reloadData];
}

-(void)deleteTask:(Task*)dotask AtindexPath:(NSIndexPath*)indexPath{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfiguration.HTTPAdditionalHeaders = @{@"Authorization": authValue};
    [[AppDelegate getAppDelegate] showActivityIndicator:YES];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSString *url;
    url = [NSString stringWithFormat:@"http://happytodo.int2root.com/v1/todos/%@",dotask.taskId] ;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"DELETE";
    NSString *authValue = [NSString stringWithFormat:@"Token %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [[AppDelegate getAppDelegate] showActivityIndicator:NO];
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200 || httpResponse.statusCode == 204){
                [[AppDelegate getAppDelegate] removeNotificationWithTask:dotask];
                NSArray* taskAr = @[dotask,indexPath];
                [self performSelectorOnMainThread:@selector(deletetaskFromUI:) withObject:taskAr waitUntilDone:YES];
                //Process the data
            }else{
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                NSLog(@"response - %@",jsonData);
            }
        }
        
        
    }];
    [task resume];
}

-(void)setTaskDoneWithArray:(NSIndexPath*)indexPath{
    TimelineTableViewCell* cell = [self.timelineTable cellForRowAtIndexPath:indexPath];
    [cell setTaskDone];
    [self.timelineTable reloadData];
}

-(void)setTaskDone:(Task*)doTask AtIndex:(NSIndexPath*)indexPath{
    
    NSError *error;
    NSString *noteDataString;
    //[self.payloadDictionary setObject:@"" forKey:@"domain_name"];
    NSMutableDictionary* payloadDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    [payloadDictionary setObject:doTask.taskDetail forKey:@"desc"];
    [dictionary setObject:doTask.taskDate forKey:@"date"];
    [dictionary setObject:doTask.taskTime forKey:@"time"];
    if (doTask.taskCordinates) {
        [dictionary setObject:[doTask.taskCordinates componentsSeparatedByString:@","] forKey:@"day"];
    }
    
    [payloadDictionary setObject:dictionary forKey:@"schedule_attributes"];
    [payloadDictionary setObject:[NSNumber numberWithInt:1] forKey:@"state"];
    NSString* color = [doTask.taskColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSDictionary* colorDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ColorList" ofType:@"plist"]];
    NSInteger index = [colorDictionary.allKeys indexOfObject:color];
    [payloadDictionary setObject:[NSString stringWithFormat:@"%ld",(long)index] forKey:@"tag_list"];
    NSDictionary* dict = @{@"todo":payloadDictionary};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        noteDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    if (noteDataString) {
        [[AppDelegate getAppDelegate] showActivityIndicator:YES];
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        //sessionConfiguration.HTTPAdditionalHeaders = @{@"Authorization": authValue};
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        NSString *url;
        
        url = [NSString stringWithFormat:@"http://happytodo.int2root.com/v1/todos/%@",doTask.taskId];
        
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        request.HTTPMethod = @"PUT";
        
        request.HTTPBody = jsonData;
        
        NSString *authValue = [NSString stringWithFormat:@"Token %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"]];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [[AppDelegate getAppDelegate] showActivityIndicator:NO];
            if (!error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201){
                    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                    [[AppDelegate getAppDelegate] removeNotificationWithTask:doTask];
                    [self performSelectorOnMainThread:@selector(setTaskDoneWithArray:) withObject:indexPath waitUntilDone:YES];
                    //Process the data
                }else{
                    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                    NSLog(@"response - %@",jsonData);
                }
            }
            
        }];
        [task resume];
    }
    
}

-(void)createShareActivityWithTask:(Task*)task{
    NSString* activityString = [NSString stringWithFormat:@"Please can you do me a favour? \n\"%@\" before \"%@\" \nSent from Sydra.",task.taskDetail,task.taskDate];
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[activityString] applicationActivities:nil];
    [activityViewController setExcludedActivityTypes:@[UIActivityTypeAirDrop]];
    [self presentViewController:activityViewController animated:YES completion:nil];
}


-(NSArray *) createRightButtonsAtIndexPath: (NSIndexPath*) indexPath{

    Task* task = [[[CoreDataHandler sharedInstance] getallTaskForDate:[[[[CoreDataHandler sharedInstance] getAllDate] objectAtIndex:indexPath.section] objectForKey:@"taskDate"]] objectAtIndex:indexPath.row];
    UIColor * colors[3] = {[UIColor colorWithRed:231.0f/255.0f green:76.0f/255.0f blue:60.0f/255.0f alpha:1], [UIColor colorWithRed:149.0f/255.0f green:165.0f/255.0f blue:166.0f/255.0f alpha:1],[UIColor colorWithRed:52.0f/255.0f green:169.0f/255.0f blue:248.0f/255.0f alpha:1]};
    UIImage * icons[3] = {[UIImage imageNamed:@"delete"],[UIImage imageNamed:@"send.png"],[UIImage imageNamed:@"edit.png"]};
    NSMutableArray * result = [NSMutableArray array];
    if (!task.taskState) {
        for (int i = 0; i < 3; ++i)
        {
            MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:icons[i] backgroundColor:colors[i] padding:15 callback:^BOOL(MGSwipeTableCell * sender){
                NSLog(@"Convenience callback received (left).");
                BOOL autoHide = i != 0;
                return autoHide; //Don't autohide in delete button to improve delete expansion animation
            }];
            [result addObject:button];
        }
    }else{
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:icons[0] backgroundColor:colors[0] padding:15 callback:^BOOL(MGSwipeTableCell * sender){
            NSLog(@"Convenience callback received (left).");
            return YES;
        }];
        [result addObject:button];
    }
    
   // NSString* titles[3] = {@"Delete", @"Edit",@"Send"};
    
    return result;
}

-(void)reloadCalendar{
    [self.calendar reloadData];
}

-(IBAction)logout:(id)sender{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
    [[CoreDataHandler sharedInstance] clearAllData];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self.navigationController performSegueWithIdentifier:@"PresentLogin" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NewTaskViewController* controller = segue.destinationViewController;
    if ([sender isKindOfClass:[TimelineTableViewCell class]]) {
        //controller.isEdit = YES;
        [controller fillAllDetailsWithTask:((TimelineTableViewCell*)sender).task];
    }else{
        controller.isEdit = NO;
    }
    controller.controller = self;
    
}

-(void)getAllTaks{
    
   // [[AppDelegate getAppDelegate] showActivityIndicator:YES];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfiguration.HTTPAdditionalHeaders = @{@"Authorization": authValue};
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSString *url;
    url = @"http://happytodo.int2root.com/v1/todos";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    NSString *authValue = [NSString stringWithFormat:@"Token %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
       // [[AppDelegate getAppDelegate] showActivityIndicator:NO];
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201){
                NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                NSLog(@"response - %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                for (int i = 0; i<jsonData.count; i++) {
                    NSDictionary* taskDict = jsonData[i];
                    NSString* tid = taskDict[@"id"];
                    NSString* desc = taskDict[@"desc"];
                    NSDictionary* schedule = taskDict[@"schedule"];
                    NSString* date = schedule[@"date"];
                    NSArray* timeStrArr = [[[schedule[@"time"] componentsSeparatedByString:@"T"] objectAtIndex:1] componentsSeparatedByString:@":"];
                    NSString* timeStr = [NSString stringWithFormat:@"%@:%@",timeStrArr[0],timeStrArr[1]];
                    NSDateFormatter* fomatter = [[NSDateFormatter alloc] init];
                    [fomatter setDateFormat:@"HH:mm"];
                    //[fomatter setDateStyle:NSDateFormatterMediumStyle];
                    NSDate* timeDate = [fomatter dateFromString:timeStr];
                    [fomatter setDateFormat:@"hh:mm a"];
                    NSString* time = [fomatter stringFromDate:timeDate];
                    BOOL isCompleted;
                    if ([taskDict[@"state"] isEqualToString:@"complete"]) {
                        isCompleted = YES;
                    }else{
                        isCompleted = NO;
                    }
                    NSArray* tagArr = taskDict[@"tag_list"];
                    NSString* colorString;
                    if (tagArr.count>0) {
                        colorString = tagArr[0];
                    }else{
                        colorString = @"-1";
                    }
                    
                    NSArray* locArray;
                    if (schedule[@"day"] != [NSNull null]) {
                        locArray = schedule[@"day"];
                    }
                    
                    
                    if (locArray && locArray.count>0) {
                        NSDictionary* taskDictionary = @{@"id":tid,@"desc":desc,@"date":date,@"time":time,@"color":colorString,@"state":[NSNumber numberWithBool:isCompleted],@"coordinates":[locArray componentsJoinedByString:@","]};
                        [[CoreDataHandler sharedInstance] addTask:taskDictionary];
                    }else{
                        NSDictionary* taskDictionary = @{@"id":tid,@"desc":desc,@"date":date,@"time":time,@"color":colorString,@"state":[NSNumber numberWithBool:isCompleted]};
                            [[CoreDataHandler sharedInstance] addTask:taskDictionary];
                        
                        }
                    }
                 }
            [[AppDelegate getAppDelegate] saveContext];
            //[self.calendar selectDate:[NSDate date]];
            [self performSelectorOnMainThread:@selector(relaodData) withObject:nil waitUntilDone:YES];
                 //Process the data
            }else{
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                NSLog(@"response - %@",jsonData);
            }
        
        
    }];
    [task resume];
    
    
}

-(void)relaodData{
    [self.timelineTable reloadData];
    NSArray* array = [[CoreDataHandler sharedInstance] getAllDate] ;
    NSInteger index = 0;
    for (int i = 0; i<array.count; i++) {
        NSDictionary* dict = array[i];
        if ([[self.dateFormatter stringFromDate:[NSDate date]] isEqualToString:dict[@"taskDate"]]) {
            index = i;
        }
    }
    if ([self.timelineTable numberOfSections] > 0) {
        CGRect sectionRect = [self.timelineTable rectForSection:index];
        sectionRect.size.height = self.timelineTable.frame.size.height; [self.timelineTable scrollRectToVisible:sectionRect animated:YES];
    }

}

typedef void(^addressCompletion)(NSString *);

-(void)getAddressFromLocation:(CLLocation *)location complationBlock:(addressCompletion)completionBlock
{
    __block NSString *address = nil;
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfiguration.HTTPAdditionalHeaders = @{@"Authorization": authValue};
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=AIzaSyBoHXr7mYzxaFD8Vj2r6azSjyjXheuF-5o",location.coordinate.latitude,location.coordinate.longitude];
    
    //Replace Spaces with a '+' character.
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    //Create NSURL string from a formate URL string.
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200){
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                NSArray* locArray = jsonData[@"results"];
                if (locArray.count > 0) {
                    NSDictionary* locDict = locArray[0];
                    
                    address = locDict[@"formatted_address"];
                    completionBlock(address);
                }else{
                    completionBlock(@"");
                }
                
               
                //Process the data
            }else{
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                NSLog(@"response - %@",jsonData);
            }
        }
        
    }];
    [task resume];
}

@end
