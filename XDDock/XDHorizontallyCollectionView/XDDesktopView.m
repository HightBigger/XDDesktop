//
//  XDDesktopView.m
//  XDDock
//
//  Created by xiaoda on 2019/4/9.
//  Copyright © 2019 xiaoda. All rights reserved.
//

#import "XDDesktopView.h"
#import "XDDockView.h"
#import "XDDeskView.h"

int const DOCKSECTION = 10000;

int const CHANGEMARGIN = 30;

@interface XDDesktopView()<XDDesktopCellDelegate,XDDockViewDelegate,XDDeskViewDelegate,UIScrollViewDelegate>

#pragma mark - 布局
//desk
@property (nonatomic, strong) XDDeskView *xdDeskView;

@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, assign) NSInteger columns;
@property (nonatomic, strong) Class cellClass;
@property (nonatomic, strong) NSString *identifier;

//pagecontroller
@property (nonatomic, strong) UIPageControl *pageControl;

//dock
@property (nonatomic, strong) XDDockView *xdDockView;

#pragma mark - 拖拽相关
@property (nonatomic, assign) BOOL editMode;

@property (nonatomic, assign) BOOL canRoll;

@property (nonatomic, weak) XDDesktopCell *activeCell;
@property (nonatomic, weak) UIView *activeView;
@property (nonatomic, weak) UIView *sourceView;

@property (nonatomic, strong) UIView *snapViewForActiveCell;
@property (nonatomic, assign) CGPoint centerOffset;

@property (nonatomic, strong) NSIndexPath *activeXDPath;
@property (nonatomic, strong) NSIndexPath *sourceXDPath;

@end


@implementation XDDesktopView

#pragma mark - API
+ (instancetype)desktopViewWithRows:(NSInteger)rows
                            columns:(NSInteger)columns
                      registerClass:(Class)cellClass
                         identifier:(NSString *)identifier
{
    return [[self alloc]initWithRows:rows columns:columns registerClass:cellClass identifier:identifier];
}

- (instancetype)initWithRows:(NSInteger)rows
                     columns:(NSInteger)columns
               registerClass:(Class)cellClass
                  identifier:(NSString *)identifier
{
    self = [super init];
    if (self)
    {
        self.rows = rows;
        self.columns = columns;
        self.cellClass = cellClass;
        self.identifier = identifier;
        self.dockMax = 4;
        self.editMode = NO;
        
        [self addSubview:self.xdDeskView];
        [self addSubview:self.pageControl];
        [self addSubview:self.xdDockView];
        
        [self.xdDeskView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.xdDeskView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [self.xdDeskView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        [self.xdDeskView.bottomAnchor constraintEqualToAnchor:self.xdDockView.topAnchor].active = YES;
        
//        [self.pageControl.topAnchor constraintEqualToAnchor:self.xdDeskView.bottomAnchor constant:-40].active = YES;
        [self.pageControl.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [self.pageControl.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        [self.pageControl.bottomAnchor constraintEqualToAnchor:self.xdDockView.topAnchor].active = YES;
        [self.pageControl.heightAnchor constraintEqualToConstant:40].active = YES;
        
        [self.xdDockView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [self.xdDockView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        [self.xdDockView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.xdDockView.heightAnchor constraintEqualToConstant:120].active = YES;

    }
    return self;
}

- (XDDesktopCell *)dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath
{    
    XDDesktopCell *cell = [[self.cellClass alloc] init];
    
    cell.delegate = self;
    
    cell.indexPath = indexPath;
    
    return cell;
}

- (void)editingMode:(BOOL)editing
{
    self.editMode = editing;
    
//    [self.xdDeskView editMode:editing];
//
//    self.pageControl.numberOfPages = editing ? self.xdDeskView.pageCount + 2 : self.xdDeskView.pageCount;
}

- (void)reloadData
{
    [self.xdDeskView reloadData];
    
    [self.xdDockView reloadData];
}

- (void)setPage:(NSInteger )page animate:(BOOL)animate
{
    if (animate) {
        [UIView animateWithDuration:0.25 animations:^{
            self.xdDeskView.contentOffset = CGPointMake(self.xdDeskView.bounds.size.width * page, 0);
        } completion:^(BOOL finished) {
            [self.pageControl setCurrentPage:page+1];
        }];
        
        return;
    }
    
    self.xdDeskView.contentOffset = CGPointMake(self.xdDeskView.bounds.size.width * page, 0);
    
    [self.pageControl setCurrentPage:page+1];
}

#pragma mark - dockview代理
- (NSInteger)numberOfItemsInDockView:(XDDockView *)dockView
{
    return [self.delegate desktopView:self numberOfItemsInPage:DOCKSECTION];
}

- (XDDesktopCell *)dockView:(XDDockView *)xdDockView cellForItemAtIndex:(NSInteger)index
{
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:index inSection:DOCKSECTION];
    
    XDDesktopCell *cell = [self.delegate desktopView:self cellForItemAtIndexPath:newPath];
    
    return cell;
}

#pragma mark - deskView代理
- (NSInteger)numberOfPagesInDeskView:(XDDeskView *)deskView
{
    NSInteger pages = [self.delegate numberOfPagesInDesktopView:self];
    
    self.pageControl.numberOfPages = pages + 1;
    
    return pages;
}

- (NSInteger)deskView:(XDDeskView *)xdDeskView numberOfItemsInPage:(NSInteger)page
{
    return [self.delegate desktopView:self numberOfItemsInPage:page];
}

- (XDDesktopCell *)deskView:(XDDeskView *)xdDeskView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{    
    XDDesktopCell *cell = [self.delegate desktopView:self cellForItemAtIndexPath:indexPath];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = [self getCurrentPage];
    
    [self.pageControl setCurrentPage:page +1];
}

#pragma mark - cell代理
- (void)clickGestureForCell:(XDDesktopCell *)cell indexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(desktopView:didSelectItemAtIndexPath:)])
    {
        [self.delegate desktopView:self didSelectItemAtIndexPath:indexPath];
    }
}

- (void)longGestureForCell:(XDDesktopCell *)cell gesture:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self handleGestureBeganWithCell:cell gesture:gesture];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self handleEditingMoveWhenGestureChanged:gesture];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self handleEditingMoveWhenGestureEnded:gesture];
            break;
        }
        default: {
            [self handleEditingMoveWhenGestureEnded:gesture];
            break;
        }
    }
}

#pragma mark - action
- (void)handleGestureBeganWithCell:(XDDesktopCell *)cell gesture:(UILongPressGestureRecognizer *)recognizer
{
    if (!self.editMode) return;
    
    self.canRoll = YES;
    
    self.activeCell = cell;
    
    self.sourceXDPath = cell.indexPath;
    self.activeXDPath = cell.indexPath;
    
    self.snapViewForActiveCell = [cell snapshotViewAfterScreenUpdates:YES];
    
    CGPoint pressPoint = [recognizer locationInView:self];
    
    if (CGRectContainsPoint(self.xdDeskView.frame, pressPoint)) {
        self.sourceView = self.xdDeskView;
        self.activeView = self.xdDeskView;
    }
    else if (CGRectContainsPoint(self.xdDockView.frame, pressPoint))
    {
        self.sourceView = self.xdDockView;
        self.activeView = self.xdDockView;
    }
    
    CGRect realFrame = [self.activeView convertRect:cell.frame toView:self];
    self.centerOffset = CGPointMake(pressPoint.x - CGRectGetMidX(realFrame), pressPoint.y - CGRectGetMidY(realFrame));
    
    self.snapViewForActiveCell.frame = realFrame;
    
    cell.hidden = YES;
    
    [self addSubview:self.snapViewForActiveCell];
}

- (void)handleEditingMoveWhenGestureChanged:(UILongPressGestureRecognizer *)recognizer{
    
    CGPoint pressPoint = [recognizer locationInView:self];

    self.snapViewForActiveCell.center = CGPointMake(pressPoint.x - _centerOffset.x, pressPoint.y - _centerOffset.y);

    if (CGRectContainsPoint(self.xdDeskView.frame, pressPoint))
    {
        self.activeView = self.xdDeskView;
    }
    else if (CGRectContainsPoint(self.xdDockView.frame, pressPoint))
    {
        self.activeView = self.xdDockView;
    }
    
    //handleExchangeOperation
    if (self.sourceView == self.activeView)
    {
        [self moveInSameView];
    }
    else
    {
        if (self.activeView == self.xdDockView)
        {
            [self dragToDockView];
        }
        else if (self.activeView == self.xdDeskView)
        {
            [self dragToDeskView];
        }
    }
}

- (void)handleEditingMoveWhenGestureEnded:(UILongPressGestureRecognizer *)recognizer
{
    self.canRoll = NO;
    
    if ([self.sourceXDPath isEqual:self.activeXDPath]) {
        if ([self.delegate respondsToSelector:@selector(desktopView:moveItemAtIndexPath:toIndexPath:)]) {
            [self.delegate desktopView:self moveItemAtIndexPath:self.sourceXDPath toIndexPath:self.activeXDPath];
        }
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        
        CGRect realFrame = [self.activeView convertRect:self.activeCell.frame toView:self];
        
        self.snapViewForActiveCell.frame = realFrame;
        
    } completion:^(BOOL finished) {
        [self.snapViewForActiveCell removeFromSuperview];
        self.activeCell.hidden = NO;
    }];

//    [self.deskView reloadData];
//    [self.dockView reloadData];
}

#pragma mark - method
- (void)dragToDockView
{
    //deskView 拖拽到dockView
    NSInteger num = [self.xdDockView numberOfItemsInDock];
    
    if (num == self.dockMax) return;
    
    NSIndexPath *insertPath;
    
    CGFloat snapCenterX = CGRectGetMidX(self.snapViewForActiveCell.frame);
    
    NSIndexPath *firstPath = [NSIndexPath indexPathForRow:0 inSection:DOCKSECTION];
    //判断是否为第一个
    XDDesktopCell *cell = [self.xdDockView cellForItemAtIndexPath:firstPath];
    
    if (!cell) {
        insertPath = firstPath;
    }else
    {
        CGRect realFrame = [self.xdDockView convertRect:cell.frame toView:self];
        if (snapCenterX <= CGRectGetMidX(realFrame)) {
            insertPath = firstPath;
        }
    }
    
    if (!insertPath) {
        //判断是否为最后一个,到这里num已经大于0了
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:num-1 inSection:DOCKSECTION];
        
        cell = [self.xdDockView cellForItemAtIndexPath:lastPath];
        CGRect realFrame = [self.xdDockView convertRect:cell.frame toView:self];
        
        if (snapCenterX > CGRectGetMidX(realFrame)) {
            insertPath = [NSIndexPath indexPathForRow:num inSection:DOCKSECTION];
        }
    }
    
    if (!insertPath) {
        //既不是第一个也不是最后一个，这里num已经大于1
        for (int i = 0; i < num ; i++)
        {
            NSIndexPath *forwardPath = [NSIndexPath indexPathForRow:i inSection:DOCKSECTION];
            NSIndexPath *nextPath = [NSIndexPath indexPathForRow:i+1 inSection:DOCKSECTION];
            
            XDDesktopCell *forwardCell = [self.xdDockView cellForItemAtIndexPath:forwardPath];
            XDDesktopCell *nextCell = [self.xdDockView cellForItemAtIndexPath:nextPath];
            
            if (forwardCell && nextCell) {
                
                CGRect forwarFrame = [self.xdDockView convertRect:forwardCell.frame toView:self];
                CGRect nextFrame = [self.xdDockView convertRect:nextCell.frame toView:self];
                
                //大于左边的，小于等于右边的
                if (snapCenterX > CGRectGetMidX(forwarFrame) && snapCenterX <= CGRectGetMidX(nextFrame)) {
                    insertPath = nextPath;
                    break;
                }
            }
        }
    }
    
    if (insertPath) {
        [self.xdDockView insertItem:self.activeCell atIndexPath:insertPath];
        self.activeXDPath = insertPath;
        
        self.sourceView = self.xdDockView;
    }
}


- (void)dragToDeskView
{
    //dockView to deskView
    NSIndexPath *insertPath;
    
    for (XDDesktopCell *cell in self.xdDeskView.subviews)
    {
        CGRect realFrame = [self.xdDeskView convertRect:cell.frame toView:self];
        if (CGRectContainsPoint(realFrame, self.snapViewForActiveCell.center))
        {
            insertPath = cell.indexPath;
            break;
        }
    }
    
    NSInteger section = [self getCurrentPage];
    
    NSInteger num = [self.xdDeskView numberOfItemsInSection:section];
    
    if (!insertPath && num >= self.columns * self.rows)
    {
        self.activeView = self.xdDockView;
    }
    else
    {
        [self.xdDockView removeItem:self.activeCell release:NO];
        
        if (!insertPath) {
            insertPath = [NSIndexPath indexPathForRow:num inSection:section];
        }
        
        [self.xdDeskView insertItem:self.activeCell atIndexPath:insertPath];
        
        self.activeXDPath = insertPath;
        
        self.sourceView = self.xdDeskView;
    }
}

- (void)moveInSameView
{
    //Determine if it is in a blank space
    if ([self snapViewInSpace] && self.activeView == self.xdDeskView)
    {
        NSInteger currentPage = [self getCurrentPage];
        
        if (currentPage == self.activeXDPath.section)
        {
            NSInteger num = [self.xdDeskView numberOfItemsInSection:currentPage];
            
            NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:num - 1 inSection:currentPage];
            
            [self handleCellExchangeWithSourceIndexPath:self.activeXDPath destinationIndexPath:lastIndex];
            
            self.activeXDPath = lastIndex;
        }
        else
        {
            NSIndexPath *insertPath;
            
            for (XDDesktopCell *cell in self.xdDeskView.subviews)
            {
                CGRect realFrame = [self.activeView convertRect:cell.frame toView:self];
                if (CGRectContainsPoint(realFrame, self.snapViewForActiveCell.center))
                {
                    insertPath = cell.indexPath;
                    break;
                }
            }
            
            NSInteger num = [self.xdDeskView numberOfItemsInSection:currentPage];
            
            if (insertPath)
            {
                [self.xdDeskView insertItem:self.activeCell atIndexPath:insertPath];
                self.activeXDPath = insertPath;
            }else
            {
                if (num < self.columns * self.rows)
                {
                    if (!insertPath){
                        insertPath = [NSIndexPath indexPathForRow:num inSection:currentPage];
                    }
                    
                    [self.xdDeskView insertItem:self.activeCell atIndexPath:insertPath];
                    self.activeXDPath = insertPath;
                }
            }
        }
    
        if (self.canRoll)
        {
            NSInteger increment = 0;
            //turn to left
            if (CGRectGetMidX(self.snapViewForActiveCell.frame) < CHANGEMARGIN ){
                //current page is the first ,deskview can not turn to left
                if (currentPage > 0) {
                    increment = -1;
                }
            }
            
            //turn to right
            if (CGRectGetMidX(self.snapViewForActiveCell.frame) > CGRectGetWidth(self.frame) - CHANGEMARGIN){
                //current page is the last ,deskview can not turn to right
                if (currentPage < self.xdDeskView.pageCount-1) {
                    increment = 1;
                }
            }
            
            if (increment != 0) {
                self.canRoll = NO;
                [self setPage:currentPage + increment animate:YES];
                
                //interval of change page
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.canRoll = YES;
                });
            }
        }
    }
    else
    {
        for (XDDesktopCell *cell in self.activeView.subviews)
        {
            NSIndexPath *currentIndexPath = cell.indexPath;
            
            if ([currentIndexPath isEqual:self.activeXDPath]) continue;
            
            CGRect realFrame = [self.activeView convertRect:cell.frame toView:self];
            
            if (CGRectContainsPoint(realFrame, self.snapViewForActiveCell.center))
            {
                [self handleCellExchangeWithSourceIndexPath:self.activeXDPath destinationIndexPath:currentIndexPath];
                self.activeXDPath = currentIndexPath;
                break;
            }
        }
    }
}

- (void)handleCellExchangeWithSourceIndexPath:(NSIndexPath *)sourceIndexPath
                         destinationIndexPath:(NSIndexPath *)toIndexPath
{
    NSInteger sourceIndex;
    NSInteger toIndex;
    
    if (self.activeView == self.xdDeskView)
    {
        NSInteger pageCount = self.columns *self.rows;
        sourceIndex = sourceIndexPath.section * pageCount + sourceIndexPath.row;
        toIndex = toIndexPath.section * pageCount + toIndexPath.row;
    }
    else
    {
        sourceIndex = sourceIndexPath.row;
        toIndex = toIndexPath.row;
    }
    
    NSInteger activeRange = toIndex - sourceIndex;
    BOOL moveForward = activeRange > 0;
    NSInteger originIndex = 0;
    NSInteger targetIndex = 0;

    for (NSInteger i = 1; i <= labs(activeRange); i ++) {

        NSInteger moveDirection = moveForward?1:-1;
        originIndex = sourceIndexPath.item + i*moveDirection;
        targetIndex = originIndex - 1*moveDirection;

        NSIndexPath *originIndexPath = [NSIndexPath indexPathForItem:originIndex inSection:sourceIndexPath.section];
        NSIndexPath *targetIndexPath = [NSIndexPath indexPathForItem:targetIndex inSection:sourceIndexPath.section];

        if (self.activeView == self.xdDeskView) {
            [self.xdDeskView moveItemAtIndexPath:originIndexPath toIndexPath:targetIndexPath];
        }
        
        if (self.activeView == self.xdDockView) {
            [self.xdDockView moveItemAtIndexPath:originIndexPath toIndexPath:targetIndexPath];
        }
    }
}

- (BOOL)snapViewInSpace
{
    NSInteger currentPage = [self getCurrentPage];
    
    NSInteger num = [self.xdDeskView numberOfItemsInSection:currentPage];
    
    if (num % self.columns == 0) {
        
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:num - 1 inSection:currentPage];
        
        XDDesktopCell *cell = [self.xdDeskView cellForItemAtIndexPath:lastIndex];
        
        CGRect realFrame = [self.xdDeskView convertRect:cell.frame toView:self];
        
        CGRect activeFrame = CGRectMake(CHANGEMARGIN, 0, self.xdDeskView.frame.size.width-2*CHANGEMARGIN, CGRectGetMaxY(realFrame));
        
        return !CGRectContainsPoint(activeFrame, self.snapViewForActiveCell.center);
    }else
    {
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:num - 1 inSection:currentPage];
        
        XDDesktopCell *cell = [self.xdDeskView cellForItemAtIndexPath:lastIndex];
        
        CGRect realFrame = [self.xdDeskView convertRect:cell.frame toView:self];
        
        CGRect activeFrame = CGRectMake(CHANGEMARGIN, 0, CGRectGetMaxX(realFrame), CGRectGetMaxY(realFrame));
        
        BOOL contain1 = CGRectContainsPoint(activeFrame, self.snapViewForActiveCell.center);
        
        NSIndexPath *lastButOne = [NSIndexPath indexPathForRow:(num -1) - (num % self.columns) inSection:currentPage];

        cell = [self.xdDeskView cellForItemAtIndexPath:lastButOne];
        
        realFrame = [self.xdDeskView convertRect:cell.frame toView:self];
        
        activeFrame = CGRectMake(CHANGEMARGIN, 0, self.xdDeskView.frame.size.width - 2*CHANGEMARGIN, CGRectGetMaxY(realFrame));
        
        BOOL contain2 = CGRectContainsPoint(activeFrame, self.snapViewForActiveCell.center);
        
        return !contain1 && !contain2;
    }
}


//从0开始
- (NSInteger)getCurrentPage
{
    NSInteger page = self.xdDeskView.contentOffset.x/self.xdDeskView.bounds.size.width;
    
    return page;
}

#pragma mark - lazyLoad
- (XDDeskView *)xdDeskView
{
    if (!_xdDeskView) {
        _xdDeskView = [XDDeskView deskViewWithRows:self.rows columns:self.columns];
        _xdDeskView.deskDelegate = self;
        _xdDeskView.delegate = self;
        [_xdDeskView setItemSize:CGSizeMake(80, 95) edgeInsets:UIEdgeInsetsMake(20, 40, 45, 40)];
        _xdDeskView.translatesAutoresizingMaskIntoConstraints = NO;
        _xdDeskView.backgroundColor = [UIColor blueColor];
    }
    return _xdDeskView;
}

- (XDDockView *)xdDockView
{
    if (!_xdDockView) {
        _xdDockView = [XDDockView dockViewWithMaxcount:self.dockMax];
        _xdDockView.delegate = self;
        [_xdDockView setItemSize:CGSizeMake(80, 95) edgeInsets:UIEdgeInsetsMake(5, 40, 25, 40)];
        _xdDockView.translatesAutoresizingMaskIntoConstraints = NO;
        _xdDockView.backgroundColor = [UIColor grayColor];
    }
    return _xdDockView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0xCC/255.0f alpha:1];
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _pageControl;
}


@end
