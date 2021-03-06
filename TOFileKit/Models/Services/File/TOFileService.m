//
//  TOFileService.m
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

#import "TOFileService.h"
#import "TOFileConstants.h"

#import "TOFileCloudServiceDropbox.h"
#import "TOFileCloudServiceBox.h"
#import "TOFileCloudServiceOneDrive.h"
#import "TOFileCloudServiceGoogleDrive.h"

#import "TOFileCustomServiceFTP.h"
#import "TOFileCustomServiceSFTP.h"
#import "TOFileCustomServiceSMB.h"

@implementation TOFileService

+ (Class)classOfServiceForType:(TOFileServiceType)type
{
    return [TOFileService allServicesDictionary][@(type)];
}

+ (instancetype)fileServiceForType:(TOFileServiceType)type
{
    Class class = [TOFileService classOfServiceForType:type];
    if (class == nil) {
        return nil;
    }
    
    return [[class alloc] init];
}

#pragma mark - Listing All Services -

+ (NSArray *)allServices
{
    return @[[TOFileCloudServiceDropbox class],
             [TOFileCloudServiceGoogleDrive class],
             [TOFileCloudServiceOneDrive class],
             [TOFileCloudServiceBox class],
             [TOFileCustomServiceSMB class],
             [TOFileCustomServiceSFTP class],
             [TOFileCustomServiceFTP class]];
}

+ (NSArray *)cloudHostedServices
{
    return @[[TOFileCloudServiceDropbox class],
             [TOFileCloudServiceGoogleDrive class],
             [TOFileCloudServiceOneDrive class],
             [TOFileCloudServiceBox class]];
}

+ (NSArray *)customHostedServices
{
    return @[[TOFileCustomServiceSMB class],
             [TOFileCustomServiceSFTP class],
             [TOFileCustomServiceFTP class]];
}

+ (NSDictionary *)allServicesDictionary
{
    return @{
             @(TOFileServiceTypeDropbox)     : [TOFileCloudServiceDropbox class],
             @(TOFileServiceTypeGoogleDrive) : [TOFileCloudServiceGoogleDrive class],
             @(TOFileServiceTypeOneDrive)    : [TOFileCloudServiceOneDrive class],
             @(TOFileServiceTypeBox)         : [TOFileCloudServiceBox class],
             @(TOFileServiceTypeSMB)         : [TOFileCustomServiceSMB class],
             @(TOFileServiceTypeSFTP)        : [TOFileCustomServiceSFTP class],
             @(TOFileServiceTypeFTP)         : [TOFileCustomServiceFTP class]
            };
}

- (TOFileServiceType)serviceType
{
    return [[self class] serviceType];
}

#pragma mark - Service Name -
- (NSString *)personalizedNameOfServiceWithUserName:(NSString *)userName
{
    NSString *serviceName = [self.class name];
    
    if (userName == nil || userName.length == 0) {
        NSString *localizedNamelessString = NSLocalizedString(@"My %@", @"Nameless Personal Download Name");
        return [NSString stringWithFormat:localizedNamelessString, serviceName];
    }
    
    return [NSString stringWithFormat:NSLocalizedString(@"%@'s %@", @"Personal Download Name"), userName, serviceName];
}

- (NSString *)placeholderName
{
    return [self.class name];
}

#pragma mark - Subclass Overrides -
+ (TOFileServiceType)serviceType { return TOFileServiceTypeNone; }
+ (NSString *)name  { return nil; }
+ (UIImage *)icon   { return nil; }
+ (BOOL)nativeAppServiceAvailable { return NO; }
- (void)testConnectionWithSuccessHandler:(void (^)(void))successHandler failHandler:(void (^)(NSString *))failHandler { }
- (void)stopConnectionTest { }

@end

