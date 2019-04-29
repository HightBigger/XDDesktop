//
//  XDDockView.m
//  XDDock
//
//  Created by xiaoda on 2019/4/18.
//  Copyright © 2019 xiaoda. All rights reserved.
//

#import "XDDockView.h"
#import "XDDesktopCell.h"

@interface XDDockView()

//xditem size
@property (nonatomic) CGSize xditemSize;
// 每页内边距
@property (nonatomic) UIEdgeInsets edgeInsets;

@property (nonatomic) NSInteger maxCount;
@end

@implementation XDDockView

+ (instancetype)dockViewWithMaxcount:(NSInteger)maxCount
{
    return [[self alloc] initWithMaxCount:maxCount];
}

- (instancetype)initWithMaxCount:(NSInteger)maxCount
{
    self = [super init];
    if (self) {
        self.maxCount = maxCount;
        
        UIPanGestureRecognizer *panPress = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPress:)];
        [self addGestureRecognizer:panPress];
    }
    return self;
}

- (void)panPress:(UILongPressGestureRecognizer*)longPress
{
    return;
}

- (void)setItemSize:(CGSize)itemSize
         edgeInsets:(UIEdgeInsets)edgeInsets
{
    self.xditemSize = itemSize;
    self.edgeInsets = edgeInsets;
}

- (void)reloadData
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger num = [self.delegate numberOfItemsInDockView:self];
    
    for (int i = 0; i<num; i++) {

        XDDesktopCell *cell = [self.delegate dockView:self cellForItemAtIndex:i];

        cell.frame = [self getFrameWithIndex:i count:num];

        [self addSubview:cell];
    }
    
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if ([indexPath isEqual:toIndexPath]) return;
    
    XDDesktopCell *sourceCell = [self cellForItemAtIndexPath:indexPath];
    XDDesktopCell *toCell = [self cellForItemAtIndexPath:toIndexPath];
    
    if (!sourceCell || !toCell) return;
    
    CGRect sourceFrame = sourceCell.frame;
    CGRect toFrame = toCell.frame;
    
    sourceCell.indexPath = toIndexPath;
    toCell.indexPath = indexPath;
    
    [UIView animateWithDuration:0.25f animations:^{
        sourceCell.frame = toFrame;
        toCell.frame = sourceFrame;
    }];
}

- (NSInteger)numberOfItemsInDock
{
    return self.subviews.count;
}

- (void)insertItem:(XDDesktopCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [self addSubview:cell];
    cell.frame = [self getFrameWithIndex:indexPath.row count:self.subviews.count];
    cell.indexPath = indexPath;
    
    [UIView animateWithDuration:0.25f animations:^{
        
        for (XDDesktopCell *subCell in self.subviews)
        {
            if (subCell != cell)
            {
                if (subCell.indexPath.row>=indexPath.row)
                {
                    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:subCell.indexPath.row+1 inSection:subCell.indexPath.section];
                    subCell.indexPath = newIndexPath;
                }
                subCell.frame = [self getFrameWithIndex:subCell.indexPath.row count:self.subviews.count];
            }
        }
    }];
}

- (void)removeItem:(XDDesktopCell *)cell release:(BOOL)release
{
    if (release) {
        [cell removeFromSuperview];
    }
    
    for (XDDesktopCell *subCell in self.subviews) {
        
        if (subCell == cell)  continue;
        
        if (subCell.indexPath.row > cell.indexPath.row) {
            subCell.indexPath = [NSIndexPath indexPathForRow:subCell.indexPath.row-1 inSection:cell.indexPath.section ];
        }
        
        [UIView animateWithDuration:0.25f animations:^{
            subCell.frame = [self getFrameWithIndex:subCell.indexPath.row count:self.subviews.count - 1];
        }];
    }

}

- (nullable XDDesktopCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XDDesktopCell *getCell;
    for (XDDesktopCell *cell in self.subviews)
    {
        if ([cell.indexPath isEqual:indexPath]) {
            getCell = cell;
            break;
        }
    }
    return getCell;
}

- (CGRect)getFrameWithIndex:(NSInteger)index count:(NSInteger)count
{
    CGFloat itemX = 0;
    
    if (count > 1) {
        CGFloat columnSpacing = (self.frame.size.width - self.edgeInsets.left - self.edgeInsets.right - self.xditemSize.width*self.maxCount)/(self.maxCount-1);
        CGFloat left = (self.frame.size.width - self.xditemSize.width*count - columnSpacing*(count-1))/2;
        
        itemX = left + index*(self.xditemSize.width + columnSpacing);
    }else{
        itemX = (self.frame.size.width - self.xditemSize.width)/2;
    }
    
    CGRect frame = CGRectMake(itemX, self.edgeInsets.top, self.xditemSize.width, self.xditemSize.height);
    
    return frame;
}


@end
