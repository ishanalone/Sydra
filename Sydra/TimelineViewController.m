//
//  TimelineViewController.m
//  Sydra
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "TimelineViewController.h"
#import "FSCalendar.h"
#import "KeychainWrapper.h"
#import "CoreDataHandler.h"
#import "TimelineTableViewCell.h"
#import "Task+CoreDataClass.h"

@interface TimelineViewController ()<FSCalendarDataSource,FSCalendarDelegate>
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
   
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"token"]) {
        [self.navigationController performSegueWithIdentifier:@"PresentLogin" sender:nil];
    }
    self.taskArray = [[CoreDataHandler sharedInstance] getAllTask];
    [self.timelineTable reloadData];
}



- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
    [self.timelineTable setFrame:CGRectMake(0, bounds.origin.y + bounds.size.height+60, self.timelineTable.frame.size.width, screenBounds.size.height  - bounds.size.height - 60)];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
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
    [self performSegueWithIdentifier:@"AddNewTask" sender:nil];
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
    cell.colorView.backgroundColor = [self getColorFromString:[[colorDictionary allValues] objectAtIndex:indexPath.row]];
    cell.timeLabel.text = task.taskTime;
    cell.locationLabel.text = task.taskLocation;
    return cell;
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
    [label setFont:[UIFont fontWithName:@"AvenirNext-DemiBoldItalic" size:17]];
    [label setTextColor:[UIColor colorWithRed:80/255.0f green:210/255.0f blue:194/255.0f alpha:1.0]];
    return label;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 107.0f;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
