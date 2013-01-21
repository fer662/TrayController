//
//  NPTrayCell.h
//  NikePlus
//
//  Created by Agustin DeCabrera on 12/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCell.h"

@interface NPTrayCell : TableViewCell

@property (nonatomic, strong) IBOutlet UILabel      *textLabel;
@property (nonatomic, strong) IBOutlet UIImageView  *imageView;

@end
