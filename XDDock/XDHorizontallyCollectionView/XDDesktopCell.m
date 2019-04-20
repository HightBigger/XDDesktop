//
//  XDDesktopCell.m
//  XDDock
//
//  Created by xiaoda on 2019/4/11.
//  Copyright © 2019 xiaoda. All rights reserved.
//

#import "XDDesktopCell.h"

@interface XDDesktopCell()<UIGestureRecognizerDelegate>

@property (nonatomic , strong) UITapGestureRecognizer *clickGesture;

@property (nonatomic , strong) UILongPressGestureRecognizer *longGesture;

@end

@implementation XDDesktopCell

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self addGestureRecognizer:self.clickGesture];
        
        [self addGestureRecognizer:self.longGesture];
    }
    return self;
}

- (void)clickGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(clickGestureForCell:indexPath:)]) {
        [self.delegate clickGestureForCell:self indexPath:self.indexPath];
    }
}

- (void)longGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(longGestureForCell:gesture:)]) {
        [self.delegate longGestureForCell:self gesture:gestureRecognizer];
    }
}

- (UITapGestureRecognizer*)clickGesture
{
    if (!_clickGesture) {
        _clickGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickGesture:)];
    }
    return _clickGesture;
}

- (UILongPressGestureRecognizer*)longGesture
{
    if (!_longGesture) {
        _longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGesture:)];
        _longGesture.delegate = self;
        _longGesture.minimumPressDuration = 0.5f;
    }
    return _longGesture;
}

@end


