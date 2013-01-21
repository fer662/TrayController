//
//  NPTrayController.h
//  NikePlus
//
//  Created by Agustin DeCabrera on 05/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+NPTray.h"
#import "NPTray.h"

@class NPTrayItem;

// useful typedefs
typedef void(^void_block)();
typedef void(^void_bool_block)(BOOL);


@interface NPTrayController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet NPTray *trayView;

- (IBAction)trayButtonTapped:(id)sender;

@property (nonatomic, assign) BOOL trayVisible;
- (void)setTrayVisible:(BOOL)visible animated:(BOOL)animated;

@property(nonatomic, assign) int                                badgeValue;

// ITEMS
@property (nonatomic, strong) NPTrayItem                        *mainItem;
@property (nonatomic, strong) UIView<NPTrayHeaderView>          *headerView;
@property (nonatomic, strong) NSArray                           *items;
- (void)addItems:(NSArray*)items;

@property (nonatomic, strong, readonly) NSArray                 *viewControllers;

@property (nonatomic, strong) UIViewController                  *selectedViewController;

- (void)switchToViewController:(UIViewController*)viewController;

// Navigation swipe
- (void)setNavigationSwipeEnabled:(BOOL)enabled;

@end

