//
//  TOFileRootPresenter.h
//
//  Copyright 2019 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOFileRootPresenter.h"

@interface TOFileRootPresenter ()

// Strong reference to file coordinator
@property (nonatomic, strong) TOFileCoordinator *fileCoordinator;

// The last item type and object that was assigned to this presenter
@property (nonatomic, assign, readwrite) TOFileViewControllerType itemType;
@property (nonatomic, strong) id itemObject;

// If NOT user initiated, the item is only presented by default in regular modes
@property (nonatomic, assign) BOOL isInitialItem;

@end

@implementation TOFileRootPresenter

- (instancetype)initWithFileCoordinator:(TOFileCoordinator *)fileCoordinator
{
    if (self = [super init]) {
        _fileCoordinator = fileCoordinator;
        _isInitialItem = YES;
        _itemType = TOFileViewControllerTypeAddLocation;
    }

    return self;
}

#pragma mark - Presenter Input -

- (void)setInitialItem:(TOFileViewControllerType)type modelObject:(id)object
{
    // If NOT user initiated, this is part of the view hierarchy setting itself up.
    // Since we might be on an iPhone, where the detail controller isn't even necessary,
    // save a reference, but defer setting up that view controller until the trait collection
    // actually does change to one where we need it.

    self.isInitialItem = YES;
    self.itemType = type;
    self.itemObject = object;

    // Show it immediately, if we're not in iPhone display mode
    if (!self.isCompactPresentation) {
        if (self.showItemHandler) { self.showItemHandler(type, object); }
    }
}

- (void)showItemWithType:(TOFileViewControllerType)type modelObject:(id)object
{
    self.itemType = type;
    self.itemObject = object;

    // Make it explicit that the item on display was chosen by the user
    self.isInitialItem = NO;

    // Show the item
    self.showItemHandler(type, object);
}

#pragma mark - Presenter Output -

- (BOOL)shouldCollapseVisibleItemsForSplitViewController
{
    return self.isInitialItem || self.itemType == TOFileViewControllerTypeAddLocation;
}

#pragma mark - State Tracking -

- (BOOL)typeShouldBeDisplayedInModal:(TOFileViewControllerType)type
{
    // Depending on the display mode and type, some controllers always need to be
    // displayed above the split view controller
    switch (type) {
        case TOFileViewControllerTypeAddLocation: return _isCompactPresentation;
        default: break;
    }

    return NO;
}

@end
