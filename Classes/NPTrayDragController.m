//
//  NPTrayDragController.m
//  NikePlus
//
//  Created by Agustin de Cabrera on 22/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import "NPTrayDragController.h"
#import <UIKitHelpers/UIKitHelpers.h>
//#import "CGGeometry+NP.h"
//#import "UIPanGestureRecognizer+NP.h"

#if !__has_feature(objc_arc)
# warning file should be compiled with ARC
#endif


@interface NPTrayDragController()

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *gestureRecognizer;

- (void)handleDragGesture:(UIPanGestureRecognizer*)sender;
- (void)gestureBegan;
- (void)gestureEnded;

@property (nonatomic) CGPoint startLocation;

@end

#if !defined(CLAMP)
#define CLAMP(A, LOW, HIGH) ({ 	\
__typeof__(A) __a = (A);\
__typeof__(LOW) __low = (LOW);\
__typeof__(HIGH) __high = (HIGH);\
__a < __low ? __low : (__a > __high ? __high : __a ); \
})
#endif

CGPoint CGPointClampToRect(const CGPoint point, const CGRect rect)
{
    return CGPointMake(CLAMP(point.x, CGRectGetMinX(rect), CGRectGetMaxX(rect)),
                       CLAMP(point.y, CGRectGetMinY(rect), CGRectGetMaxY(rect)));
}
@implementation NPTrayDragController

@synthesize gestureRecognizer, view=_view, targetView=_targetView;
@synthesize delegate;
@synthesize bounds, startLocation, direction;

- (id)init
{
    if ((self = [super init])) {
        gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragGesture:)];
        direction = NPTrayDragControllerDirectionAll;
    }
    return self;
}

- (void)handleDragGesture:(UIPanGestureRecognizer*)sender
{
    if (!sender.enabled)
        return;
    
    if (sender.state == UIGestureRecognizerStateBegan)
        [self gestureBegan];
    
    CGPoint newLocation = CGPointMake(startLocation.x + self.dragTranslation.x, startLocation.y + self.dragTranslation.y);
    
    if (!CGRectEqualToRect(bounds, CGRectZero))
        newLocation = CGPointClampToRect(newLocation, bounds);
    
    if (self.direction & NPTrayDragControllerDirectionHorizontal)
        self.targetView.frameX_rga = newLocation.x;
    
    if (self.direction & NPTrayDragControllerDirectionVertical)
        self.targetView.frameY_rga = newLocation.y;
    
    if (sender.state == UIGestureRecognizerStateEnded)
        [self gestureEnded];
}
- (void)gestureBegan
{
    startLocation = self.targetView.frameOrigin_rga;
    
    if ([delegate respondsToSelector:@selector(dragControllerDidBegin:)])
        [delegate dragControllerDidBegin:self];
}
- (void)gestureEnded
{
    if ([delegate respondsToSelector:@selector(dragControllerDidEnd:)])
        [delegate dragControllerDidEnd:self];
}

#pragma mark Properties

- (BOOL)enabled                     { return gestureRecognizer.enabled; }
- (void)setEnabled:(BOOL)enabled    { gestureRecognizer.enabled = enabled; }

- (void)setView:(UIView *)view
{
    if (view != _view) {
        [_view removeGestureRecognizer:gestureRecognizer];
        _view = view;        
        [_view addGestureRecognizer:gestureRecognizer];
    }
}

- (CGPoint)dragVelocity
{
    return [gestureRecognizer velocityInView:gestureRecognizer.view];
}

- (CGPoint)dragTranslation
{
    return [gestureRecognizer translationInView:gestureRecognizer.view];
}

@end
