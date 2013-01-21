//
//  NPTrayItem.h
//  NikePlus
//
//  Created by Agustin de Cabrera on 21/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NPTray;

@interface NPTrayItem : NSObject
{
    BOOL _selected;
}

+ (id)itemWithViewController:(UIViewController*)viewController;
+ (id)itemWithViewController:(UIViewController*)viewController title:(NSString *)title image:(UIImage*)image;
+ (id)itemWithViewController:(UIViewController*)viewController title:(NSString *)title image:(UIImage*)image supportsRotation:(BOOL)rotates;
- (id)initWithViewController:(UIViewController*)viewController;

@property (nonatomic, strong)           NSString            *title;
@property (nonatomic, strong)           UIImage             *image;
@property (nonatomic, strong, readonly) UIViewController    *viewController;
@property (nonatomic, assign) BOOL                          selected;
@property (nonatomic, assign) BOOL                          supportsRotation;

@property (nonatomic, strong) NSString *badgeValue; // not implemented yet

// table view cell
- (CGFloat)rowHeight;

- (UITableViewCell*)cellForTableView:(UITableView*)tableView;

@end

