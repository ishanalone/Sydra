//
//  NewTaskViewController.m
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "NewTaskViewController.h"
#import "NewTaskTableViewCell.h"
#import "AppDelegate.h"
#import "MapViewController.h"
#import "CoreDataHandler.h"
#import "UITextField+Shake.h"

@import Material;

@interface NewTaskViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,strong) NSArray* inputArray;
@property (nonatomic,strong) NSArray* keysArray;
@property (nonatomic,strong) NSMutableDictionary* payloadDictionary;
@property (nonatomic,strong) NSDictionary* colorDictionary;

@end

@implementation NewTaskViewController{
    Task* editTask;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.inputArray = @[@"I WANT TO",@"DATE",@"REMIND ME AT",@"REMIND ME WHERE",@"COLOR"];

    self.payloadDictionary = [[NSMutableDictionary alloc] init];
    self.colorDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ColorList" ofType:@"plist"]];
    NSLog(@"Color - %@",self.colorDictionary);
    
    if (_isEdit) {
        [self.createButton setTitle:@"Update" forState:UIControlStateNormal];
        [_titleHeader setText:@"Edit ToDo"];
    }else{
        [_titleHeader setText:@"Create ToDo"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fillAllDetailsWithTask:(Task *)task{
    _isEdit = YES;
    editTask = task;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.inputArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewTaskTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"NewTaskTableViewCell" forIndexPath:indexPath];
    cell.inputField.placeholder = self.inputArray[indexPath.row];
    
    switch (indexPath.row) {
        case 0:
            if (editTask) {
                cell.inputField.text = editTask.taskDetail;
            }
            break;
        case 1:
            cell.inputField.inputView = [self datePicker];
            if (editTask) {
                cell.inputField.text = editTask.taskDate;
            }
            break;
        case 2:
            if (editTask) {
                cell.inputField.text = editTask.taskTime;
            }
            cell.inputField.inputView = [self timePicker];
            break;
        
        case 4:
            if (editTask) {
                cell.inputField.text = editTask.taskColor ;
                [cell.inputField setTextColor:[self getColorFromString:self.colorDictionary[[editTask.taskColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]]];
            }
            cell.inputField.inputView = [self pickerView];
            break;
        case 3:
            [((TextField*)cell.inputField) setDetail: @"You will be notified when you are in area."];
            if (editTask) {
                cell.inputField.text = editTask.taskLocation;
                 NSArray* locArray;
                if (editTask.taskCordinates != nil) {
                    locArray = [editTask.taskCordinates componentsSeparatedByString:@","];
                }
                CLLocation* eventLocation = [[CLLocation alloc] initWithLatitude:[locArray[0] floatValue] longitude:[locArray[1] floatValue]];
                ;
                [self getAddressFromLocation:eventLocation complationBlock:^(NSString * address) {
                    if(address) {
                        
                        [self performSelectorOnMainThread:@selector(updateCellWithAddress:) withObject:@[indexPath,address] waitUntilDone:YES];
                    }
                }];
            }
            break;
        default:
            break;
    }
    
    [cell.inputField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [cell.inputField setPlaceholderActiveColor:[UIColor lightGrayColor]];
    [cell.inputField setPlaceholderNormalColor:[UIColor grayColor]];
    [cell.inputField setDividerColor:[UIColor colorWithRed:80.0f/255.0f green:210.0f/255.0f blue:194.0f/255.0f alpha:1]];

    cell.inputField.tag = indexPath.row;
    return cell;
}

-(void)updateCellWithAddress:(NSArray*)addressArra{
    
    NewTaskTableViewCell* cell = [self.taskTable cellForRowAtIndexPath:addressArra[0]];
    cell.inputField.text = addressArra[1];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}



- (UIPickerView *) pickerView {
    UIPickerView*   _pickerView = [[UIPickerView alloc] init];
    [_pickerView setBackgroundColor:[UIColor whiteColor]];
    [_pickerView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [_pickerView setShowsSelectionIndicator:NO];
    [_pickerView setDelegate:self];
    [_pickerView setDataSource:self];
    
    return _pickerView;
}

- (UIDatePicker *) timePicker
{
    UIDatePicker* timePicker = [[UIDatePicker alloc] init];
    //[timePicker setMinimumDate:[NSDate date]];
    [timePicker setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [timePicker setDatePickerMode:UIDatePickerModeTime];
    [timePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
    return timePicker;
}


- (UIDatePicker *) datePicker
{
    UIDatePicker* _datePicker = [[UIDatePicker alloc] init];
    [_datePicker setMinimumDate:[NSDate date]];
    [_datePicker setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    return _datePicker;
}


- (void)dateChanged:(UIDatePicker *)dPicker
{
    NSDateFormatter* dropDownDateTimeFormater = [[NSDateFormatter alloc] init];
    [dropDownDateTimeFormater setDateFormat:@"yyyy-MM-dd"];
    //[dropDownDateTimeFormater setTimeStyle:NSDateFormatterNoStyle];
    NewTaskTableViewCell* cell = [self.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell.inputField.text = [dropDownDateTimeFormater stringFromDate:dPicker.date];
}

- (void)timeChanged:(UIDatePicker *)tPicker
{
    NSDateFormatter* dropDownTimeFormatter = [[NSDateFormatter alloc] init];
    [dropDownTimeFormatter setDateStyle:NSDateFormatterNoStyle];
    [dropDownTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    NewTaskTableViewCell* cell = [self.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    cell.inputField.text = [dropDownTimeFormatter stringFromDate:tPicker.date];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.colorDictionary allKeys].count;
}

#pragma mark UIPickerView delegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (!view) {
        view = [[UIView alloc] init];
        [view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        [view setBackgroundColor:[self getColorFromString:[[self.colorDictionary allValues] objectAtIndex:row]]];
        UILabel* name = [[UILabel alloc] init];
        [name setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        [name setTextAlignment:NSTextAlignmentCenter];
        name.text = [[self.colorDictionary allKeys] objectAtIndex:row];
        [name setTextColor:[UIColor whiteColor]];
        [view addSubview:name];
    }
    return view;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NewTaskTableViewCell* cell = [self.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    //cell.inputField.backgroundColor = [self getColorFromString:[[self.colorDictionary allValues] objectAtIndex:row]];
    cell.inputField.text = [NSString stringWithFormat:@"  %@",[[self.colorDictionary allKeys] objectAtIndex:row]] ;
    [cell.inputField setTextColor:[self getColorFromString:[[self.colorDictionary allValues] objectAtIndex:row]]];
    
}

-(UIColor*)getColorFromString:(NSString*)str{
    NSArray* rgbArr = [str componentsSeparatedByString:@","];
    UIColor* color = [UIColor colorWithRed:[rgbArr[0] floatValue]/255.0f green:[rgbArr[1] floatValue]/255.0f blue:[rgbArr[2] floatValue]/255.0f alpha:1.0];
    return color;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.taskTable setContentSize:CGSizeMake(0, 500)];
    NewTaskTableViewCell* cell = [self.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
    [UIView animateWithDuration:0.5 animations:^{
        [cell.placeholderLabel setFrame:(CGRect){CGPointMake(cell.placeholderLabel.frame.origin.x, 15),cell.placeholderLabel.frame.size}];
        [self.taskTable setContentOffset:CGPointMake(0, 20 + (textField.tag*40))];
    } completion:^(BOOL finished) {
        [cell.placeholderLabel setHidden:YES];
        [cell.placeholderLabel setFrame:(CGRect){CGPointMake(cell.placeholderLabel.frame.origin.x, 15),cell.placeholderLabel.frame.size}];
    }];
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self.taskTable setContentSize:CGSizeMake(self.taskTable.frame.size.width, self.taskTable.frame.size.height + 300)];
    if (textField.tag == 3) {
        [self performSegueWithIdentifier:@"MapView" sender:nil];
        return NO;
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self.taskTable setContentSize:CGSizeMake(self.taskTable.frame.size.width, self.taskTable.frame.size.height)];
    NewTaskTableViewCell* cell = [self.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];

    [UIView animateWithDuration:0.5 animations:^{
        if (cell.inputField.text.length == 0) {
            [cell.placeholderLabel setFrame:cell.inputField.frame];
        }else{
            [cell.placeholderLabel setFrame:(CGRect){CGPointMake(cell.placeholderLabel.frame.origin.x, 15),cell.placeholderLabel.frame.size}];
        }
        [self.taskTable setContentOffset:CGPointMake(0, 0)];
    } completion:^(BOOL finished) {
         if (cell.inputField.text.length != 0) {
             [cell.placeholderLabel setFrame:(CGRect){CGPointMake(cell.placeholderLabel.frame.origin.x, 15),cell.placeholderLabel.frame.size}];
         }
        [cell.placeholderLabel setHidden:NO];
    }];
    
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    [textField resignFirstResponder];
    return YES;
}


-(BOOL)isValid{
    for (int i = 0; i<_inputArray.count; i++) {
        if (i != 3) {
            NewTaskTableViewCell* cell = [self.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell.inputField.text.length == 0) {
                cell.inputField.detail = @"This field cannot be empty.";
                [(TextField*)cell.inputField setDividerColor:[UIColor redColor]];
                [cell.inputField shake];
                return NO;
            }
        }
    }
    return YES;
}

-(IBAction)createTask:(id)sender{
    [self.view endEditing:YES];
    if ([self isValid]) {
        NSError *error;
        NSString *noteDataString;
        //[self.payloadDictionary setObject:@"" forKey:@"domain_name"];
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        NewTaskTableViewCell* cell = [self.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (cell.inputField.text.length != 0) {
            [self.payloadDictionary setObject:cell.inputField.text forKey:@"desc"];
        }
        NewTaskTableViewCell* cell1 = [self.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        if (cell1.inputField.text.length != 0) {
            [dictionary setObject:cell1.inputField.text forKey:@"date"];
        }
        NewTaskTableViewCell* cell2 = [self.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        if (cell2.inputField.text.length != 0) {
            [dictionary setObject:cell2.inputField.text forKey:@"time"];
        }
        NewTaskTableViewCell* cell3 = [self.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        NewTaskTableViewCell* cell4 = [self.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        //[dictionary setObject:cell3.inputField.text forKey:@"rule"];
        if (_locationDictionary) {
            [dictionary setObject:@[self.locationDictionary[@"lat"],self.locationDictionary[@"lng"]] forKey:@"day"];
        }else{
            if (_isEdit && editTask.taskCordinates.length>0) {
                NSArray* coord = [editTask.taskCordinates componentsSeparatedByString:@","];
                [dictionary setObject:@[coord[0],coord[1]] forKey:@"day"];
            }
        }
        
        [self.payloadDictionary setObject:dictionary forKey:@"schedule_attributes"];
        [self.payloadDictionary setObject:[NSNumber numberWithInt:0] forKey:@"state"];
        NSString* color = [cell4.inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSInteger index = [self.colorDictionary.allKeys indexOfObject:color];
        [self.payloadDictionary setObject:[NSString stringWithFormat:@"%ld",(long)index] forKey:@"tag_list"];
        NSDictionary* dict = @{@"todo":self.payloadDictionary};
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
            if (_isEdit) {
                url = [NSString stringWithFormat:@"http://happytodo.int2root.com/v1/todos/%@",editTask.taskId];
            }else{
                url = @"http://happytodo.int2root.com/v1/todos";
            }
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            if (_isEdit) {
                request.HTTPMethod = @"PUT";
            }else{
                request.HTTPMethod = @"POST";
            }
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
                        NSLog(@"response - %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                        NSDictionary* taskDict = jsonData;
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
                        
                        NSArray*locArray ;
                        if (schedule[@"day"] != [NSNull null]) {
                            locArray = schedule[@"day"];
                        }
                        if (locArray && locArray.count>0) {
                            CLLocation* eventLocation = [[CLLocation alloc] initWithLatitude:[locArray[0] floatValue] longitude:[locArray[1] floatValue]];
                            
                            [self getAddressFromLocation:eventLocation complationBlock:^(NSString * address) {
                                if(address) {
                                    NSDictionary* taskDictionary = @{@"id":tid,@"desc":desc,@"date":date,@"time":time,@"color":colorString,@"state":[NSNumber numberWithBool:isCompleted],@"location":address,@"coordinates":[locArray componentsJoinedByString:@","]};
                                    if (editTask) {
                                        [[AppDelegate getAppDelegate] removeNotificationWithTask:[[CoreDataHandler sharedInstance] updateTask:taskDictionary withId:editTask.taskId]];
                                    }else{
                                        [[CoreDataHandler sharedInstance] addTask:taskDictionary];
                                        [[AppDelegate getAppDelegate] saveContext];
                                        
                                    }
                                    //[[AppDelegate getAppDelegate] addNotification:taskDictionary];
                                    [self dismissViewControllerAnimated:YES completion:^{
                                        [self.controller reloadCalendar];
                                    }];
                                }
                            }];

                        }else{
                            NSDictionary* taskDictionary = @{@"id":tid,@"desc":desc,@"date":date,@"time":time,@"color":colorString,@"state":[NSNumber numberWithBool:isCompleted]};
                            if (editTask) {
                                [[AppDelegate getAppDelegate] removeNotificationWithTask:[[CoreDataHandler sharedInstance] updateTask:taskDictionary withId:editTask.taskId]];
                                
                                    [[AppDelegate getAppDelegate] addNotification:taskDictionary];
                                
                            }else{
                                [[CoreDataHandler sharedInstance] addTask:taskDictionary];
                                [[AppDelegate getAppDelegate] saveContext];
                                
                            }
                            //[[AppDelegate getAppDelegate] addNotification:taskDictionary];
                            [self dismissViewControllerAnimated:YES completion:^{
                                [self.controller reloadCalendar];
                            }];
                        }
                        
                        //Process the data
                    }else{
                        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                        NSLog(@"response - %@",jsonData);
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!!!" message:@"Something went wrong. Please try again" preferredStyle:UIAlertControllerStyleAlert];
                        [alertController.view setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
                        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                        
                        [alertController addAction:ok];
                        
                        
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                }
                
            }];
            [task resume];
        }
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

-(IBAction)closeCreate:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)fillLocationDetails{
    NewTaskTableViewCell* cell = [self.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    cell.inputField.text = [self.locationDictionary objectForKey:@"formattedAddress"];
    [cell.placeholderLabel setHidden:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MapViewController* controller = segue.destinationViewController;
    controller.controller = self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
