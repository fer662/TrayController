//
//  NPTrayItem.m
//  NikePlus
//
//  Created by Agustin de Cabrera on 21/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import "NPTrayItem.h"
#import "NPTrayCell.h"
#import "UIViewController+NPTray.h"
#import "UITableView+UITableViewHelper.h"

#if !__has_feature(objc_arc)
# warning file should be compiled with ARC
#endif


@implementation NPTrayItem

@synthesize title=_title;
@synthesize image=_image;
@synthesize viewController=_viewController;
@synthesize badgeValue=_badgeValue;
@synthesize selected=_selected;
@synthesize supportsRotation = _supportsRotation;

+ (id)itemWithViewController:(UIViewController*)viewController
{
    return [[self alloc] initWithViewController:viewController];
}

+ (id)itemWithViewController:(UIViewController*)viewController title:(NSString *)title image:(UIImage*)image supportsRotation:(BOOL)rotates
{
    NPTrayItem *item = [self itemWithViewController:viewController];
    item.title = title;
    item.image = image;
    item.selected = NO;
    item.supportsRotation = rotates;
    return item;

}

+ (id)itemWithViewController:(UIViewController*)viewController title:(NSString *)title image:(UIImage*)image
{
    NPTrayItem *item = [self itemWithViewController:viewController];
    item.title = title;
    item.image = image;
    item.selected = NO;
    return item;
}

- (id)initWithViewController:(UIViewController*)viewController
{
    if ((self = [super init])) {
        _viewController = viewController;
        _viewController.trayItem = self;
    }
    return self;
}

- (void)dealloc
{
    _viewController.trayItem = nil;
}

#pragma mark - Table Cells

- (UITableViewCell *)cellForTableView:(UITableView *)tableView
{
    return [tableView cellOfClass:[NPTrayCell class] withObject:self];
}

- (CGFloat)rowHeight
{
    return [NPTrayCell heightForObject:self];
}

@end
