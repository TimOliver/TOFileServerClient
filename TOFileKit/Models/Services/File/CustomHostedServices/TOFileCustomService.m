//
//  TOFileCustomService.m
//
//  Copyright 2015-2019 Timothy Oliver. All rights reserved.
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

#import "TOFileCustomService.h"

NSString * const kICNetworkServiceNameKey           = @"name";
NSString * const kICNetworkServiceServerAddressKey  = @"serverAddress";
NSString * const kICNetworkServicePortNumberKey     = @"portNumber";
NSString * const kICNetworkServiceUserNameKey       = @"userName";
NSString * const kICNetworkServicePasswordKey       = @"password";

@implementation TOFileCustomService

- (NSString *)placeholderName
{
    return [self personalizedNameOfServiceWithUserName:nil];
}

- (NSString *)placeholderServerAddress
{
    return @"127.0.0.1";
}

+ (NSString *)netServiceType
{
    return nil;
}

- (NSInteger)defaultPort
{
    return -1;
}

#pragma mark - Convenience Methods -

+ (Class)customServiceClassForNetServiceType:(NSString *)serviceType;
{
    if (serviceType == nil) { return nil; }

    static dispatch_once_t onceToken;
    static NSDictionary *services = nil;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        NSArray *customHostedServices = [TOFileService customHostedServices];
        for (Class service in customHostedServices) {
            dictionary[[service netServiceType]] = service;
        }
        services = [NSDictionary dictionaryWithDictionary:dictionary];
    });

    return services[serviceType];
}

+ (NSArray *)allNetServiceTypes
{
    return [[self class] filteredNetServiceTypesWithDisallowedTypes:nil];
}

+ (NSArray *)filteredNetServiceTypesWithDisallowedTypes:(nullable NSArray *)disallowedTypes
{
    NSMutableArray *types = [NSMutableArray array];
    NSArray *hostedServices = [[self class] customHostedServices];

    for (Class service in hostedServices) {
        TOFileServiceType type = [service serviceType];
        if (disallowedTypes && [disallowedTypes indexOfObject:@(type)] != NSNotFound) {
            continue;
        }
        [types addObject:[service netServiceType]];
    }

    return [NSArray arrayWithArray:types];
}

@end
