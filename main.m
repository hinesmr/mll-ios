//
//  main.m
//  reader 
//
//  Created by Michael R. Hines on 8/13/14.
//
//
#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import <UIKit/UIKit.h>
#include <python2.7/Python.h>
#include <dlfcn.h>
#include "main.h"
#include "mica.h"

void load_custom_builtin_importer();

#ifdef main
#undef main
#endif

int main(int argc, char *argv[]) {
    NSLog(@"Application starting up.");
    //setenv("CFNETWORK_DIAGNOSTICS", "2", 1);
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

void run_python() {
    int ret = 0;
    // Change the executing path to YourApp
    chdir("YourApp");
    //NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    // Special environment to prefer .pyo, and don't write bytecode if .py are found
    // because the process will not have write attribute on the device.
    putenv("PYTHONOPTIMIZE=2");
    putenv("PYTHONDONTWRITEBYTECODE=1");
    putenv("PYTHONNOUSERSITE=1");
    putenv("PYTHONPATH=.");
    //putenv("PYTHONVERBOSE=1");
    
    if(Py_IsInitialized()) {
        NSLog(@"Python was initialized previously. Cleaning it up before restart.");
        Py_Finalize();
    }

    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    //NSLog(@"PythonHome is: %s", (char *)[resourcePath UTF8String]);
    Py_SetPythonHome((char *)[resourcePath UTF8String]);

    //NSLog(@"Initializing python");
    Py_Initialize();
    char * argv = {"mica"};
    PySys_SetArgv(1, &argv);

    // If other modules are using thread, we need to initialize them before.
    PyEval_InitThreads();

    // Add an importer for builtin modules
    load_custom_builtin_importer();

    // Search and start main.py
    const char * prog = [
        [[NSBundle mainBundle] pathForResource:@"YourApp/main" ofType:@"pyo"] cStringUsingEncoding:
        NSUTF8StringEncoding];
    
    
    //NSLog(@"Running main.pyo: %s", prog);

    FILE* fd = fopen(prog, "r");
    if ( fd == NULL ) {
        ret = 1;
        NSLog(@"Unable to open main.pyo, abort.");
    } else {
        ret = PyRun_SimpleFileEx(fd, prog, 1);
        if (ret != 0)
            NSLog(@"Application quit abnormally!");
        else
            NSLog(@"Normal Application exit");
    }
    
    Py_Finalize();
    NSLog(@"Leaving");
    
    
    // Look like the app still runn even when we leaved here.
    //exit(ret);
    //return ret;
}


void load_custom_builtin_importer() {
    static const char *custom_builtin_importer = \
        "import sys, imp\n" \
        "from os import environ\n" \
        "from os.path import exists, join\n" \
        "# Fake redirection when we run the app without xcode\n" \
        "if 'CFLOG_FORCE_STDERR' not in environ:\n" \
        "    class fakestd(object):\n" \
        "        def write(self, *args, **kw): pass\n" \
        "        def flush(self, *args, **kw): pass\n" \
        "    sys.stdout = fakestd()\n" \
        "    sys.stderr = fakestd()\n" \
        "# Custom builtin importer for precompiled modules\n" \
        "class CustomBuiltinImporter(object):\n" \
        "    def find_module(self, fullname, mpath=None):\n" \
        "        if '.' not in fullname:\n" \
        "            return\n" \
        "        if mpath is None:\n" \
        "            return\n" \
        "        part = fullname.rsplit('.')[-1]\n" \
        "        fn = join(mpath[0], '{}.so'.format(part))\n" \
        "        if exists(fn):\n" \
        "            return self\n" \
        "        return\n" \
        "    def load_module(self, fullname):\n" \
        "        f = fullname.replace('.', '_')\n" \
        "        mod = sys.modules.get(f)\n" \
        "        if mod is None:\n" \
        "            #print 'LOAD DYNAMIC', f\n" \
        "            try:\n" \
        "                mod = imp.load_dynamic(f, f)\n" \
        "            except ImportError:\n" \
        "                #print 'LOAD DYNAMIC FALLBACK', fullname\n" \
        "                mod = imp.load_dynamic(fullname, fullname)\n" \
        "            return mod\n" \
        "        return mod\n" \
        "sys.meta_path.append(CustomBuiltinImporter())";
    PyRun_SimpleString(custom_builtin_importer);
}

@implementation AppDelegate

- (void) python_thread {

    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    run_python();
    NSLog(@"Python is ending now...");
    //[pool release];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    NSLog(@"Did finish launching called.");
    self.token = nil; 
    self.stop_now = @"no";
    self.start_now = @"no";
    self.pushcheck = @"no";
    UIUserNotificationType types = UIUserNotificationTypeBadge |
                 UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings =
                [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [application registerUserNotificationSettings:mySettings];
    //[application registerForRemoteNotifications];
    [NSThread detachNewThreadSelector:@selector(python_thread) toTarget: self withObject:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if ([self.pushcheck isEqualToString:@"yes"]) {
	    NSLog(@"Instructing shutdown, pushcheck: %@", self.pushcheck);
	    self.stop_now = @"yes";
    }
    NSLog(@"We will go to inactive, now...");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"We backgrounded!");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"We're about to enter the foreground.....");
    if ([self.pushcheck isEqualToString:@"yes"]) {
	NSLog(@"Instructing shutdown, pushcheck: %@", self.pushcheck);
        self.start_now = @"yes";
    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [application cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 0;
    NSLog(@"We're active now....");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"We're about to background.............");
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        //register to receive notifications
        [application registerForRemoteNotifications];
    } else {
        // same as response to didFailToRegisterForRemoteNotificationsWithError
        NSDictionary* data = [NSDictionary dictionaryWithObject:@"foo bar baz" forKey:@"deviceToken"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationsRegistered" object:self userInfo:data];
    }    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *stringToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                         ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                         ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                         ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    //NSLog(@"Did Register for Remote Notifications with Device Token (%@)", stringToken);
    self.pushcheck = @"yes";
    self.token = stringToken;
    [self.couch storePushToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    self.pushcheck = @"yes";
    NSLog(@"Failed to register for remote notifications: %@, %@", error, error.localizedDescription);
}

@end
