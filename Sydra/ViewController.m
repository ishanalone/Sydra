//
//  ViewController.m
//  Sydra
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "ViewController.h"
#import "LoginTableViewCell.h"
#import "AppDelegate.h"
#import "SignUpController.h"
#import "KeychainWrapper.h"

@interface ViewController ()
@property (nonatomic,strong) NSArray* inputArray;
@property (nonatomic,strong) NSArray* keysArray;
@property (nonatomic,strong) NSMutableDictionary* payloadDictionary;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inputArray = @[@"Email",@"Password",@"Domain"];
    self.keysArray = @[@"email",@"password",@"domain_name"];
    // Do any additional setup after loading the view, typically from a nib.
    [[AppDelegate getAppDelegate] buildAgreeTextViewFromString:@"DON'T HAVE AN ACCOUNT?  #<si>SIGN UP#" atContainer:self.container andController:self];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.logoImage.center = CGPointMake(CGRectGetMidX(screenBounds), self.logoImage.frame.size.height/2 + 30);
    self.payloadDictionary = [[NSMutableDictionary alloc] init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.inputArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LoginTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LoginTableViewCell" forIndexPath:indexPath];
    cell.inputField.placeholder = self.inputArray[indexPath.row];
    return cell;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.5 animations:^{
        [_loginTable setContentOffset:CGPointMake(0, 150)];
        [self.logoImage setFrame:CGRectMake(40, self.logoLabel.frame.origin.y+20, 40, 40)];
    } completion:^(BOOL finished) {
        [_loginTable setScrollEnabled:false];
    }];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.5 animations:^{
        [_loginTable setContentOffset:CGPointMake(0, 0)];
        [self.logoImage setFrame:CGRectMake(40, self.logoLabel.frame.origin.y+20, 139, 139)];
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        self.logoImage.center = CGPointMake(CGRectGetMidX(screenBounds), self.logoImage.frame.size.height/2 + 30);
    } completion:^(BOOL finished) {
        [_loginTable setScrollEnabled:true];
    }];
   
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)fillLoginValues:(NSArray*)array{
    for (int i = 0; i < self.inputArray.count; i++) {
        LoginTableViewCell* cell = [self.loginTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.inputField.text = array[i];
    }
}

- (void)tapOnLink:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        [self performSegueWithIdentifier:@"SignUp" sender:nil];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    SignUpController* controller = segue.destinationViewController;
    controller.controller = self;
}

-(IBAction)signIn:(id)sender{
    NSError *error;
    NSString *noteDataString;
    //[self.payloadDictionary setObject:@"" forKey:@"domain_name"];
    for (int i =0; i < _keysArray.count; i++) {
        LoginTableViewCell* cell = [self.loginTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
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
        
        NSString *url = @"http://happytodo.int2root.com/v1/signin";
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
        
                    [[NSUserDefaults standardUserDefaults] setObject:jsonData[@"auth_token"] forKey:@"token"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

@end
