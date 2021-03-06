//
//  TOFileViewController.m
//  TOFileKitExample
//
//  Created by Tim Oliver on 30/6/19.
//  Copyright © 2019 Tim Oliver. All rights reserved.
//

#import "TOFileCoordinator.h"
#import "TOFileViewController.h"
#import "TOFileLocationsViewController.h"
#import "TOFileNavigationController.h"
#import "TOFileLocationPickerViewController.h"
#import "TOFileRootPresenter.h"
#import "TOFileRootView.h"

#import "UIViewController+TOFileRouting.h"

@interface TOFileViewController () <UISplitViewControllerDelegate>

// The master split view controller controlling all of the content
@property (nonatomic, strong) UISplitViewController *splitViewController;

// The base view controller showing the saved file locations (and its parent nav controller)
@property (nonatomic, strong) UINavigationController *locationsNavigationController;
@property (nonatomic, strong) TOFileLocationsViewController *locationsViewController;

// By default, the view controller that lets users add new file locations
@property (nonatomic, strong) UINavigationController *locationPickerNavigationController;
@property (nonatomic, strong) TOFileLocationPickerViewController *locationPickerViewController;

// In compact, create a second, modal copy of the location picker
@property (nonatomic, strong) UINavigationController *modalLocationPickerNavigationController;
@property (nonatomic, strong) TOFileLocationPickerViewController *modalLocationPickerViewController;

// Data manipulation and state tracking
@property (nonatomic, strong, readwrite) TOFileCoordinator *fileCoordinator;
@property (nonatomic, strong) TOFileRootPresenter *presenter;

// When in regular mode, the done and download buttons shown along the top
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *downloadsButton;

// Convenience accessors for current state
@property (nonatomic, readonly) TOFileRootView *rootView;
@property (nonatomic, readonly) BOOL isCompactPresentation;

@end

@implementation TOFileViewController

#pragma mark - Class Creation -

- (instancetype)initWithFileCoordinator:(TOFileCoordinator *)fileCoordinator
{
    if (self = [super init]) {
        _fileCoordinator = fileCoordinator;
        _presenter = [[TOFileRootPresenter alloc] initWithFileCoordinator:_fileCoordinator];

        [self commonInit];
    }

    return self;
}

- (void)loadView
{
    self.view = [[TOFileRootView alloc] initWithFrame:CGRectZero];
}

- (void)commonInit
{
    // On iOS 13, force this to still be full screen
    self.modalPresentationStyle = UIModalPresentationFullScreen;
}

#pragma mark - View Configuration -

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Make all of the child controllers we'll display
    [self makeChildViewControllers];

    // Bind the toolbar button callbacks
    [self bindToolbarButtonCallbacks];

    // Bind the presenter callbacks
    [self bindPresenterCallbacks];

    // Add the split view controller to the hierachy
    [self addChildViewController:self.splitViewController];
    self.rootView.contentView = self.splitViewController.view;

    // Set the initial state for the presenter
    self.presenter.isCompactPresentation = self.isCompactPresentation;
}

- (void)makeChildViewControllers
{
    // Far left column, the locations view controller
    self.locationsViewController = [[TOFileLocationsViewController alloc] initWithFileCoordinator:_fileCoordinator];
    self.locationsNavigationController = [[TOFileNavigationController alloc] initWithRootViewController:self.locationsViewController];

    // Configure our split view controller to host these controllers
    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.preferredPrimaryColumnWidthFraction = 0.35f;
    self.splitViewController.minimumPrimaryColumnWidth = 320.0f;
    self.splitViewController.maximumPrimaryColumnWidth = 415.0f;
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.splitViewController.delegate = self;
    self.splitViewController.viewControllers = @[self.locationsNavigationController];
    self.splitViewController.view.backgroundColor = [UIColor whiteColor];
}

- (void)bindToolbarButtonCallbacks
{
    __weak typeof(self) weakSelf = self;

    // Bind the toolbar's done button
    id doneButtonTapped = ^(UIBarButtonItem *item) {
        [weakSelf doneButtonTapped:item];
    };
    self.rootView.doneButtonTapped = doneButtonTapped;

    // Bind the toolbar's download button
    id downloadsButtonTapped = ^(UIBarButtonItem *item) {
        [weakSelf downloadsButtonTapped:item];
    };
    self.rootView.downloadsButtonTapped = downloadsButtonTapped;
}

- (void)bindPresenterCallbacks
{
    __weak typeof(self) weakSelf = self;

    id showItemHandler = ^(TOFileViewControllerType type, id object) {
        [weakSelf showItemWithType:type object:object];
    };
    self.presenter.showItemHandler = showItemHandler;
}

#pragma mark - View Lifecycle -

- (void)viewDidLayoutSubviews
{
    // On iOS 11 and above, modify the safe area insets to
    // account for the toolbar height, so inner scrolling content
    // adapts properly.
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets insets = self.additionalSafeAreaInsets;
        insets.bottom = self.rootView.toolbarHeight;
        self.additionalSafeAreaInsets = insets;
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];

    // Update the presenter with the new size class
    self.presenter.isCompactPresentation = self.isCompactPresentation;

    // Set the left bar button item if in iPad
    UINavigationItem *locationsNavigationItem = self.locationsViewController.navigationItem;
    locationsNavigationItem.leftBarButtonItem = !self.isCompactPresentation ? self.doneButton : nil;

    // If we were presenting a modal location picker, remove it
    if (!self.isCompactPresentation && self.modalLocationPickerNavigationController) {
        [self dismissModalLocationPickerViewController];
    }
}

#pragma mark - Split View Controller Delegate -

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
            collapseSecondaryViewController:(UIViewController *)secondaryViewController
                ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    return [self.presenter shouldCollapseVisibleItemsForSplitViewController];
}

- (nullable UIViewController *)splitViewController:(UISplitViewController *)splitViewController
            separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
    return self.locationPickerNavigationController;
}

#pragma mark - View Routing -

- (void)to_showViewControllerOfType:(TOFileViewControllerType)type
                         withObject:(id)object
                           animated:(BOOL)animated
{
    // Forward to the presenter that we need to display a detail controller
    if (!animated) {
        // An initial item that will be retained and shown when needed
        [self.presenter setInitialItem:type modelObject:object];
    }
    else {
        // A user initiated push
        [self.presenter showItemWithType:type modelObject:object];
    }
}

- (void)showItemWithType:(TOFileViewControllerType)type object:(id)object
{
    switch (type) {
        case TOFileViewControllerTypeAddLocation:
            if (self.isCompactPresentation) {
                [self showModalLocationPickerViewController];
            }
            else {
                [self.splitViewController showDetailViewController:self.locationPickerNavigationController
                                                            sender:nil];
            }
        break;
        default: break;
    }
}

- (void)showModalLocationPickerViewController
{
    self.modalLocationPickerViewController = [[TOFileLocationPickerViewController alloc] initWithFileCoordinator:_fileCoordinator];
    self.modalLocationPickerNavigationController = [[TOFileNavigationController alloc] initWithRootViewController:self.modalLocationPickerViewController];
    self.modalLocationPickerNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.modalLocationPickerNavigationController animated:YES completion:nil];
}

- (void)dismissModalLocationPickerViewController
{
    self.modalLocationPickerNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.modalLocationPickerNavigationController dismissViewControllerAnimated:YES completion:nil];
    self.modalLocationPickerNavigationController = nil;
    self.modalLocationPickerViewController = nil;
}

#pragma mark - Interaction -

- (void)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)downloadsButtonTapped:(id)sender
{
    
}

#pragma mark - Convenience Accessors -

- (UINavigationController *)locationPickerNavigationController
{
    if (_locationPickerNavigationController) { return _locationPickerNavigationController; }

    // Lazy load the locations picker on request
    self.locationPickerViewController = [[TOFileLocationPickerViewController alloc] initWithFileCoordinator:_fileCoordinator];
    _locationPickerNavigationController = [[TOFileNavigationController alloc] initWithRootViewController:self.locationPickerViewController];
    _locationPickerNavigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    return _locationPickerNavigationController;
}

- (UIBarButtonItem *)doneButton
{
    if (_doneButton) { return _doneButton; }
    _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                target:self
                                                                action:@selector(doneButtonTapped:)];

    return _doneButton;
}

- (UIBarButtonItem *)downloadsButton
{
    if (_downloadsButton) { return _downloadsButton; }
    _downloadsButton = [[UIBarButtonItem alloc] initWithTitle:@"Downloads"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(downloadsButtonTapped:)];

    return _downloadsButton;
}

- (TOFileRootView *)rootView { return (TOFileRootView *)self.view; }

- (BOOL)isCompactPresentation
{
    return (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact);
}

@end
