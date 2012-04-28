iOSPapertrailLogger
===================

Redirects NSLog (and stderr) messages on iOS to [Papertrail](http://papertrailapp.com/ "Papertrail"), useful in cases where you don't have access to the console for debugging purposes, like when you have an external accessory connected to the device's dock connector. 

Most of the code is in the App Delegate, in the `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions` and `- (void)notificationReceived:(NSNotification *)notification` methods. 

