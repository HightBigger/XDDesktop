//
//  XDDeskView.h
//  XDDock
//
//  Created by xiaoda on 2019/4/19.
//  Copyright © 2019 xiaoda. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XDDeskView,XDDesktopCell;
@protocol XDDeskViewDelegate <NSObject>
@required

/**
 Number of cells per page
 
 @param xdDeskView deskView
 @param page current page.
 @return number of current page
 */
- (NSInteger)deskView:(XDDeskView *)xdDeskView numberOfItemsInPage:(NSInteger)page;

/**
 The cell that is returned
 
 @param xdDeskView xdDeskView
 @param indexPath indexPath
 @return cell
 */
- (__kindof XDDesktopCell *)deskView:(XDDeskView *)xdDeskView cellForItemAtIndexPath:(NSIndexPath*)indexPath;

@optional

/**
 Number of pages of deskView,default 1
 
 @param deskView deskView
 @return number of pages
 */
- (NSInteger)numberOfPagesInDeskView:(XDDeskView *)deskView;


/**
 Methods for notification of highlight events when the touch lifts.
 
 @param xdDeskView xdDeskView
 @param indexPath index of the touch
 */
- (void)desktopView:(XDDeskView *)xdDeskView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface XDDeskView : UIScrollView

@property (nonatomic, weak) id <XDDeskViewDelegate> deskDelegate;

+ (instancetype)deskViewWithRows:(NSInteger)rows
                         columns:(NSInteger)columns;

- (void)setItemSize:(CGSize)itemSize
         edgeInsets:(UIEdgeInsets)edgeInsets;

- (void)reloadData;

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)insertItem:(XDDesktopCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (nullable XDDesktopCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;



@end

NS_ASSUME_NONNULL_END
