//
//  NPTrayDragController.h
//  NikePlus
//
//  Created by Agustin de Cabrera on 22/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NPTrayDragControllerDelegate;


typedef enum {
    NPTrayDragControllerDirectionHorizontal = 1 << 0,
    NPTrayDragControllerDirectionVertical   = 1 << 1,
    NPTrayDragControllerDirectionAll        = NPTrayDragControllerDirectionHorizontal | NPTrayDragControllerDirectionVertical,
} NPTrayDragControllerDirection;


@interface NPTrayDragController : NSObject

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIView *targetView;

@property (nonatomic) CGRect bounds;
@property (nonatomic) BOOL enabled;

@property (nonatomic, readonly) CGPoint dragTranslation;
@property (nonatomic, readonly) CGPoint dragVelocity;

@property (nonatomic, assign) id<NPTrayDragControllerDelegate> delegate;

// the allowed direction for dragging. Default is NPTrayDragControllerDirectionAll.
@property (nonatomic) NPTrayDragControllerDirection direction; 

@end


@protocol NPTrayDragControllerDelegate <NSObject>
@optional

- (void)dragControllerDidEnd:(NPTrayDragController*)dragController;
- (void)dragControllerDidBegin:(NPTrayDragController*)dragController;

@end