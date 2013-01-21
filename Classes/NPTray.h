//
//  NPTray.h
//  NikePlus
//
//  Created by Agustin DeCabrera on 06/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NPTrayDelegate;
@protocol NPTrayHeaderView;
@class NPTrayCell, NPTrayItem, NPTrayProfileView;


@interface NPTray : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UIView                   *view;
@property (nonatomic, strong) IBOutlet UITableView              *tableView;

@property (nonatomic, assign) id<NPTrayDelegate>                delegate;

@property (nonatomic, strong) NPTrayItem                        *mainItem;
@property (nonatomic, strong) UIView<NPTrayHeaderView>          *headerView;
@property (nonatomic, copy) NSArray                             *items;
- (void)addTrayItem:(NPTrayItem*)trayItem;

@property (nonatomic, strong) NPTrayItem                        *selectedItem;

- (void)selectMainItem;

@end


@protocol NPTrayDelegate <NSObject>
@optional

- (void)tray:(NPTray *)tray didSelectItem:(NPTrayItem*)item;

@end

@protocol NPTrayHeaderView <NSObject>
@optional
- (void)setTray:(NPTray*)aTray;
- (void)didAppear;
- (void)didDisappear;

@end
