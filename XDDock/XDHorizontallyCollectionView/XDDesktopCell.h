//
//  XDDesktopCell.h
//  XDDock
//
//  Created by xiaoda on 2019/4/11.
//  Copyright © 2019 xiaoda. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XDDesktopCell;
@protocol XDDesktopCellDelegate <NSObject>

- (void)clickGestureForCell:(XDDesktopCell *)cell indexPath:(NSIndexPath *)indexPath;

- (void)longGestureForCell:(XDDesktopCell *)cell gesture:(UILongPressGestureRecognizer*)gesture;

@end

@interface XDDesktopCell : UIView

@property (nonatomic, weak) id <XDDesktopCellDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end



NS_ASSUME_NONNULL_END
