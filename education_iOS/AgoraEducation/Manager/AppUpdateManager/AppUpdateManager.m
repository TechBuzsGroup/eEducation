//
//  AppUpdateManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/31.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "AppUpdateManager.h"
#import "AlertViewUtil.h"
#import "HttpManager.h"

#define ITUNES_URL @"https://itunes.apple.com/cn/app/id1497655202"

@interface AppUpdateManager()<UIApplicationDelegate>

@end

static AppUpdateManager *manager = nil;

@implementation AppUpdateManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if(self = [super init]){
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

+ (void)checkAppUpdateWithModel:(ConfigModel *)model {
    if(model.code == 0 && model.data != nil) {
        
        if(model.data.reviewing == 0){
            if(model.data.forcedUpgrade == 1) {
                [AppUpdateManager.shareManager showAppUpdateAlertView:NO];
            } else if(model.data.forcedUpgrade == 2) {
                [AppUpdateManager.shareManager showAppUpdateAlertView:YES];
            }
        }
    }
}

+ (void)checkAppUpdate {
    
    [HttpManager getAppConfigWithSuccess:^(id responseObj) {
        
        ConfigModel *model = [ConfigModel yy_modelWithDictionary:responseObj];
        if(model.code == 0 && model.data != nil) {
            
            if(model.data.reviewing == 0){
                if(model.data.forcedUpgrade == 2) {
                    [AppUpdateManager.shareManager showAppUpdateAlertView:NO];
                } else if(model.data.forcedUpgrade == 3) {
                    [AppUpdateManager.shareManager showAppUpdateAlertView:YES];
                }
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)showAppUpdateAlertView:(BOOL)force {
    
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    UINavigationController *nvc = (UINavigationController*)window.rootViewController;
    if(nvc != nil){
        UIViewController *showController = nvc;
        if(nvc.visibleViewController != nil){
            showController = nvc.visibleViewController;
        }
        
        NSURL *url = [NSURL URLWithString:ITUNES_URL];
        
        if(force){
            [AlertViewUtil showAlertWithController:showController title:@"The version has been updated. Please download the new version" message:nil cancelText:nil sureText:@"OK" cancelHandler:nil sureHandler:^(UIAlertAction * _Nullable action) {

                if(@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }];
        } else {
            [AlertViewUtil showAlertWithController:showController title:@"The version has been updated. Please download the new version" message:nil cancelText:@"Cancel" sureText:@"OK" cancelHandler:nil sureHandler:^(UIAlertAction * _Nullable action) {

                if(@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }];
        }
    }
}

- (void)applicationWillEnterForeground {
    [AppUpdateManager checkAppUpdate];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end

