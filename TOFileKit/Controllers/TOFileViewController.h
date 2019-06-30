//
//  TOFileViewController.h
//  TOFileKitExample
//
//  Created by Tim Oliver on 30/6/19.
//  Copyright © 2019 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOSegmentedTabBarController.h"

@class TOFileCoordinator;

NS_ASSUME_NONNULL_BEGIN

@interface TOFileViewController : TOSegmentedTabBarController

@property (nonatomic, readonly) TOFileCoordinator *fileCoordinator;

- (instancetype)initWithFileCoordinator:(TOFileCoordinator *)fileCoordinator;

@end

NS_ASSUME_NONNULL_END