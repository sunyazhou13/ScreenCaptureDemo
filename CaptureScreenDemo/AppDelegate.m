//
//  AppDelegate.m
//  CaptureScreenDemo
//
//  Created by sunyazhou on 2016/10/11.
//  Copyright © 2016年 Baidu, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "TestVC.h"
@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    TestVC *testVC = [[TestVC alloc] initWithNibName:@"TestVC" bundle:[NSBundle mainBundle]];
    
    self.window.contentViewController = testVC;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
