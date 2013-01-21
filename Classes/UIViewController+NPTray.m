//
//  UIViewController+NPTrayController.m
//  NikePlus
//
//  Created by Agustin DeCabrera on 09/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import "UIViewController+NPTray.h"
#import "NPTrayController.h"
#import "NPTray.h"
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
# warning file should be compiled with ARC
#endif


@implementation UIViewController(NPTray)

static void *trayItemKey;

- (NPTrayItem*)trayItem
{
    return objc_getAssociatedObject(self, &trayItemKey);
}
- (void)setTrayItem:(NPTrayItem *)trayItem
{
    objc_setAssociatedObject(self, &trayItemKey, trayItem, OBJC_ASSOCIATION_ASSIGN);
}

- (void)willAppearInNavTrayController:(NPTrayController*)trayController withAction:(SEL)action
{/*
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_barButton"] target:trayController action:action];*/
}
- (void)willDisappearInNavTrayController:(NPTrayController*)trayController
{
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)wasSelectedInNavTrayController:(NPTrayController*)trayController
{
}

- (void)showBadgeValue:(int)badgeValue forNavTrayController:(NPTrayController*)trayController
{
    //NPBarButtonItem *barButton = safe_cast(NPBarButtonItem, self.navigationItem.leftBarButtonItem);
    
    //barButton.badgeValue = badgeValue;
}

@end


@implementation UINavigationController(NPTray)

- (void)willAppearInNavTrayController:(NPTrayController*)trayController withAction:(SEL)action
{
    if ([self.viewControllers count] > 0)
        [[self.viewControllers objectAtIndex:0] willAppearInNavTrayController:trayController withAction:action];
}
- (void)willDisappearInNavTrayController:(NPTrayController*)trayController
{
    if ([self.viewControllers count] > 0)
        [[self.viewControllers objectAtIndex:0] willDisappearInNavTrayController:trayController];
}

- (void)wasSelectedInNavTrayController:(NPTrayController*)trayController
{
    if ([self.viewControllers count] > 0)
        [[self.viewControllers objectAtIndex:0] wasSelectedInNavTrayController:trayController];
}

- (void)showBadgeValue:(int)badgeValue forNavTrayController:(NPTrayController*)trayController
{
    if ([self.viewControllers count] > 0)
        [[self.viewControllers objectAtIndex:0] showBadgeValue:badgeValue forNavTrayController:trayController];
}

@end
