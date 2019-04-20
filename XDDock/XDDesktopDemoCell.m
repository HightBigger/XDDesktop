//
//  XDDesktopDemoCell.m
//  XDDock
//
//  Created by xiaoda on 2019/4/18.
//  Copyright © 2019 xiaoda. All rights reserved.
//

#import "XDDesktopDemoCell.h"

@interface XDDesktopDemoCell()

@property(nonatomic,strong)UILabel *lab;

@end

@implementation XDDesktopDemoCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.lab = [[UILabel alloc] init];
        self.lab.backgroundColor = [UIColor whiteColor];
        self.lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lab];
        
        self.lab.translatesAutoresizingMaskIntoConstraints = NO;
        [self.lab.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.lab.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [self.lab.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        [self.lab.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    }
    return self;
}

- (void)setTitleNum:(NSString*)title
{
    self.lab.text = title;
}

@end
