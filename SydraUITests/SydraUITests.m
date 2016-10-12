//
//  SydraUITests.m
//  SydraUITests
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface SydraUITests : XCTestCase
@property (nonatomic,strong) XCUIApplication* app;
@end

@implementation SydraUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.app = [[XCUIApplication alloc] init];
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = YES;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWrongCredential {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    
    XCUIElement *emailField = self.app.textFields[@"email"];
    [emailField tap];
    [emailField typeText:@"ishan@yopmail.com"];
    
    XCUIElement *passwordSecureTextField = self.app.secureTextFields[@"password"];
    [passwordSecureTextField tap];
    [passwordSecureTextField typeText:@"123"];
    
    XCUIElement *domainTextField = self.app.textFields[@"domain"];
    [domainTextField tap];
    [domainTextField typeText:@"current"];
    
    XCUIElement *loginbutton = self.app.buttons[@"Sign In"] ;
    [loginbutton tap];
    
    XCTAssert([self.app.otherElements containingType:XCUIElementTypeAlert identifier:@"Oops!!!"]);
    XCTAssert([self.app.alerts[@"Oops!!!"] exists]);
     [self.app.alerts[@"Oops!!!"].buttons[@"OK"] tap];
}

-(void)testInvalidEmail{
    
    XCUIElementQuery *tablesQuery = self.app.tables;
    
    XCUIElement *emailField = self.app.textFields[@"email"];
    [emailField tap];
    [emailField typeText:@"ishan@yopmail"];
    
    XCUIElement *passwordSecureTextField = self.app.secureTextFields[@"password"];
    [passwordSecureTextField tap];
    
   
    [emailField tap];
     [tablesQuery.buttons[@"Clear text"] tap];
    [emailField typeText:@"ishan.yopmail.com"];
    
    [passwordSecureTextField tap];
    
    [emailField tap];
    [tablesQuery.buttons[@"Clear text"] tap];
    [emailField typeText:@"@yopmail.com"];
    
    [passwordSecureTextField tap];
    
}

-(void)testEmptyFields{
    XCUIElement *loginbutton = self.app.buttons[@"Sign In"] ;
    [loginbutton tap]; // Check for empty email
    
    XCUIElement *emailField = self.app.textFields[@"email"];
    [emailField tap];
    [emailField typeText:@"ishan@yopmail.com"];
    
    [loginbutton tap]; // Check for empty password
    
    XCUIElement *passwordSecureTextField = self.app.secureTextFields[@"password"];
    [passwordSecureTextField tap];
    [passwordSecureTextField typeText:@"123"]; // // Check for empty domain
    
    [loginbutton tap];
    
}

-(void)testCorrectDetail{
    
    
    
    XCUIElement *emailField = self.app.textFields[@"email"];
    [emailField tap];
    [emailField typeText:@"ishan@yopmail.com"];
    
    XCUIElement *passwordSecureTextField = self.app.secureTextFields[@"password"];
    [passwordSecureTextField tap];
    [passwordSecureTextField typeText:@"temp123"];
    
    XCUIElement *domainTextField = self.app.textFields[@"domain"];
    [domainTextField tap];
    [domainTextField typeText:@"current"];
    
    XCUIElement *loginbutton = self.app.buttons[@"Sign In"] ;
    [loginbutton tap];
    
     [[[[[[[[[[[XCUIApplication alloc] init] childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:0] tap];
}

@end
