//
//  TestVC.m
//  CaptureScreenDemo
//
//  Created by sunyazhou on 2016/10/11.
//  Copyright © 2016年 Baidu, Inc. All rights reserved.
//

#import "TestVC.h"

@interface TestVC ()
//@property(nonatomic, strong)NSTimer *timer;
//@property(nonatomic, assign)NSInteger repeatCount;
@property(nonatomic, strong)dispatch_queue_t queue;
@property(nonatomic, strong)dispatch_source_t timer;
@end

@implementation TestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (IBAction)startCapture:(NSButton *)sender {
    if (self.timer == nil) {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
    }
    //延时
    NSTimeInterval delayTime = 0.0f;
    
    //间隔
    NSTimeInterval interval = 100;
    
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    dispatch_source_set_timer(self.timer, startDelayTime, interval * NSEC_PER_MSEC , 1 * NSEC_PER_MSEC);
    dispatch_source_set_event_handler(self.timer, ^{
        
        // stuff performed on background queue goes here
        
        NSLog(@"done on custom background queue");
        
        // if you need to also do any UI updates, synchronize model updates,
        // or the like, dispatch that back to the main queue:
        [self dealImage];
        
    });
    dispatch_resume(self.timer);
}

- (IBAction)stopAction:(NSButton *)sender {
    
    dispatch_source_cancel(self.timer);
    self.timer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.timer invalidate];
        NSLog(@"done on main queue");
    });

//    if (self.repeatCount == 20) {
//            } else {
//        self.repeatCount++;
//    }
}


- (void)dealImage {
    NSScreen *screen = [[NSScreen screens] lastObject];
    if (screen == nil) { return; }
    CGImageRef imgRef = [TestVC screenShot:screen];
    NSRect mainFrame = screen.frame;
    NSImage *image = [[NSImage alloc] initWithCGImage:imgRef size:mainFrame.size];
    [self captureAppScreen:image];
    CGImageRelease(imgRef);
}



- (void)captureAppScreen:(NSImage *)image {
    
    static NSDateFormatter* formatter;
    static NSURL*           homeDir;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYYMMDDHHmmssSSSS"];
        
        homeDir = [NSURL fileURLWithPath:[@"~/Movies/" stringByExpandingTildeInPath]];
    });
    NSString* date = [formatter stringFromDate:[NSDate date]];
    
    if (image) {
        NSData *imgData = [image TIFFRepresentation];
        NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:imgData];
        NSData* newData = [bitmap representationUsingType:NSBMPFileType properties:@{}];
        NSString *randomStr = [NSString stringWithFormat:@"%@-%zd.bmp",date,arc4random()];
        NSURL *bmpPath = [homeDir URLByAppendingPathComponent:randomStr];
        [newData writeToURL:bmpPath atomically:YES];
        image = nil;
    }
}

+ (CGImageRef)screenShot:(NSScreen *)screen
{
    CFArrayRef windowsRef = CGWindowListCreate(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    
    NSRect rect = screen.frame;
    NSRect mainRect = [NSScreen mainScreen].frame;
    for (NSScreen *subScreen in [NSScreen screens]) {
        if ((int) subScreen.frame.origin.x == 0 && (int) subScreen.frame.origin.y == 0) {
            mainRect = subScreen.frame;
        }
    }
    
    rect = NSMakeRect(rect.origin.x, (mainRect.size.height) - (rect.origin.y + rect.size.height), rect.size.width, rect.size.height);
    
    NSLog(@"screenShot: %@", NSStringFromRect(rect));
    CGImageRef imgRef = CGWindowListCreateImageFromArray(rect, windowsRef, kCGWindowImageDefault);
    CFRelease(windowsRef);
    
    return imgRef;
}

- (void)dealloc {
//    [self.timer invalidate];
//    self.timer = nil;
}
@end
