//
//  XDDesktopView.h
//  XDDock
//
//  Created by xiaoda on 2019/4/9.
//  Copyright © 2019 xiaoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDDesktopCell.h"

/**
 控件结构
 |----------------------XDDesktopCell--------------------|
 |-----------------XDDesktopCollectionCell---------------|
 |-------------DeskView-------------DockView-------------|
 |-------------------------UIView------------------------|  (最下层)
 */
//netExtension的id
FOUNDATION_EXPORT int const DOCKSECTION;

NS_ASSUME_NONNULL_BEGIN
@class XDDesktopView;

@protocol XDDesktopViewDelegate <NSObject>
@required

/**
 Number of pages of desktopView (default 2 ,contain dockview)

 @param desktopView desktopView
 @return number of pages
 */
- (NSInteger)numberOfPagesInDesktopView:(XDDesktopView *)desktopView;
/**
 Number of applications per page

 @param desktopView desktopView
 @param page current page. The dock page is defined as 10000,max number is 4
 @return number of current page
 */
- (NSInteger)desktopView:(XDDesktopView *)desktopView numberOfItemsInPage:(NSInteger)page;

/**
 The cell that is returned must be retrieved from a call to -dequeueReusableCellForIndexPath:

 @param desktopView desktopView
 @param indexPath current page
 @return cell
 */
- (__kindof XDDesktopCell *)desktopView:(XDDesktopView *)desktopView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 Methods for notification of highlight events when the touch lifts.

 @param desktopView desktopView
 @param indexPath index of the touch
 */
- (void)desktopView:(XDDesktopView *)desktopView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Methods for notification of moving events.

 @param desktopView desktopView
 @param sourceIndexPath index of source item
 @param destinationIndexPath index of destination item
 */
- (void)desktopView:(XDDesktopView *)desktopView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath;

- (void)desktopView:(XDDesktopView *)desktopView deleteItemAtIndexPath:(NSIndexPath *)sourceIndexPath;

@end;

@interface XDDesktopView : UIView

@property (nonatomic, weak) id <XDDesktopViewDelegate> delegate;

//the max number of elements the dockView may contain,default 4.
@property (nonatomic, assign) NSInteger dockMax;
/**
 desktopView 初始化方法

 @param rows deskview行数
 @param columns deskview列数
 @param cellClass cellClass
 @param identifier identifier
 @return XDDesktopView
 */
+ (instancetype)desktopViewWithRows:(NSInteger)rows
                            columns:(NSInteger)columns
                      registerClass:(Class)cellClass
                         identifier:(NSString *)identifier;

- (__kindof XDDesktopCell *)dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath;

- (void)editingMode:(BOOL)editing;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
