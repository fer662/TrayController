//
//  NPTrayController.m
//  NikePlus
//
//  Created by Agustin DeCabrera on 05/03/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#if !__has_feature(objc_arc)
# warning file should be compiled with ARC
#endif

#import "NPTrayController.h"
#import "NPTray.h"
#import "NPTrayItem.h"
#import "NPTrayDragController.h"
#import <UIKitHelpers/UIKitHelpers.h>

typedef enum {
    UIViewPhaseInitialized = 0,
    UIViewPhaseDidLoad,
    UIViewPhaseWillAppear,
    UIViewPhaseDidAppear,
    UIViewPhaseWillDisappear,
    UIViewPhaseDidDisappear,
    UIViewPhaseDidUnload
} UIViewPhase;

#if !defined(CLAMP)
#define CLAMP(A, LOW, HIGH) ({ 	\
__typeof__(A) __a = (A);\
__typeof__(LOW) __low = (LOW);\
__typeof__(HIGH) __high = (HIGH);\
__a < __low ? __low : (__a > __high ? __high : __a ); \
})
#endif

@interface NPTrayController() <NPTrayDelegate, NPTrayDragControllerDelegate>
{
    BOOL isAnimating;
}

@property (nonatomic) UIViewPhase viewPhase;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) NPTrayDragController *dragController;
@property (nonatomic, strong) NPTrayDragController *navDragController;

- (void)createGestureRecognizers;
- (void)handleTapGesture:(UITapGestureRecognizer*)sender;

@property (nonatomic, strong) NPTrayItem    *selectedItem;

- (UIView *)selectedView;

- (void)toggleTrayVisibility;
- (void)preloadViews;

@end


@implementation NPTrayController

@synthesize mainView=_mainView;
@synthesize trayView=_trayView;
@synthesize tapRecognizer=_tapRecognizer;
@synthesize dragController=_dragController;
@synthesize navDragController=_navDragController;
@synthesize trayVisible=_trayVisible;
@synthesize viewPhase=_viewPhase;

@synthesize mainItem=_mainItem;
@synthesize headerView=_headerView;
@synthesize items=_items;
@synthesize viewControllers=_viewControllers;
@synthesize selectedItem=_selectedItem;

@synthesize badgeValue=_badgeValue;


- (NSUInteger)supportedInterfaceOrientationsForCurrentViewController {
    
    if (self.selectedItem.supportsRotation) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else
        return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -

- (id)init
{
    if ((self =  [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]])) {
        _items = [[NSArray alloc] init];
        _viewControllers = [[NSArray alloc] init];
        _trayVisible = YES;
        _viewPhase = UIViewPhaseInitialized;
        
        [self createGestureRecognizers];
    }
    return self;
}

- (void)dealloc
{
    _trayView.delegate = nil;
    _dragController.delegate = nil;
    _navDragController.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (NO)
    {
        BOOL isLoaded = [self isViewLoaded];
        
        if (isLoaded && self.view.window == nil)
        {
            [self performSelectorOnMainThread:@selector(viewWillUnload)
                                   withObject:nil
                                waitUntilDone:YES];
            
            [self.view removeFromSuperview];
            self.view = nil;
            
            [self performSelectorOnMainThread:@selector(viewDidUnload)
                                   withObject:nil
                                waitUntilDone:YES];
        }
    }

}

- (void)preloadViews
{
//    for (UIViewController *viewController in self.viewControllers) {
//        [viewController forceViewLoad]; // preload view
//    }
}

- (void)setTrayVisible:(BOOL)visible
{
    [self setTrayVisible:visible animated:NO];
}
- (void)setTrayVisible:(BOOL)visible animated:(BOOL)animated
{    
    void_block anim_block = ^{
        self.mainView.frameX_rga = visible? self.trayView.frameWidth_rga : 0;
    };
    void_bool_block end_block = ^(BOOL finished){ 
        isAnimating = NO;
        
        self.selectedView.userInteractionEnabled = !visible;
        self.tapRecognizer.enabled = visible;
        self.dragController.enabled = visible;
        self.navDragController.enabled = !visible;
        
        self.trayView.hidden = !visible;
    };
    
    // skip aniumation if already animating...
    if (visible == _trayVisible && animated && isAnimating) {
        return;
    }
    
    _trayVisible = visible;

    if (visible) {
        self.trayView.hidden = NO;
        [self preloadViews];
    }
    
    if (animated) {
        isAnimating = YES;
        
        self.selectedView.userInteractionEnabled = NO;
        self.dragController.enabled = NO;
        self.navDragController.enabled = NO;
        
        double delta = CLAMP((self.mainView.frameX_rga - self.trayView.frameX_rga) / self.trayView.frameWidth_rga, 0, 1);
        NSTimeInterval duration = 0.3 * (visible? 1-delta : delta);
        
        [UIView animateWithDuration:duration 
                         animations:anim_block 
                         completion:end_block];
    }
    else {
        anim_block();
        end_block(YES);
    }
}

- (void)toggleTrayVisibility
{
    [self setTrayVisible:!self.trayVisible animated:YES];
}


#pragma mark - Badges

- (void)setBadgeValue:(int)badgeValue
{
    if (_badgeValue != badgeValue) {
        _badgeValue = badgeValue;
        
        for (UIViewController *controller in self.viewControllers) {
            [controller showBadgeValue:_badgeValue forNavTrayController:self];
        }
    }
}


#pragma mark - Gestures

- (void)createGestureRecognizers
{
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.tapRecognizer.enabled = NO;
    
    self.dragController = [[NPTrayDragController alloc] init];
    self.dragController.enabled = NO;
    self.dragController.delegate = self;      
    self.dragController.direction = NPTrayDragControllerDirectionHorizontal;
    
    self.navDragController = [[NPTrayDragController alloc] init];
    self.navDragController.enabled = NO;
    self.navDragController.delegate = self;      
    self.navDragController.direction = NPTrayDragControllerDirectionHorizontal;
}

- (void)handleTapGesture:(UITapGestureRecognizer*)sender
{
    if (!sender.enabled)
        return;
    
    [self toggleTrayVisibility];
}

- (void)setNavigationSwipeEnabled:(BOOL)enabled
{
    self.navDragController.enabled = enabled;
}

#pragma mark - Items

- (void)setItems:(NSArray *)items
{
    if (items != _items) {
        _items = items;
        _viewControllers = [self.items valueForKey:@"viewController"];
    }
}
- (void)addItems:(NSArray*)items
{
    if ([items count])
        self.items = [self.items arrayByAddingObjectsFromArray:items];
}
- (NSArray*)allItems
{
    return [self.items arrayByAddingObject:self.mainItem];
}

static UINavigationController* navigationControllerForViewController(UIViewController* viewController)
{
    return (UINavigationController *)([viewController isKindOfClass:[UINavigationController class]]?viewController:viewController.navigationController);
}
static UINavigationBar* navigationBarForViewController(UIViewController* viewController)
{
    return navigationControllerForViewController(viewController).navigationBar;
}

- (void)showViewController:(UIViewController*)viewController
{    
    viewController.view.frame = self.mainView.bounds;
    
    if ([self respondsToSelector:@selector(addChildViewController:)])
        [self addChildViewController:viewController];
    
    [viewController willAppearInNavTrayController:self withAction:@selector(trayButtonTapped:)];
    [viewController showBadgeValue:self.badgeValue forNavTrayController:self];
    
    [self.mainView addSubview:viewController.view];
    
    self.navDragController.view = navigationBarForViewController(viewController);
}
- (void)hideViewController:(UIViewController*)viewController
{
    self.navDragController.view = nil;
    
    [viewController willDisappearInNavTrayController:self];
    [viewController.view removeFromSuperview];
    
    if ([viewController respondsToSelector:@selector(removeFromParentViewController)])
        [viewController removeFromParentViewController];
}

- (void)didDeselectViewController:(UIViewController*)viewController
{
    [viewController viewWillDisappear:NO];
    [self hideViewController:viewController];
    [viewController viewDidDisappear:NO];
}
- (void)didSelectViewController:(UIViewController*)viewController
{
    [viewController view];
    [viewController viewWillAppear:NO];
    [self showViewController:viewController];
    [viewController viewDidAppear:NO];
}

- (NSUInteger)indexForItem:(NPTrayItem*)item
{
    return [self.items indexOfObject:item];
}

- (void)setSelectedItem:(NPTrayItem*)item
{
    if (item == _selectedItem)
        return;
    
    if (self.viewPhase == UIViewPhaseDidAppear)
        [self didDeselectViewController:self.selectedViewController];
    
    _selectedItem = item;
    self.trayView.selectedItem = self.selectedViewController.trayItem;
    
    if (self.viewPhase == UIViewPhaseDidAppear)    
        [self didSelectViewController:self.selectedViewController];
}

- (void)switchToViewController:(UIViewController*)viewController
{
    self.selectedViewController = viewController;
    
    [self setTrayVisible:NO animated:YES];
}


#pragma mark - Selected Item

- (UIViewController *)selectedViewController
{
    return self.selectedItem.viewController;
}

- (void)setSelectedViewController:(UIViewController *)viewController
{
    self.selectedItem = viewController.trayItem;
}
- (UIView*)selectedView
{
    return self.selectedViewController.view;
}


#pragma mark - UIView lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewPhase = UIViewPhaseDidLoad;
    
    self.trayView.delegate = self;
    self.trayView.items = self.items;
    self.trayView.mainItem = self.mainItem;
    self.trayView.headerView = self.headerView;
    [self.headerView setTray:self.trayView];
    
    [self setTrayVisible:NO animated:NO];
    
    [self.mainView addGestureRecognizer:self.tapRecognizer];
    
    self.dragController.view = self.mainView;
    self.dragController.targetView = self.mainView;
    self.dragController.bounds = self.trayView.frame;
    
    self.navDragController.targetView = self.mainView;
    self.navDragController.bounds = self.trayView.frame;
    
    self.trayView.selectedItem = self.selectedViewController.trayItem;
}

- (void)viewDidUnload
{        
    [super viewDidUnload];
    self.viewPhase = UIViewPhaseDidUnload;
    
    [self.tapRecognizer.view removeGestureRecognizer:self.tapRecognizer];
    
    self.dragController.view = nil;
    self.dragController.targetView = nil;
    
    self.navDragController.view = nil;
    self.navDragController.targetView = nil;
    
    self.mainView = nil;
    self.trayView.delegate = nil;
    self.trayView = nil;    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.viewPhase = UIViewPhaseWillAppear;
 
    self.view.frameY_rga = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    [self showViewController:self.selectedViewController];
    
    [self.selectedViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.viewPhase = UIViewPhaseDidAppear;
    
    [self.selectedViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{    
    [super viewWillDisappear:animated];
    self.viewPhase = UIViewPhaseWillDisappear;
    
    [self.selectedViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{   
    [super viewDidDisappear:animated];
    self.viewPhase = UIViewPhaseDidDisappear;
    
    [self hideViewController:self.selectedViewController];
    
    [self.selectedViewController viewDidDisappear:animated];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.selectedViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.selectedViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

//iOS 6 Methods

-(BOOL)shouldAutorotate
{
    if (self.selectedItem.supportsRotation == NO) {
        return NO;
    }
    
    UINavigationController *navi = navigationControllerForViewController(self.selectedViewController);
    return [navi.visibleViewController shouldAutorotateToInterfaceOrientation:[[UIDevice currentDevice] orientation]];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [self supportedInterfaceOrientationsForCurrentViewController];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}



#pragma mark - UIContainerViewControllerCallbacks

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers 
{
    return NO;
}


#pragma mark - IBAction

- (IBAction)trayButtonTapped:(UIButton *)sender 
{
    [self toggleTrayVisibility];
}


#pragma mark - NPTrayDelegate

- (void)tray:(NPTray *)tray didSelectItem:(NPTrayItem *)item
{
    [self setTrayVisible:NO animated:YES];
    
    for (NPTrayItem* anItem in [self allItems])
        anItem.selected = NO;
    
    self.selectedItem = item;
    self.selectedItem.selected = YES;
/*
    OMAppMeasurement *s = [OMAppMeasurement getInstance];
    switch ([self indexForItem:item]) {
        case NSNotFound:    [s trackPageName:@"nav>profile"];               break;
        case 0:             [s trackPageName:@"nav>home"];                  break;
        case 1:             [s trackPageName:@"nav>activity"];              break;
        case 2:             [s trackPageName:@"nav>leaderboards"];          break;
        case 3:             [s trackPageName:@"nav>friends"];               break;
        case 4:             [s trackPageName:@"nav>settings"];              break;
        case 5:             [s trackPageName:@"nav>shop_nike_running"];     break;            
        default:
            break;
    }
    */
    [self.selectedViewController wasSelectedInNavTrayController:self];
}


#pragma mark - NPTrayDragControllerDelegate

- (void)dragControllerDidBegin:(NPTrayDragController *)dragController
{
    self.trayView.hidden = NO;
}
- (void)dragControllerDidEnd:(NPTrayDragController *)dragController
{    
    CGPoint velocity = dragController.dragVelocity;
    BOOL visible = velocity.x > 0;
    
    // if tray is on either edge, ignore velocity
    if (self.mainView.frameX_rga >= self.trayView.frameWidth_rga) {
        visible = YES;
    }
    else if (self.mainView.frameX_rga <= self.trayView.frameX_rga) {
        visible = NO;
    }
    
    [self setTrayVisible:visible animated:YES];
}

@end

