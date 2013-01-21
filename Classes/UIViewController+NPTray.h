//
//  UIViewController+NPTrayController.h
//  NikePlus
//
//  Created by Agustin DeCabrera on 09/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NPTrayItem, NPTrayController;


@interface UIViewController (NPTray)

@property (nonatomic, assign) NPTrayItem *trayItem;

- (void)willAppearInNavTrayController:(NPTrayController*)trayController withAction:(SEL)action;
- (void)willDisappearInNavTrayController:(NPTrayController*)trayController;

- (void)wasSelectedInNavTrayController:(NPTrayController*)trayController;

- (void)showBadgeValue:(int)badgeValue forNavTrayController:(NPTrayController*)trayController;

@end
