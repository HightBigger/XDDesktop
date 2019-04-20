//
//  ViewController.m
//  XDDock
//
//  Created by xiaoda on 2019/4/3.
//  Copyright © 2019 xiaoda. All rights reserved.
//

#import "ViewController.h"
#import "XDDesktopViewController.h"
#import "XDInfoViewController.h"
#import "XDScrollView.h"

@interface ViewController ()<UIScrollViewDelegate>

@property(nonatomic,strong) UIPageViewController *pageViewController;

@property(nonatomic,strong) XDInfoViewController *infoViewController;

@property(nonatomic,strong) XDDesktopViewController *deskViewController;

@property(nonatomic,strong) XDScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0)];
}

#pragma mark - setView
- (void)setupView
{
    [self.view setBackgroundColor:[UIColor greenColor]];
    
    [self.view addSubview:self.scrollView];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.scrollView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.scrollView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;

    [self addChildViewController:self.infoViewController];
    [self addChildViewController:self.deskViewController];

    [self.scrollView addSubview:self.infoViewController.view];

    self.infoViewController.view.translatesAutoresizingMaskIntoConstraints = NO;

    [self.infoViewController.view.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor].active = YES;
    [self.infoViewController.view.leftAnchor constraintEqualToAnchor:self.scrollView.leftAnchor].active = YES;
    [self.infoViewController.view.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor].active = YES;
    [self.infoViewController.view.heightAnchor constraintEqualToAnchor:self.scrollView.heightAnchor].active = YES;

    [self.scrollView addSubview:self.deskViewController.view];
    self.deskViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deskViewController.view.leftAnchor constraintEqualToAnchor:self.infoViewController.view.rightAnchor].active = YES;
    [self.deskViewController.view.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor].active = YES;
    [self.deskViewController.view.rightAnchor constraintEqualToAnchor:self.scrollView.rightAnchor].active = YES;
    [self.deskViewController.view.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor].active = YES;
    [self.deskViewController.view.heightAnchor constraintEqualToAnchor:self.scrollView.heightAnchor].active = YES;
}

#pragma mark - lazyload
- (XDScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[XDScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = YES;
        _scrollView.backgroundColor = [UIColor greenColor];
    }
    return _scrollView;
}

- (XDInfoViewController *)infoViewController
{
    if (!_infoViewController) {
        _infoViewController = [XDInfoViewController new];
    }
    
    return _infoViewController;
}

- (XDDesktopViewController *)deskViewController
{
    if (!_deskViewController) {
        _deskViewController = [XDDesktopViewController new];
    }
    return _deskViewController;
}

@end
