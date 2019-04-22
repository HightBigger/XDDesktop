//
//  XDDeskView.m
//  XDDock
//
//  Created by xiaoda on 2019/4/19.
//  Copyright © 2019 xiaoda. All rights reserved.
//

#import "XDDeskView.h"
#import "XDDesktopCell.h"

@interface XDDeskView()

// 行数
@property (nonatomic) NSInteger rows;
// 列数
@property (nonatomic) NSInteger columns;
// 页数
@property (nonatomic) NSInteger pageCount;
//xditem size
@property (nonatomic) CGSize xditemSize;
// 每页内边距
@property (nonatomic) UIEdgeInsets edgeInsets;

@end

@implementation XDDeskView

+ (instancetype)deskViewWithRows:(NSInteger)rows
                         columns:(NSInteger)columns
{
    return [[self alloc] initWithRows:rows columns:columns];
}

- (instancetype)initWithRows:(NSInteger)rows
                     columns:(NSInteger)columns
{
    self = [super init];
    if (self)
    {
        self.rows = rows;
        self.columns = columns;
        self.pageCount = 1;
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = YES;
    }
    
    return self;
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
    
    if ([self.deskDelegate respondsToSelector:@selector(numberOfPagesInDeskView:)])
    {
        self.pageCount = [self.deskDelegate numberOfPagesInDeskView:self];
    }
    
    CGFloat pageWidth = self.frame.size.width;

    self.contentSize = CGSizeMake(pageWidth * self.pageCount, self.frame.size.height);
    
    for (int page = 0; page<self.pageCount; page++) {
        
        NSInteger items = [self.deskDelegate deskView:self numberOfItemsInPage:page];
        
        for (int row = 0; row<items; row++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:page];
            
            XDDesktopCell *cell = [self.deskDelegate deskView:self cellForItemAtIndexPath:indexPath];
            
            cell.frame = [self layoutFrameForItemAtIndexPath:indexPath];
            
            [self addSubview:cell];
        }
    }
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if ([indexPath isEqual:toIndexPath]) return;
    
    XDDesktopCell *sourceCell = [self getCellAtIndexPath:indexPath];
    XDDesktopCell *toCell = [self getCellAtIndexPath:toIndexPath];
    
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

- (void)insertItem:(XDDesktopCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *removePath = [NSIndexPath indexPathForRow:self.columns* self.rows-1 inSection:indexPath.section];
    XDDesktopCell *removeCell = [self getCellAtIndexPath:removePath];
    
    for (XDDesktopCell *subCell in self.subviews)
    {
        if (subCell.indexPath.section == indexPath.section && subCell != cell && subCell.indexPath.row >= indexPath.row)
        {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:subCell.indexPath.row + 1 inSection:indexPath.section];
            subCell.indexPath = newIndexPath;
            [UIView animateWithDuration:0.25f animations:^{
                subCell.frame = [self layoutFrameForItemAtIndexPath:newIndexPath];
            }];
        }
    }
    
    cell.frame = [self layoutFrameForItemAtIndexPath:indexPath];
    cell.indexPath = indexPath;
    [self addSubview:cell];
    
    if (removeCell)
    {
        [removeCell removeFromSuperview];
        [self insertItem:removeCell atIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section+1]];
    }
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    
    for (XDDesktopCell *cell in self.subviews)
    {
        if (cell.indexPath.section ==  section) {
            [array addObject:cell];
        }
    }
    
    return array.count;
}

- (nullable XDDesktopCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XDDesktopCell *indexCell;
    
    for (XDDesktopCell *cell in self.subviews)
    {
        if ([cell.indexPath isEqual:indexPath]) {
            indexCell = cell;
            break;
        }
    }
    return indexCell;
}

- (XDDesktopCell *)getCellAtIndexPath:(NSIndexPath *)indexPath
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

- (CGRect)layoutFrameForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger page = indexPath.section;
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;

    NSInteger x = row % self.columns;
    NSInteger y = row / self.columns;
    
    CGFloat columnSpacing = (w - self.edgeInsets.left - self.edgeInsets.right - self.xditemSize.width*self.columns)/(self.columns-1);
    CGFloat lineSpacing = (h - self.edgeInsets.top - self.edgeInsets.bottom - self.xditemSize.height*self.rows)/(self.rows-1);

    CGFloat itemX = w * page + self.edgeInsets.left + x*(self.xditemSize.width + columnSpacing);
    CGFloat itemY = self.edgeInsets.top + y*(self.xditemSize.height + lineSpacing);

    CGRect frame = CGRectMake(itemX, itemY, self.xditemSize.width, self.xditemSize.height);
    
    return frame;
}

@end
