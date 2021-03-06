//
//  WPSplashViewModelTests.m
//  Wordpress
//
//  Created by Evgeniy Yurtaev on 01/01/15.
//  Copyright (c) 2015 Evgeniy Yurtaev. All rights reserved.
//

#define EXP_SHORTHAND

#import <Foundation/Foundation.h>
#import <Expecta/Expecta.h>
#import <Specta/Specta.h>
#import <OCMock/OCMock.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "WPSplashViewModel.h"
#import "WPClient.h"
#import "WPSite.h"
#import "WPGetSiteRequest.h"

#import "WPViewModel+Friend.h"
#import "WPRouter+Start.h"

SpecBegin(SplashViewModel)

describe(@"Splash", ^{
    __block WPSplashViewModel *viewModel;
    __block RACSignal *mockedCloseSignal;
    __block WPSite *site;
    __block id mockedClient;
    
    beforeEach(^{
        
        RACSubject *closeSignal = [RACReplaySubject replaySubjectWithCapacity:1];
        [closeSignal sendCompleted];
        mockedCloseSignal = OCMPartialMock(closeSignal);
        
        viewModel = [[WPSplashViewModel alloc] init];
        viewModel.closeSignal = mockedCloseSignal;
        
        site = [WPSite new];
        site.siteID = @1;
        
        mockedClient = OCMClassMock([WPClient class]);
        OCMStub(ClassMethod([mockedClient sharedInstance])).andReturn(mockedClient);
        OCMStub([mockedClient currentSite]).andReturn(site);
    });
    
    describe(@"when it fetching data", ^{
        __block id mockedRouter;
        
        beforeEach(^{
            mockedRouter = OCMClassMock([WPRouter class]);
            OCMStub(ClassMethod([mockedRouter sharedInstance])).andReturn(mockedRouter);
            OCMStub([mockedRouter presentStartScreenWithSite:[OCMArg isKindOfClass:[WPSite class]]]).andReturn([RACSignal empty]);
        });
        
        context(@"when request return description of site", ^{
            
            __block WPSite *updatedSite;
            
            beforeEach(^{
                updatedSite = [WPSite new];
                updatedSite.siteID = @1;
                
                OCMStub([mockedClient performRequest:[OCMArg isKindOfClass:[WPGetSiteRequest class]]]).andDo(^(NSInvocation *inv) {
                    [inv retainArguments];
                    
                    id returnValue = [RACSignal return:updatedSite];
                    [inv setReturnValue:&returnValue];
                });
                
                waitUntil(^(DoneCallback done) {
                    [[viewModel fetchData]
                        subscribeCompleted:^{
                            done();
                        }];
                });
            });
            
            it(@"should perform request for get site with {site.siteID} ID", ^{
                
                OCMVerify([mockedClient performRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
                    if (![obj isKindOfClass:[WPGetSiteRequest class]]) {
                        return NO;
                    }
                    return [[obj routeObject] isEqual:site];
                }]]);
            });
            
            it(@"should update `currentSite` of `WPClient` to recived new site", ^{
                OCMVerify([mockedClient setCurrentSite:updatedSite]);
            });
            
            it(@"should present the screen of posts with `siteID` == 1", ^{
                OCMVerify([mockedRouter presentStartScreenWithSite:site]);
            });
        });
        
        context(@"when request return error", ^{
            __block NSError *error;
            
            beforeEach(^{
                
                error = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: @"test" }];
                
                __block NSInteger numberOfRetries = 0;
                RACSignal *requestSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    
                    ++numberOfRetries;
                    if (numberOfRetries == 1) {
                        [subscriber sendError:error];
                    } else {
                        [subscriber sendNext:[WPSite new]];
                        [subscriber sendCompleted];
                    }
                    return nil;
                }];
                OCMStub([mockedClient performRequest:[OCMArg isKindOfClass:[WPGetSiteRequest class]]]).andReturn(requestSignal);
                
                waitUntil(^(DoneCallback done) {
                    [[viewModel fetchData]
                        subscribeCompleted:^{
                            done();
                        }];
                });
            });
            
            it(@"should change value of `errorMessage` to value from `NSLocalizedDescriptionKey`", ^{
                expect(viewModel.errorMessage).to.equal(error.userInfo[NSLocalizedDescriptionKey]);
            });
        });
    });
});

SpecEnd