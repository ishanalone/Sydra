//
//  NSString+Validations.m
//  Sydra
//
//  Created by Ishan Alone on 08/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "NSString+Validations.h"


@implementation NSString (Validations)

-(BOOL)isValidEmail{
    NSString *emailRegex = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}
-(void)isValidPassword{
    
}


@end
