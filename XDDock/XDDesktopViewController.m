//
//  XDDesktopViewController.m
//  XDDock
//
//  Created by xiaoda on 2019/4/4.
//  Copyright © 2019 xiaoda. All rights reserved.
//

#import "XDDesktopViewController.h"
#import "XDDesktopView.h"
#import "XDDesktopDemoCell.h"

@interface XDDesktopViewController ()<XDDesktopViewDelegate>

@property(nonatomic,strong)XDDesktopView *xdcollectionView;

@property(nonatomic,strong)NSMutableArray *dockArray;
@property(nonatomic,strong)NSMutableArray *deskArray0;
@property(nonatomic,strong)NSMutableArray *deskArray1;
@property(nonatomic,strong)NSMutableArray *deskArray2;

@end

@implementation XDDesktopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dockArray = [NSMutableArray arrayWithCapacity:0];
    self.deskArray0 = [NSMutableArray arrayWithCapacity:0];
    self.deskArray1 = [NSMutableArray arrayWithCapacity:0];
    self.deskArray2 = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < 3; i++) {
        [self.dockArray addObject:[NSNumber numberWithInt:i]];
    }
    
    for (int i = 0; i < 17; i++) {
        [self.deskArray0 addObject:[NSNumber numberWithInt:i]];
    }
    
    for (int i = 0; i < 11; i++) {
        [self.deskArray1 addObject:[NSNumber numberWithInt:i]];
    }
    
    for (int i = 0; i < 3; i++) {
        [self.deskArray2 addObject:[NSNumber numberWithInt:i]];
    }
    
    [self setupView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.xdcollectionView editingMode:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.xdcollectionView reloadData];
}

- (void)setupView
{
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:self.xdcollectionView];
    [self.xdcollectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:40].active = YES;
    [self.xdcollectionView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.xdcollectionView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.xdcollectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
}

#pragma mark - XDCollectionView代理
- (NSInteger)numberOfPagesInDesktopView:(XDDesktopView *)desktopView
{
    return 3;
}

- (NSInteger)desktopView:(XDDesktopView *)desktopView numberOfItemsInPage:(NSInteger)page{
    if (page == DOCKSECTION) {
        return self.dockArray.count;
    }
    if (page == 0) {
        return self.deskArray0.count;
    }
    if (page == 1) {
        return self.deskArray1.count;
    }
    if (page == 2) {
        return self.deskArray2.count;
    }
    
    return 7;
}

- (XDDesktopCell *)desktopView:(XDDesktopView *)desktopView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XDDesktopDemoCell *cell = [desktopView dequeueReusableCellForIndexPath:indexPath];
    
    if (indexPath.section == DOCKSECTION) {
        NSInteger num = [self.dockArray[indexPath.row] integerValue];
        [cell setTitleNum:[NSString stringWithFormat:@"dock:%ld",(long)num]];
    }
    if (indexPath.section == 0) {
        NSInteger num = [self.deskArray0[indexPath.row] integerValue];
        [cell setTitleNum:[NSString stringWithFormat:@"desk:%ld",(long)num]];
    }
    if (indexPath.section == 1) {
        NSInteger num = [self.deskArray1[indexPath.row] integerValue];
        [cell setTitleNum:[NSString stringWithFormat:@"desk:%ld",(long)num]];
    }
    if (indexPath.section == 2) {
        NSInteger num = [self.deskArray2[indexPath.row] integerValue];
        [cell setTitleNum:[NSString stringWithFormat:@"desk:%ld",(long)num]];
    }

    return cell;
}

- (void)desktopView:(XDDesktopView *)desktopView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)desktopView:(XDDesktopView *)desktopView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSNumber *source;
    if (sourceIndexPath.section == DOCKSECTION) {
        source = self.dockArray[sourceIndexPath.row];
        [self.dockArray removeObjectAtIndex:sourceIndexPath.row];
    }
    
    if (sourceIndexPath.section == 0) {
        source = self.deskArray0[sourceIndexPath.row];
        [self.deskArray0 removeObjectAtIndex:sourceIndexPath.row];
    }
    
    
    if (sourceIndexPath.section == 1) {
        source = self.deskArray1[sourceIndexPath.row];
        [self.deskArray1 removeObjectAtIndex:sourceIndexPath.row];
    }
    
    if (sourceIndexPath.section == 2) {
        source = self.deskArray2[sourceIndexPath.row];
        [self.deskArray2 removeObjectAtIndex:sourceIndexPath.row];
    }
    
    if (destinationIndexPath.section == DOCKSECTION) {
        [self.dockArray insertObject:source atIndex:destinationIndexPath.row];
    }
    
    
    if (destinationIndexPath.section == 0) {
        [self.deskArray0 insertObject:source atIndex:destinationIndexPath.row];
    }
    
    
    if (destinationIndexPath.section == 1) {
        [self.deskArray1 insertObject:source atIndex:destinationIndexPath.row];
    }
    
    if (destinationIndexPath.section == 2) {
        [self.deskArray2 insertObject:source atIndex:destinationIndexPath.row];
    }    
}

- (void)desktopView:(XDDesktopView *)desktopView deleteItemAtIndexPath:(NSIndexPath *)sourceIndexPath
{
    if (sourceIndexPath.section == DOCKSECTION) {
        [self.dockArray removeObjectAtIndex:sourceIndexPath.row];
    }
}

#pragma mark - lazyLoad
- (XDDesktopView *)xdcollectionView
{
    if (!_xdcollectionView)
    {
        _xdcollectionView = [XDDesktopView desktopViewWithRows:7 columns:4 registerClass:[XDDesktopDemoCell class] identifier:@"UICollectionViewCell"];
        _xdcollectionView.backgroundColor = [UIColor brownColor];
        _xdcollectionView.delegate = self;
        _xdcollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    }

    return _xdcollectionView;
}

@end
