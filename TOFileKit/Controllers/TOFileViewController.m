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

@interface TOFileViewController ()

@property (nonatomic, strong) UISplitViewController *downloadSplitController;
@property (nonatomic, strong) TOFileLocationsViewController *locationsController;
@property (nonatomic, strong) TOFileLocationPickerViewController *locationPickerViewController;

@property (nonatomic, strong) UITableViewController *activityViewController;

@property (nonatomic, strong, readwrite) TOFileCoordinator *fileCoordinator;

@end

@implementation TOFileViewController

- (instancetype)initWithFileCoordinator:(TOFileCoordinator *)fileCoordinator
{
    if (self = [super init]) {
        _fileCoordinator = fileCoordinator;
        [self makeChildControllers];
    }

    return self;
}

- (void)makeChildControllers
{
    // Far left column, the locations view controller
    self.locationsController = [[TOFileLocationsViewController alloc] initWithFileCoordinator:_fileCoordinator];
    TOFileNavigationController *locationsNavigationController = [[TOFileNavigationController alloc] initWithRootViewController:self.locationsController];

    // Middle column, by default the picker view controller
    self.locationPickerViewController = [[TOFileLocationPickerViewController alloc] initWithFileCoordinator:_fileCoordinator];
    TOFileNavigationController *pickerNavigationController = [[TOFileNavigationController alloc] initWithRootViewController:self.locationPickerViewController];

    // Create a split view controller to host these controllers
    self.downloadSplitController = [[UISplitViewController alloc] init];
    self.downloadSplitController.title = @"Download";
    self.downloadSplitController.preferredPrimaryColumnWidthFraction = 0.4f;
    self.downloadSplitController.minimumPrimaryColumnWidth = 320.0f;
    self.downloadSplitController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.downloadSplitController.viewControllers = @[locationsNavigationController, pickerNavigationController];
    self.downloadSplitController.view.backgroundColor = [UIColor whiteColor];

    // Far right column, the activity view controller
    self.activityViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.activityViewController.title = @"Activity";
    TOFileNavigationController *activityNavigationController = [[TOFileNavigationController alloc] initWithRootViewController:self.activityViewController];

    // Set us to the split view
    self.controllers = @[self.downloadSplitController, activityNavigationController];
    self.separatorLineColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];


}


@end