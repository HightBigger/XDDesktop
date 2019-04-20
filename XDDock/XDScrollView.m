//
//  XDScrollView.m
//  XDDock
//
//  Created by xiaoda on 2019/4/9.
//  Copyright © 2019 xiaoda. All rights reserved.
//

#import "XDScrollView.h"

@implementation XDScrollView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer.view isKindOfClass:self.class]) {
        if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
            /*
             第二页向右手势取消响应
             */
            UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)gestureRecognizer;
            
            CGPoint velocity = [pan velocityInView:pan.view];
            
            XDScrollView *scrollView = (XDScrollView*)gestureRecognizer.view;
            
            NSInteger page = scrollView.contentOffset.x/scrollView.bounds.size.width + 1;
            
            NSInteger count = scrollView.contentSize.width/scrollView.bounds.size.width;
            
            if (page == count && velocity.x < 0) {
                return NO;
            }
        }
    }
    return YES;
}


@end
