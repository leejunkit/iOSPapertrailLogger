//
//  JKAppDelegate.m
//  PapertrailLogger
//
//  Created by Jun Kit Lee on 28/4/12.
//  
//

#import "JKAppDelegate.h"
#import <CoreFoundation/CoreFoundation.h>
#import "JKViewController.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>

@implementation JKAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"This should show up on the console");
    
    pipe = [NSPipe pipe];
    stderrWriteFileHandle = [[pipe fileHandleForWriting] retain];
    stderrReadFileHandle = [[pipe fileHandleForReading] retain];
    
    dup2([stderrWriteFileHandle fileDescriptor], STDERR_FILENO);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NSFileHandleReadCompletionNotification object:stderrReadFileHandle];
    [stderrReadFileHandle readInBackgroundAndNotify];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[JKViewController alloc] initWithNibName:@"JKViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)notificationReceived:(NSNotification *)notification
{
    [stderrReadFileHandle readInBackgroundAndNotify];
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *logMessage = [[NSString alloc] initWithData: [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem] encoding: NSUTF8StringEncoding];
    logMessage = [applicationName stringByAppendingFormat:@" %@", logMessage];
    
    //create the socket
    CFSocketRef socket;
    socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_DGRAM, IPPROTO_UDP, 0, NULL, NULL);
    
    //convert logs.papertrailapp.com to an IP address
    struct hostent *hostname_to_ip = gethostbyname("logs.papertrailapp.com");
    
    //create the sockaddr_in struct
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(17600); //change this to the port Papertrail tells you to use
    
    //the following line is probably contrived but I am a C noob. sorry.
    inet_aton(inet_ntoa(* (struct in_addr *)hostname_to_ip->h_addr_list[0]), &addr.sin_addr);
    
    //convert the struct to a NSData object
    NSData *addrData = [NSData dataWithBytes:&addr length:sizeof(addr)];
    
    int err = CFSocketSendData(socket, (CFDataRef)addrData, (CFDataRef)[logMessage dataUsingEncoding:NSUTF8StringEncoding], 0);
    if (err)
    {
        //handle the error
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
