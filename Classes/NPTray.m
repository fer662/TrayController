//
//  NPTray.m
//  NikePlus
//
//  Created by Agustin DeCabrera on 06/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import "NPTray.h"
#import "NPTrayCell.h"
#import "NPTrayItem.h"
#import <UIKitHelpers/UIKitHelpers.h>

#if !__has_feature(objc_arc)
# warning file should be compiled with ARC
#endif


@interface NPTray()

- (void)initialize;
- (void)reloadTable;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) IBOutlet UIView *mainItemView;

@end


@implementation NPTray

@synthesize view=_view, tableView=_tableView;
@synthesize mainItem=_mainItem, mainItemView=_mainItemView, headerView=_headerView, items=_items, delegate;
@synthesize selectedIndexPath=_selectedIndexPath;

- (void)initialize
{
    _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    _items = [[NSArray alloc] init];
    
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    _view.frame = self.bounds;
    [self addSubview:_view];
    
    _view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tray_background"]];
    
    _tableView.tableFooterView = [[UIView alloc] init];
}

- (void)dealloc
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}


#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}

- (void)setHidden:(BOOL)hidden
{
    if (hidden != self.hidden) {
        [super setHidden:hidden];
        
        if (hidden)
        {
            [self.headerView didDisappear];
        }
        else
        {
            [self reloadTable];
            [self.headerView didAppear];
        }
    }
}


#pragma mark - NPTray

- (void)reloadTable
{
    [self reloadMainItem]; 
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)reloadMainItem
{
    Class viewClass = nil;
    if (!viewClass)
        return;
        
    [[self.mainItemView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *newView = [[viewClass alloc] initWithFrame:self.mainItemView.bounds];
    [self.mainItemView addSubview:newView];
    
    //[self.mainItem configureView:newView forTray:self];
    
    self.tableView.frameY_rga = [newView frameHeight_rga];
    self.tableView.frameHeight_rga = self.view.frameHeight_rga - self.tableView.frameY_rga;
}

- (void)setMainItem:(NPTrayItem *)anItem
{
    if (anItem != _mainItem) {
        _mainItem = anItem;
        [self reloadMainItem];
    }
}

- (void)setHeaderView:(UIView<NPTrayHeaderView>*)aView
{
    _headerView = aView;
    
    _tableView.tableHeaderView = _headerView;
}

- (void)setItems:(NSArray *)items
{
    if (items != _items) {
        _items = [items copy];
        
        [self reloadTable];
    }
}

- (void)addTrayItem:(id)trayItem
{
    self.items = [self.items arrayByAddingObject:trayItem];
}

- (NPTrayItem*)itemAtIndexPath:(NSIndexPath*)indexPath
{
    return [self.items objectAtIndex:indexPath.row];
}
- (NSIndexPath*)indexPathforItem:(NPTrayItem*)item
{
    NSUInteger itemIndex = [self.items indexOfObject:item];
    
    if (itemIndex == NSNotFound)
        return nil;
    
    return [NSIndexPath indexPathForRow:itemIndex inSection:0];
}

- (NPTrayItem *)selectedItem
{
    return [self itemAtIndexPath:self.selectedIndexPath];
}
- (void)setSelectedItem:(NPTrayItem *)selectedItem
{
    NSIndexPath *itemPath = [self indexPathforItem:selectedItem];
    if (itemPath)
        self.selectedIndexPath = itemPath;
}

- (void)selectMainItem
{
    self.selectedIndexPath = nil;
 
    if ([delegate respondsToSelector:@selector(tray:didSelectItem:)])
        [delegate tray:self didSelectItem:_mainItem];
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    if (selectedIndexPath != _selectedIndexPath) {
        _selectedIndexPath = selectedIndexPath;
        
        [self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{            
    return [[self itemAtIndexPath:indexPath] cellForTableView:tableView];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self itemAtIndexPath:indexPath] rowHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    self.selectedIndexPath = indexPath;
    
    if ([delegate respondsToSelector:@selector(tray:didSelectItem:)])
        [delegate tray:self didSelectItem:[self itemAtIndexPath:indexPath]];
}


#pragma mark - Properties

- (void)setTableView:(UITableView *)tableView
{
    if (tableView != _tableView) {
        _tableView.dataSource = nil;
        _tableView.delegate = nil;
        _tableView = tableView;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
}

@end
