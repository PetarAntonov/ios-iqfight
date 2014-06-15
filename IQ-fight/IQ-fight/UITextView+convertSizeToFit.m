//
//  UITextView+convertSizeToFit.m
//  IQ-fight
//
//  Created by Petar Antonov on 6/15/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "UITextView+convertSizeToFit.h"

@implementation UITextView (convertSizeToFit)

- (void)convertSizeToFit
{
    self.bounces = YES;
    self.scrollEnabled = YES;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = YES;
    
    CGRect frame = self.frame;
    [self sizeToFit];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, frame.size.width, self.frame.size.height);
    
    self.bounces = NO;
    self.scrollEnabled = NO;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = NO;
}

@end
