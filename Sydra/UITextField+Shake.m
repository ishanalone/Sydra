//
//  UITextField+Shake.m
//  Sydra
//
//  Created by Ishan Alone on 08/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "UITextField+Shake.h"

@implementation UITextField (Shake)

- (void)shake {
    [self shakeWithIterations:1 direction:2 size:3];
}

- (void)shakeWithIterations:(int)iterations direction:(int)direction size:(int)size {
    [UIView animateWithDuration:0.09-(iterations*.01) animations:^{
        self.transform = CGAffineTransformMakeTranslation(size*direction, 0);
    } completion:^(BOOL finished) {
        if (iterations >= 5 || size <= 0) {
            self.transform = CGAffineTransformIdentity;
            return;
        }
        [self shakeWithIterations:iterations+1 direction:direction*-1 size:MAX(0, size-1)];
    }];
}

@end
