//
//  XDDockView.h
//  XDDock
//
//  Created by xiaoda on 2019/4/18.
//  Copyright © 2019 xiaoda. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class XDDockView,XDDesktopCell;

@protocol XDDockViewDelegate <NSObject>
@required
/**
 Number of items of dockView
 
 @param dockView desktopView
 @return number of items
 */
- (NSInteger)numberOfItemsInDockView:(XDDockView *)dockView;

- (__kindof XDDesktopCell *)dockView:(XDDockView *)xdDockView cellForItemAtIndex:(NSInteger)index;

@end

@interface XDDockView : UIView

@property (nonatomic, weak) id <XDDockViewDelegate> delegate;

+ (instancetype)dockViewWithMaxcount:(NSInteger)maxCount;

- (void)setItemSize:(CGSize)itemSize
         edgeInsets:(UIEdgeInsets)edgeInsets;

- (void)reloadData;

- (NSInteger)numberOfItemsInDock;

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;

- (void)insertItem:(XDDesktopCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)removeItem:(XDDesktopCell *)cell release:(BOOL)release;

- (nullable XDDesktopCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
