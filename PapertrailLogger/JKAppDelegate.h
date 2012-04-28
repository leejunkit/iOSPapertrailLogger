//
//  JKAppDelegate.h
//  PapertrailLogger
//
//  Created by Jun Kit Lee on 28/4/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JKViewController;

@interface JKAppDelegate : UIResponder <UIApplicationDelegate> {
    NSPipe *pipe;
    NSFileHandle *stderrWriteFileHandle;
    NSFileHandle *stderrReadFileHandle;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) JKViewController *viewController;

@end
