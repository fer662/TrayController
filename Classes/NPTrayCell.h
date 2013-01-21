//
//  NPTrayCell.h
//  NikePlus
//
//  Created by Agustin DeCabrera on 12/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NPTrayItem;


@interface NPTrayCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel      *textLabel;
@property (nonatomic, strong) IBOutlet UIImageView  *imageView;

- (void)configureWithItem:(NPTrayItem*)item;

@end
