//
//  TOFileLocalServiceDiscoveryTests.m
//  TOFileKitTests
//
//  Created by Tim Oliver on 6/4/19.
//  Copyright © 2019 Tim Oliver. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TOFileLocalServiceDiscovery.h"

@interface TOFileLocalServiceDiscoveryTests : XCTestCase

@end

@implementation TOFileLocalServiceDiscoveryTests

// Do a basic test to see that the class will properly handle services sent from Bonjour
- (void)testLocalDiscovery
{
    NSArray *serviceTypes = @[@"_smb._tcp."];

    // Allocation
    TOFileLocalServiceDiscovery *discovery = [[TOFileLocalServiceDiscovery alloc] initWithSearchServiceTypes:serviceTypes];
    XCTAssertNotNil(discovery);

    discovery.newServiceAddedHandler = ^(NSNetService *service, NSInteger index) {
        XCTAssertNotNil(service);
    };

    // Create a dummy service
    NSNetService *service = [[NSNetService alloc] initWithDomain:@"" type:@"_smb._tcp." name:@"Test"];

    // Expose the protocol conformance of the object so we can trigger a fake service detection
    id<NSNetServiceBrowserDelegate> discoveryDelegate = (id)discovery;
    [discoveryDelegate netServiceBrowser:[[NSNetServiceBrowser alloc] init] didFindService:service moreComing:YES];
}

@end