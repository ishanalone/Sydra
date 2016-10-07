//
//  SignUpController.m
//  Sydra
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "SignUpController.h"
#import "LoginTableViewCell.h"
#import "AppDelegate.h"

@interface SignUpController ()
@property (nonatomic,strong) NSArray* inputArray;
@property (nonatomic,strong) NSArray* keysArray;
@property (nonatomic,strong) NSMutableDictionary* payloadDictionary;
@end

@implementation SignUpController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inputArray = @[@"Name",@"Email",@"Password",@"Confirm Password",@"Domain"];
    self.keysArray = @[@"name",@"email",@"password",@"password_confirmation",@"domain_name"];
    self.payloadDictionary = [[NSMutableDictionary alloc] init];
    // Do any additional setup after loading the view.
    [[AppDelegate getAppDelegate] buildAgreeTextViewFromString:@"ALREADY HAVE AN ACCOUNT?  #<si>SIGN IN#" atContainer:self.container andController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.inputArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LoginTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SignUpTableViewCell" forIndexPath:indexPath];
    cell.inputField.placeholder = self.inputArray[indexPath.row];
    cell.inputField.tag = indexPath.row;
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, 80)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    UILabel* logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
    //NSArray* array = [UIFont fontNamesForFamilyName:@"Avenir Next"];
    [logoLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBoldItalic" size:35]];
    logoLabel.text = @"sydra";
    [logoLabel setTextAlignment:NSTextAlignmentCenter];
    [logoLabel setTextColor:[UIColor colorWithRed:80/255.0f green:210/255.0f blue:194/255.0f alpha:1.0]];
    [headerView addSubview:logoLabel];
    logoLabel.center = CGPointMake(CGRectGetMidX(screenBounds), logoLabel.frame.size.height/2 );;
    UIImageView* logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(logoLabel.frame.origin.x - 40, 25, 30, 30)];
    [logoImage setImage:[UIImage imageNamed:@"sydra_logo"]];
    [headerView addSubview:logoImage];
    UIButton* closebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closebutton addTarget:self action:@selector(closeSignUp) forControlEvents:UIControlEventTouchUpInside];
    [closebutton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closebutton setFrame:CGRectMake(5, 5, 40, 40)];
    [headerView addSubview:closebutton];
    return headerView;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)closeSignUp{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 80;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"Offsetpoit - %@",NSStringFromCGPoint(self.signUpTable.contentOffset));
    /*if ((self.signUpTable.contentOffset.y > SCROLL_OFFSET_HEADER_SHRINK &&
         self.signUpTable.tableHeaderView.frame.size.height > 80) ||
        self.signUpTable.contentOffset.y < SCROLL_OFFSET_HEADER_SHRINK) {
        [self.signUpTable reloadData];
    }*/
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.5 animations:^{
        [_signUpTable setContentOffset:CGPointMake(0, 20 + (textField.tag*40))];
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.5 animations:^{
        [_signUpTable setContentOffset:CGPointMake(0, 0)];
    } completion:^(BOOL finished) {
    
    }];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)tapOnLink:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(IBAction)signUp:(id)sender{
    NSError *error;
    NSString *noteDataString;
    //[self.payloadDictionary setObject:@"" forKey:@"domain_name"];
    for (int i =0; i < _keysArray.count; i++) {
        LoginTableViewCell* cell = [self.signUpTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (cell.inputField.text.length != 0) {
            [self.payloadDictionary setObject:cell.inputField.text forKey:self.keysArray[i]];
        }
        [cell.inputField resignFirstResponder];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.payloadDictionary
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
        
        NSString *url = @"http://happytodo.int2root.com/v1/signup";
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        request.HTTPBody = jsonData;
        request.HTTPMethod = @"POST";
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [[AppDelegate getAppDelegate] showActivityIndicator:NO];
            if (!error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if (httpResponse.statusCode == 200){
                    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
                    NSLog(@"response - %@",jsonData);
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        [_controller fillLoginValues:@[self.payloadDictionary[@"email"],self.payloadDictionary[@"password"],self.payloadDictionary[@"domain_name"]]];
                    }];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
