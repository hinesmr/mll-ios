//
//  mica.m
//  reader 
//
//  Created by Michael R. Hines on 8/13/14.
//
//
#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import <CouchbaseLiteListener/CBLListener.h>
#import <CouchbaseLite/CBLView.h>
#include <stdlib.h>
#include <string.h>

#import "mica.h"
#import "main.h"


@implementation MyViewController {
    UIWindow * window;
    UIWebView * webview;
    CGFloat width;
    CGFloat height;
}

- (BOOL)prefersStatusBarHidden {
    //NSLog(@"preferStatusBarHidden was called.");
    return YES;
}

- (BOOL) shouldAutorotate {
    //NSLog(@"shouldAutorotate was called.");
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    //NSLog(@"supportedInterfaceOrientations was called.");
    return UIInterfaceOrientationMaskAll;
    //return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //NSLog(@"shouldAutorotateToInterfaceOrientation was called.");
    return YES;
}
/*

- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    NSLog(@"again!again!!!!!!!!!!!! old orientation width: %d height %d", (int)self->webview.frame.size.width, (int)self->webview.frame.size.height);
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"HEY We're about to rotate!!!!!!!!!!! old orientation width: %d height %d", (int)self->webview.frame.size.width, (int)self->webview.frame.size.height);

    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
	 NSLog(@"Going to landscape");
         [self->webview setFrame:CGRectMake(0, 0, self->height, self->width)];
    } else {
	 NSLog(@"Going to portrait");
         [self->webview setFrame:CGRectMake(0, 0, self->width, self->height)];
    }
    NSLog(@"HEY We're about to rotate!!!!!!!!!!! new orientation width: %d height %d", (int)self->webview.frame.size.width, (int)self->webview.frame.size.height);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"HEY we rotated!!!!!!!!!!! new orientation width: %d height %d", (int)self->webview.frame.size.width, (int)self->webview.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];

   NSLog(@"viewWillAppear called: %@", self.traitCollection);
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id)coordinator
{
   NSLog(@"willTransitionToTraitCollection called: %@", newCollection);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"NEW ROTATION function was called for ios 8.");
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    //The device has already rotated, that's why this method is being called.
    UIInterfaceOrientation toOrientation   = [[UIDevice currentDevice] orientation];
    //fixes orientation mismatch (between UIDeviceOrientation and UIInterfaceOrientation)
    if (toOrientation == UIInterfaceOrientationLandscapeRight) toOrientation = UIInterfaceOrientationLandscapeLeft;
    else if (toOrientation == UIInterfaceOrientationLandscapeLeft) toOrientation = UIInterfaceOrientationLandscapeRight;

    UIInterfaceOrientation fromOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    [self willRotateToInterfaceOrientation:toOrientation duration:0.0];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self willAnimateRotationToInterfaceOrientation:toOrientation duration:[context transitionDuration]];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self didRotateFromInterfaceOrientation:fromOrientation];
    }];
}
*/

- (void) setWebView :(UIWebView *) wv
{
    self->webview = wv;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
	    self->width = wv.frame.size.height;
	    self->height = wv.frame.size.width;
    } else {
	    self->width = wv.frame.size.width;
	    self->height = wv.frame.size.height;
    }
    self->webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self->webview.scalesPageToFit = YES;
}
@end

@implementation mica {
    NSMutableDictionary * dbs;
    NSMutableDictionary * urls;
    NSMutableDictionary * filters;
    NSMutableDictionary * pushes;
    NSMutableDictionary * pulls;
    NSMutableDictionary * seeds;
    NSMutableDictionary * mappers;
    NSMutableDictionary * reducers;
    NSString * maindb;

    UIWindow * window;
    UIWebView * webview;
    double pull_percent;
    double push_percent;
    Reachability *reachability;
    CBLListener* listener;
};

- (id) init {
    if(self = [super init]) {
        self->pull_percent = 100.0;
        self->push_percent = 100.0;
        self->window = nil;
        self->webview = nil;
	self->listener = nil;
        self->maindb = nil;
        //NSLog(@"mica bridge class initialized.");
        self->dbs = [[NSMutableDictionary alloc] init];
        self->pushes = [[NSMutableDictionary alloc] init];
        self->pulls = [[NSMutableDictionary alloc] init];
        self->urls = [[NSMutableDictionary alloc] init];
        self->filters = [[NSMutableDictionary alloc] init];
        self->seeds = [[NSMutableDictionary alloc] init];
        self->mappers = [[NSMutableDictionary alloc] init];
        self->reducers = [[NSMutableDictionary alloc] init];

        //[CBLManager enableLogging:@"Sync"];
        //[CBLManager enableLogging:@"SyncVerbose"];
        //[CBLManager enableLogging:@"ChangeTracker"];
        //[CBLManager enableLogging:@"ChangeTrackerVerbose"];
        //[CBLManager enableLogging:@"View"];
        //[CBLManager enableLogging:@"ViewVerbose"];
        //[CBLManager enableLogging:@"WS"];
        //[CBLManager enableLogging:@"RemoteRequest"];
        //[CBLManager enableLogging:@"RemoteRequestVerbose"];
        //[CBLManager enableLogging:@"Query"];
        //[CBLManager enableLogging:@"QueryVerbose"];
        //[CBLManager enableLogging:@"CBLDatbase"];
        //[CBLManager enableLogging:@"CBLDatbaseVerbose"];
        //[CBLManager enableLogging:@"CBL_Server"];
        //[CBLManager enableLogging:@"CBL_ServerVerbose"];
	//[CBLManager enableLogging:@"Listener"];
	//[CBLManager enableLogging:@"ListenerVerbose"];
	//[CBLManager enableLogging:@"CBL_Listener"];
	//[CBLManager enableLogging:@"CBL_ListenerVerbose"];
	//[CBLManager enableLogging:@"CBLListener"];
	//[CBLManager enableLogging:@"CBLListenerVerbose"];
        //[CBLManager enableLogging:@"CBL_Router"];
        //[CBLManager enableLogging:@"CBL_RouterVerbose"];
        //[CBLManager enableLogging:@"CBLRouter"];
        //[CBLManager enableLogging:@"CBLRouterVerbose"];
        //[CBLManager enableLogging:@"Router"];
        //[CBLManager enableLogging:@"RouterVerbose"];

	self->reachability = [Reachability reachabilityForInternetConnection];
	[self->reachability startNotifier];

	CBLReduceBlock countReducer = ^id(NSArray *keys, NSArray *values, BOOL rereduce) {
	    if (rereduce) {
		return [CBLView totalValues: values];
	    } else {
		return @(values.count);
	    }
        };

 	[self->mappers setValue: MAPBLOCK({
            NSString * _id = doc[@"_id"];
            if ([_id rangeOfString:@"MICA:[^:]+:stories:[^:]+$" options:NSRegularExpressionSearch].location != NSNotFound && doc[@"translating"] != nil) {
		if (doc[@"translating"]) {
			NSArray *chunks = [_id componentsSeparatedByString: @":"];
			emit([NSArray arrayWithObjects:chunks[1], doc[@"name"], nil], doc);
		}
            }
        }) forKey:@"stories/translating"];

 	[self->mappers setValue: MAPBLOCK({
            NSString * _id = doc[@"_id"];
            if ([_id rangeOfString:@"MICA:[^:]+:stories:[^:]+$" options:NSRegularExpressionSearch].location != NSNotFound && doc[@"upgrading"] != nil) {
		if (doc[@"upgrading"]) {
			NSArray *chunks = [_id componentsSeparatedByString: @":"];
			emit([NSArray arrayWithObjects:chunks[1], doc[@"name"], nil], doc);
		}
            }
        }) forKey:@"stories/upgrading"];

 	[self->mappers setValue: MAPBLOCK({
            NSString * _id = doc[@"_id"];
            if ([_id rangeOfString:@"MICA:[^:]+:stories:[^:]+$" options:NSRegularExpressionSearch].location != NSNotFound) {
		        NSArray *chunks = [_id componentsSeparatedByString: @":"];
                emit([NSArray arrayWithObjects:chunks[1], doc[@"name"], nil], doc);
            }
        }) forKey:@"stories/all"];

 	[self->mappers setValue: MAPBLOCK({
            NSString * _id = doc[@"_id"];
            if ([_id rangeOfString:@"MICA:[^:]+:stories:chat;[^;]+;[^;]+;[^;:]+$" options:NSRegularExpressionSearch].location != NSNotFound) {
		        NSArray *pre_chunks = [_id componentsSeparatedByString: @":"];
		        NSArray *chunks = [pre_chunks[3] componentsSeparatedByString: @";"];
                emit([NSArray arrayWithObjects:pre_chunks[1], chunks[1], chunks[3], nil], doc);
            }
        }) forKey:@"chats/all"];

 	[self->mappers setValue: MAPBLOCK({
            NSString * _id = doc[@"_id"];
            if ([_id rangeOfString:@"MICA:[^:]+:stories:[^:]+:pages:[^:]+$" options:NSRegularExpressionSearch].location != NSNotFound) {
		NSArray *chunks = [_id componentsSeparatedByString: @":"];
                emit([NSArray arrayWithObjects:chunks[1], chunks[3], chunks[5], nil], doc);
            }
        }) forKey:@"stories/allpages"];

	[self->mappers setValue: [self->mappers valueForKey:@"stories/allpages"] forKey: @"stories/pages"];
	[self->reducers setValue: countReducer forKey: @"stories/pages"];

 	[self->mappers setValue: MAPBLOCK({
            NSString * _id = doc[@"_id"];
            if ([_id rangeOfString:@"MICA:[^:]+:stories:[^:]+:original:[^:]+$" options:NSRegularExpressionSearch].location != NSNotFound) {
		NSArray *chunks = [_id componentsSeparatedByString: @":"];
                emit([NSArray arrayWithObjects:chunks[1], chunks[3], chunks[5], nil], doc);
            }
        }) forKey:@"stories/alloriginal"];

	[self->mappers setValue: [self->mappers valueForKey:@"stories/alloriginal"] forKey: @"stories/original"];
	[self->reducers setValue: countReducer forKey: @"stories/original"];

 	[self->mappers setValue: MAPBLOCK({
            NSString * _id = doc[@"_id"];
            if ([_id rangeOfString:@"MICA:[^:]+:memorized:[^:]+$" options:NSRegularExpressionSearch].location != NSNotFound) {
		NSArray *chunks = [_id componentsSeparatedByString: @":"];
                emit([NSArray arrayWithObjects:chunks[1], chunks[3], nil], doc);
            }
        }) forKey:@"memorized2/all"];

	//[self->mappers setValue: [self->mappers valueForKey:@"memorized/all"] forKey: @"memorized/allcount"];
	//[self->reducers setValue: countReducer forKey: @"memorized/allcount"];

 	[self->mappers setValue: MAPBLOCK({
            NSString * lang = doc[@"source_language"];
            if (lang == nil) {
                lang = @"zh-CHS";
		NSArray * sromanization = doc[@"sromanization"];
		NSArray * target = doc[@"target"];
                if (sromanization != nil) {
                    if ([sromanization count] == 0) {
                        lang = @"en";
                    } else {
                        NSString * merged = @"";
                        NSArray * source = doc[@"source"];
                        for (NSString* part in source) {
                            merged = [merged stringByAppendingString:part];
                        }
                        if ([sromanization count] == 1 && [merged isEqualToString:sromanization[0]]) {
                            if ([source count] > 1 || ![source[0] isEqualToString:sromanization[0]]) {
                                if ([target count] == 0 || ![sromanization[0] isEqualToString:target[0]]) {
                                    lang = @"en";
                                }
                            }
                        }
                    }
                }
            }
            NSString * _id = doc[@"_id"];
            if ([_id rangeOfString:@"MICA:[^:]+:memorized:[^:]+$" options:NSRegularExpressionSearch].location != NSNotFound) {
		NSArray *chunks = [_id componentsSeparatedByString: @":"];
                emit([NSArray arrayWithObjects:chunks[1], lang, chunks[3], nil], doc);
            }
        }) forKey:@"memorized2/allcount"];

	[self->reducers setValue: countReducer forKey: @"memorized2/allcount"];

 	[self->mappers setValue: MAPBLOCK({
            NSString * _id = doc[@"_id"];
            if ([_id rangeOfString:@"MICA:[^:]+:mergegroups:[^:]+$" options:NSRegularExpressionSearch].location != NSNotFound) {
		NSArray *chunks = [_id componentsSeparatedByString: @":"];
                emit([NSArray arrayWithObjects:chunks[1], chunks[3], nil], doc);
            }
        }) forKey:@"mergegroups/all"];

 	[self->mappers setValue: MAPBLOCK({
            NSString * _id = doc[@"_id"];
            if ([_id rangeOfString:@"MICA:[^:]+:splits:[^:]+$" options:NSRegularExpressionSearch].location != NSNotFound) {
		NSArray *chunks = [_id componentsSeparatedByString: @":"];
                emit([NSArray arrayWithObjects:chunks[1], chunks[3], nil], doc);
            }
        }) forKey:@"splits/all"];

 	[self->mappers setValue: MAPBLOCK({
            NSString * _id = doc[@"_id"];
            if ([_id rangeOfString:@"MICA:[^:]+:tonechanges:[^:]+$" options:NSRegularExpressionSearch].location != NSNotFound) {
		NSArray *chunks = [_id componentsSeparatedByString: @":"];
                emit([NSArray arrayWithObjects:chunks[1], chunks[3], nil], doc);
            }
        }) forKey:@"tonechanges/all"];

 	[self->mappers setValue: MAPBLOCK({
            if (doc[@"mica_database"] != nil) {
                emit(doc, doc);
            }
        }) forKey:@"accounts/all"];

 	[self->mappers setValue: MAPBLOCK({
            NSString * _id = doc[@"_id"];
            if ([_id rangeOfString:@"MICA:sessions:.*$" options:NSRegularExpressionSearch].location != NSNotFound) {
		NSArray *chunks = [_id componentsSeparatedByString: @":"];
                emit([NSArray arrayWithObjects:chunks[2], nil], doc);
            }
        }) forKey:@"sessions/all"];

	[self->mappers setValue: [self->mappers valueForKey:@"accounts/all"] forKey: @"accounts/allcount"];
	[self->reducers setValue: countReducer forKey: @"accounts/allcount"];
    }
    return self;
}

- (void) dealloc {
    [self->window release];
    [super dealloc];
}

- (void) webviewstatic :(NSString*)html {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
	    if (self->window != nil) {
            [self->webview release];
	        [self->window release];
            self->window = nil;
            self->webview = nil;
	    }
	    self->window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	    NSLog(@"Creating static webview splash.");
	    self->window.backgroundColor = [UIColor whiteColor];
	    [self->window makeKeyAndVisible];
	    self->webview = [[UIWebView alloc] initWithFrame: self->window.bounds];
	    MyViewController *vc = [[MyViewController alloc] init];
            [vc setWebView:self->webview];
	    [self->webview loadHTMLString:html baseURL:nil];
            self->window.rootViewController = vc;
	    [vc.view addSubview:self->webview];
    }];
}

- (void) webview :(NSString*)fullURL {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
	    if (self->window != nil) {
            [self->webview release];
	        [self->window release];
            self->window = nil;
            self->webview = nil;
	    }
	    self->window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	    NSLog(@"Creating webview. with url %@", fullURL);
	    self->window.backgroundColor = [UIColor whiteColor];
	    [self->window makeKeyAndVisible];
	    NSURL * url = [NSURL URLWithString:fullURL];
	    NSURLRequest * requestObj = [NSURLRequest requestWithURL:url];
	    self->webview = [[UIWebView alloc] initWithFrame: self->window.bounds];
	    //self->webview.scalesPageToFit = YES;
	    MyViewController *vc = [[MyViewController alloc] init];
            [vc setWebView:self->webview];
	    [self->webview loadRequest:requestObj];
	    self->window.rootViewController = vc;
	    [vc.view addSubview:self->webview];
    }];

}

+ (NSString *) toString:(NSDictionary *) json
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options: 0 error:&error];
    NSString *jsonString = nil;

    if(!jsonData) {
        NSLog(@"COUCH ERROR: toString got a json conversion error: %@", error);
        return nil;
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding: NSUTF8StringEncoding];
    }

    return jsonString;
}

+ (NSDictionary *) toJSON:(NSString *) dict
{
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [dict dataUsingEncoding: NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];

    if(!json) {
        NSLog(@"COUCH ERROR: toJSON got a json conversion error: %@", error);
        return nil;
    }

    return json;
}

#define FINISH(result, fmt, ...)                                                                            \
do {                                                                                                    \
NSString * msg = [NSString stringWithFormat:fmt, ## __VA_ARGS__ ];                                  \
if (result == nil)                                                                                  \
NSLog(@"COUCH ERROR: %@", msg);                                                                 \
else                                                                                                \
return result;                                                                                      \
} while(0)

#define DBCHECK()                                                                   \
CBLDatabase * db = nil;                                                     \
do {                                                                            \
db = [self->dbs valueForKey: dbname];                                       \
if (db == nil)                                                              \
FINISH(nil, @"Could not find database: %@", dbname);                    \
} while(0)

- (NSString *) get_attachment: (NSString *) dbname :(NSString *) key :(NSString *)filename
{
    DBCHECK();
    CBLDocument *doc = [db existingDocumentWithID:key];
    if (doc == nil) {
        FINISH(nil, @"Uh oh. Key is missing for attachment %@ : %@", key, filename);
    }
    CBLRevision * rev = doc.currentRevision;
    CBLAttachment * att = [rev attachmentNamed:filename];

    if (att == nil) {
        FINISH(nil, @"Uh oh. Attachment is missing: %@", filename);
    }

    NSString * data = [[NSString alloc] initWithData:att.content encoding:NSASCIIStringEncoding];
    FINISH(data, @"Getting attachment by string-only not yet implemented.");
}

- (NSString *) get_attachment_meta: (NSString *) dbname :(NSString *) key :(NSString *)filename
{
    DBCHECK();

    //NSLog(@"Getting only meta data for docid: %@", key);

    CBLDocument *doc = [db documentWithID:key];
    CBLRevision * rev = doc.currentRevision;
    CBLAttachment * att = [rev attachmentNamed:filename];

    if (att == nil) {
        FINISH(nil, @"Uh oh. Attachment is missing: %@", filename);
    }

    NSDictionary * oprops = att.metadata;
    NSMutableDictionary * iprops = [[NSMutableDictionary alloc] init];
    [iprops addEntriesFromDictionary:oprops];
    NSString * json = [mica toString:iprops];
    FINISH(json, @"Success getting attachment %@ from key %@ db %@", filename, key, dbname);
}


- (int)listen: (NSString *)user :(NSString *)pass :(NSString *)requestedPort
{
    int port = requestedPort.intValue;
    CBLManager * mgr = [CBLManager sharedInstance];
    NSError * error;

    /* This doesn't seem to work. It has to be in the listener. */
    [mgr.customHTTPHeaders setObject:@"http://localhost:10000" forKey:@"Access-Control-Allow-Origin"];
    [mgr.customHTTPHeaders setObject:@"604800" forKey: @"Access-Control-Max-Age"];
    [mgr.customHTTPHeaders setObject:@"GET, PUT, POST, DELETE, OPTIONS" forKey:@"Access-Control-Allow-Methods"];
    [mgr.customHTTPHeaders setObject:@"accept, origin, authorization, content-type" forKey:@"Access-Control-Allow-Headers"];
    [mgr.customHTTPHeaders setObject:@"true" forKey:@"Access-Control-Allow-Credentials"];

    if (self->listener == nil) {
        self->listener = [[CBLListener alloc] initWithManager: mgr port: port];
	if (self->listener == nil) {
	    NSLog(@"Failed to start listener.");
	    return -1;
	}
	self->listener.readOnly = YES;
	self->listener.passwords = @{user : pass};
	if (![self->listener start: &error]) {
	    NSLog(@"Failed to start HTTP listener: %@", error.localizedDescription);
	    return -1;
	}
	
	//NSLog(@"Started: %@, %@, %d", user, pass, port);
    } else {
        NSLog(@"Listener already started!");
    }

    return self->listener.port;
}

- (int)drop: (NSString *) dbname
{
    NSError* error;
    DBCHECK();

    [self->dbs removeObjectForKey:dbname];

    [self stop_replication:dbname];

    if (![db deleteDatabase: &error]) {
        NSLog(@"Could not delete database: %@ because %@", dbname, error);
        return -1;
    }

    NSLog(@"Database dropped successfully: %@.", dbname);
    db = nil;

    return 0;
}

- (int)start: (NSString *) dbname
{
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    CBLDatabase *db = [self->dbs valueForKey: dbname];
    if (db != nil) {
        NSLog(@"Started: db %@ already opened.", dbname);
        return -1;
    }

    NSLog(@"Starting db %@", dbname);

    NSError * error;
    db = [[CBLManager sharedInstance] databaseNamed:dbname error: &error];

    if (!db) {
        NSLog(@"Could not open database: %@ because %@", dbname, error);
        return -1;
    }

    [self->dbs setValue:db forKey:dbname];

    CBLManager * mgr = [CBLManager sharedInstance];
    mgr.excludedFromBackup = YES;
    NSString *version = @"14";

    for (NSString* key in self->mappers) {
        //NSLog(@"Installing native mapreduce for: %@", key);	
	CBLReduceBlock reducer = [self->reducers objectForKey:key];
	CBLMapBlock mapper = [self->mappers objectForKey:key];
        [[db viewNamed: key] setMapBlock:mapper reduceBlock: reducer version: version];
    }

   appDelegate.couch = self;

   NSLog(@"Start complete db %@", dbname);

   if (appDelegate.token != nil && ![dbname isEqualToString: @"files"] && ![dbname isEqualToString:@"sessiondb"]) {
       NSLog(@"We found a token: %@. Registering...", appDelegate.token);
       self->maindb = dbname;
       [self _storePushToken : self->maindb];
   } else {
       NSLog(@"Skipping DB token check: %@ %@", appDelegate.token, dbname);
   }

   return 0;
}

+ (NSDictionary *) _get:(CBLDatabase *) db key: (NSString*)key
{
    CBLDocument *doc = [db documentWithID:key];

    NSDictionary *props;
    if (doc != nil)
        props = doc.properties;

    if (doc == nil || props == nil)
        return nil;

    return props;
}

- (void) _storePushToken: (NSString *) dbname 
{
    DBCHECK();
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
//    NSLog(@"We successfully reached view controller. Ready to store token");

#if !TOKEN_ENV_SANDBOX
    NSString * which = @"apns_dist";
//    NSLog(@"TOKEN_ENV==PRODUCTION");
#endif

#if TOKEN_ENV_SANDBOX
    NSString * which = @"apns_dev";
//    NSLog(@"TOKEN_ENV==SANDBOX");
#endif

    NSDictionary *tmpprops = [mica _get : db key: @"MICA:push_tokens"];
    NSDictionary *props;
    BOOL found = NO;

    if (tmpprops == nil) {
        //NSLog(@"Push document doesn't exist. Creating a new one");
        props = @{
	    @"gcm" : [[NSMutableArray alloc] init],
	    @"apns_dev" : [[NSMutableArray alloc] init], 
	    @"apns_dist" : [[NSMutableArray alloc] init],
	};
    } else {
        props = [tmpprops mutableCopy];
        [props setValue:[[props valueForKey:which ] mutableCopy] forKey:which];
    }

    NSMutableArray * tokens = [props valueForKey:which];
    for (NSString * tok in tokens) {
        if ([tok isEqualToString: appDelegate.token]) {
            found = YES;
            break;
        }
    }

    if(found == NO) {
       NSError * error;
       [tokens addObject:appDelegate.token];
       NSLog(@"Token not found: Appending: %@", [mica toString:props]);
       CBLDocument *doc = [db documentWithID:@"MICA:push_tokens"];
       if (![doc putProperties:props error:&error]) {
           NSLog(@"Failed to push tokens into DB: %@", error);
       }
    }
    //NSLog(@"Token storage complete.");
}

- (void) storePushToken
{
  if (self->maindb != nil) {
      [self _storePushToken : self->maindb];
  }
}


- (NSString *) doc_exist: (NSString *) dbname :(NSString *) key
{
    DBCHECK();
    //NSLog(@"Checking doc_exist for key: %@ from db %@", key, dbname);
    NSDictionary *props = [mica _get : db key: key];
    if (props == nil) {
        FINISH(@"false", @"No such key: %@", key);
    }

    FINISH(@"true", @"key found: %@", key);
    return nil; //no effect
}

- (NSString *) get:(NSString *) dbname :(NSString *) key
{
    DBCHECK();

    //NSLog(@"Looking up document with key: %@ from db %@", key, dbname);

    NSDictionary *props = [mica _get : db key: key];
    if (props == nil)
        FINISH(@"", @"Could not find document: %@ from database: %@", key, dbname);

    NSString *dict = [mica toString:props];
    FINISH(dict, @"Got value from key: %@ db %@", key, dbname);
    return nil; //no effect
}

- (NSString *)delete:(NSString *) dbname :(NSString *) key
{
    NSError * error;
    DBCHECK();

    //NSLog(@"Looking up document with key: %@ from db %@", key, dbname);
    CBLDocument *doc = [db existingDocumentWithID:key];

    NSDictionary *props;
    if (doc != nil)
        props = doc.properties;

    if (doc == nil || props == nil)
        FINISH(@"Failure. Document does not exist.", @"Could not find document: %@ from database: %@", key, dbname);

    if (![doc deleteDocument: &error])
        FINISH(error.localizedDescription, @"Could not delete document: %@ from database: %@", key, dbname);

    FINISH(@"", @"Deleted document with key: %@ db %@", key, dbname);
    return nil; //no effect
}

+ (NSString *) _path:(NSString *) path
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    return [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:path]];
}

- (NSString *)get_attachment_to_path:(NSString *) dbname :(NSString *) docid :(NSString *) filename : (NSString *) path
{
    DBCHECK();

    //    path = [path stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    //    path = [path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];

    NSString * desc = [NSString stringWithFormat:@"for export (db %@) attachment: %@ to path %@ using filename %@", dbname, docid, path, filename];

    CBLDocument * doc = [db existingDocumentWithID:docid];

    if (doc == nil)
        FINISH(@"failed document does not exist.", @"No such document %@", desc);

    CBLRevision * rev = doc.currentRevision;

    if (rev == nil)
        FINISH(@"failed no revision for document", @"No revision for document %@", desc);

    CBLAttachment * att = [rev attachmentNamed:filename];

    if (att == nil)
        FINISH(@"failed no contents for document", @"No contents for document %@", desc);

    NSData * data = att.content;

    //NSString * databasePath = [mica _path: path];
    NSString * databasePath = path;

    //    NSError *error;

    //NSLog(@"Attachment retrieved. Writing to file...");

    if ([data writeToFile:databasePath atomically:YES])
        //    if ([data writeToFile:databasePath options:0 error:&error])
        FINISH(@"", @"Finished %@", desc);
    else
        FINISH(@"failed", @"Failed %@", desc);
    return nil; //no effect
}

/*
 - (void)put_attachment_from_path:(CDVInvokedUrlCommand*)cmd
 {
 CBLDatabase *db;
 NSString * docid = [cmd.arguments objectAtIndex:0];
 NSString * filename = [cmd.arguments objectAtIndex:1];
 NSString * contentType = [cmd.arguments objectAtIndex:2];
 NSString * path = [[cmd.arguments objectAtIndex:3] stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
 NSString * desc = [NSString stringWithFormat:@" for import (db %@) attachment: %@ to path %@ using filename %@ type %@", dbname, docid, path, filename, contentType];

 path = [path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];

 DBCHECK();

 CBLDocument * doc = [db existingDocumentWithID:docid];

 if (doc == nil)
 FINISH(nil, @"No such document %@", desc);

 CBLUnsavedRevision * rev = [doc.currentRevision createRevision];

 if (rev == nil)
 FINISH(nil, @"No revision for document %@", desc);

 NSError * error;
 //NSString * databasePath = [mica _path: path];
 NSString * databasePath = path;

 NSData * data = [[NSFileManager defaultManager] contentsAtPath:databasePath];

 if (data == nil)
 FINISH(nil, @"Could not open file %@ %@", databasePath, desc);

 if (contentType == nil)
 contentType = @"";
 [rev setAttachmentNamed:filename withContentType:contentType content:data];

 if ([rev save: &error])
 FINISH(@"success", @"Finished %@", desc);
 else
 FINISH(nil, @"Failed: %@ %@", error, desc);
 }
 */

- (NSString *)put:(NSString *) dbname :(NSString *) key :(NSString *) value
{
    NSError * error;
    DBCHECK();

    NSDictionary * json = [mica toJSON:value];
    //NSLog(@"Putting document with key: %@ from db %@", key, dbname);
    CBLDocument *doc = [db documentWithID:key];

    if (doc == nil)
        FINISH(@"Could not prepare to put.", @"Could prepare document for putting find document: %@ from database: %@", key, dbname);

    if (![doc putProperties:json error:&error])
        FINISH(error.localizedDescription, @"Could put document %@ to database: %@", key, dbname);

    FINISH(@"", @"Put value to key: %@ db %@", key, dbname);
    return nil; //no effect
}

- (NSString *) connected {
	NetworkStatus status = [reachability currentReachabilityStatus];

	if(status == NotReachable)
	{
	    //NSLog(@"INTERNET No, we are offline.");
	    return @"none";
	} else {
		if (status == ReachableViaWWAN) {
		    //NSLog(@"INTERNET We are on expensive internet.");
		    return @"expensive";
		} else if (status == ReachableViaWiFi) {
		    //NSLog(@"INTERNET We are on wifi.");
		    return @"online";
		}
	}
        return @"none";
}

- (void)stop_replication:(NSString *) dbname
{
    CBLReplication * push = [self->pushes valueForKey:dbname];
    CBLReplication * pull = [self->pulls valueForKey:dbname];

    if (pull) {
        [self->pulls removeObjectForKey:dbname];
        [pull stop];
    }

    if (push) {
        [self->pushes removeObjectForKey:dbname];
        [push stop];
    }

    NSLog(@"Database: %@ stopped replicating.", dbname);
}

- (CBLQueryEnumerator *) view:(NSString *) dbname :(NSString *) designDoc :(NSString *) viewName :(NSString *) params
{
    NSString * name = [NSString stringWithFormat:@"%@/%@", designDoc, viewName];

    DBCHECK();

    CBLView * v = [db viewNamed: name];
    NSAssert(v != nil, @"view %@ not found", name);

    CBLQuery *query = [v createQuery];
    if (![name isEqualToString:@""]) {
        NSDictionary * json = [mica toJSON:params];

        if ([json valueForKey: @"startkey"] != nil) {
            query.startKey = [json valueForKey: @"startkey"];
        }
        if ([json valueForKey: @"endkey"] != nil) {
            query.endKey = [json valueForKey: @"endkey"];
        }
        if ([json valueForKey: @"keys"] != nil) {
            NSString * uuid = [json valueForKey: @"keys"];
            //NSLog(@"Setting seed keys for uuid: %@", uuid);
            NSMutableArray * seedkeys = [self->seeds valueForKey: uuid];
            NSAssert(seedkeys != nil, @"seed keys are nil for uuid %@", uuid);
            query.keys = seedkeys;
        }
        if ([json valueForKey: @"stale"] != nil) {
            NSLog(@"COUCH: Warning View request 'stale' parameter not supported.");
        }
    }

    //NSLog(@"Running query: %@", name);
    NSError * error;
    CBLQueryEnumerator * rowEnum = [query run: &error];
    //NSLog(@"Returning iterator.");

    return rowEnum;
}

- (NSString *) view_next :(CBLQueryRow *) row
{
    NSMutableDictionary * dict   = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * result = [[NSMutableDictionary alloc] init];

    result[@"key"] = row.key;
    result[@"value"] = row.value;
    dict[@"result"] = result;

    FINISH([mica toString:dict], @"View complete.");
    return nil; //no effect
}

- (void) updateView: (NSString *) js
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
	[self->webview stringByEvaluatingJavaScriptFromString:js];
    }];
}

- (void) updateReplication: (CBLReplication *)event : (NSString *) type
{
    unsigned processed = event.completedChangesCount;
    unsigned total = event.changesCount;
    //NSLog(@"COUCH: %@ %u/%u", type, processed, total);

    if (total != 0) {
        double percent = MIN(100.0, (processed / (double)MAX(total, 1u)) * 100.0);

        if ([type isEqualToString:@"pull"]) {
            if (self->pull_percent == percent)
                return;
            self->pull_percent = percent;
        } else {
            if (self->push_percent == percent)
                return;
            self->push_percent = percent;
        }

        if ( self->webview != nil ) {
            NSString * js = [NSString stringWithFormat:@"%@stat('%.1f');", type, percent];
            [self updateView : js];
        } else {
            NSLog(@"%@ webview not alive yet.", type);
        }
    }
}

- (void)pullChanged:(NSNotification *)notification {
    [self updateReplication : notification.object : @"pull"];
}

- (void)pushChanged:(NSNotification *)notification {
    [self updateReplication : notification.object : @"push"];
}

- (int)replicate:(NSString *) dbname : (NSString *) server : (NSString *) filterparams
{
    DBCHECK();

    if ([self->pushes valueForKey: dbname] != nil && [self->pulls valueForKey: dbname]) {
        NSLog(@"Database: %@ already replicating.", dbname);
        return 0;
    }

    if ([self->urls valueForKey:dbname] == nil)
        [self->urls setValue:server forKey:dbname];

    if ([self->filters valueForKey:dbname] == nil)
        [self->filters setValue:filterparams forKey:dbname];

    NSURL * url = [NSURL URLWithString: server];
    CBLReplication *push = [db createPushReplication:url];
    CBLReplication *pull = [db createPullReplication:url];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(pushChanged:)
                                                 name: kCBLReplicationChangeNotification
     //                                             userInfo: @{@"webview" : self.webview, @"obj" : push}
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(pullChanged:)
                                                 name: kCBLReplicationChangeNotification
     //                                            userInfo: @{@"webview" : self.webview, @"obj" : push}
                                               object: nil];
    push.continuous = pull.continuous = YES;

    NSMutableDictionary * params = [[mica toJSON:filterparams] mutableCopy];
    [pull setFilter: [params valueForKey:@"name"]];
    [params removeObjectForKey:@"name"];
    [pull setFilterParams: params];

    [pull start];
    [push start];

    [self->pushes setValue:push forKey:dbname];
    [self->pulls setValue:pull forKey:dbname];

    //NSLog(@"Replication started : %@ <==> db %@", server, dbname);
    return 0;
}


- (void) runloop
{
    //NSLog(@"ios Runloop wants to check for work to do.");
    NSTimeInterval MY_EXTRA_TIME = 0.1; // 100 milliseconds
    NSDate *futureDate = [[NSDate date] dateByAddingTimeInterval:MY_EXTRA_TIME];
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:futureDate];
    //NSLog(@"ios Runloop returning");
}

- (void) view_seed :(NSString *) uuid :(NSString *) username :(NSString *) key_value
{
    NSMutableArray * keylist = [self->seeds valueForKey: uuid];
    if (keylist == nil) {
        //NSLog(@"New set of seeds for uuid %@ example %@", uuid, key_value);
        keylist = [[NSMutableArray alloc] init];
        [self->seeds setValue:keylist forKey:uuid];
    }

    NSMutableArray * keypair = [[NSMutableArray alloc] init];

    [keypair addObject:username];
    [keypair addObject:key_value];

    [keylist addObject:keypair];
}

- (void) view_seed_cleanup :(NSString *) uuid
{
    if ([self->seeds valueForKey: uuid] != nil) {
        //NSLog(@"Flushing seed keys for uuid: %@", uuid);
        [self->seeds removeObjectForKey:uuid];
    }
    //NSLog(@"Total views in progress: %d", [self->seeds count]);
}

- (NSString *) compact :(NSString *) dbname
{
    DBCHECK();
    NSError * error;
    NSLog(@"Compacting db %@...", dbname);
    if (![db compact: &error]) {
        FINISH(error.localizedDescription, @"Compaction failed for db %@: %@", dbname, error.localizedDescription);
    }
    FINISH(@"", @"Compaction for db %@ complete.", dbname);
    return nil; //no effect
}

- (NSString *) info :(NSString *) dbname
{
    DBCHECK();
    //NSLog(@"Getting db info %@...", dbname);
    NSString *dateString = [NSDateFormatter localizedStringFromDate:db.startTime
                                                      dateStyle:NSDateFormatterShortStyle 
                                                      timeStyle:NSDateFormatterFullStyle];
    NSDictionary *info = @{
	    @"size" : @(db.totalDataSize),
	    @"dbname" : dbname,
	    @"uuid" : db.publicUUID,
	    @"doc_count" : @(db.documentCount),
	    @"update_seq" : @(db.lastSequenceNumber),
	    @"disk_size" : @(db.totalDataSize),
	    @"instance_start_time " : dateString,
	};

    FINISH([mica toString:info], @"Info for db %@ complete.", dbname);
    return nil; //no effect
}


- (NSString *) get_pull_percent
{
    NSString * per = [NSString stringWithFormat:@"%.1f", self->pull_percent];
    return per;
}

- (NSString *) get_language
{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    //NSLog(@"Returning MICA language: %@", language);
    return language;
}

- (NSString *) get_push_percent
{
    NSString * per = [NSString stringWithFormat:@"%.1f", self->push_percent];
    return per;
}

@end

NSString *kReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";





#pragma mark - Supporting functions



#define kShouldPrintReachabilityFlags 1



static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)

{

#if kShouldPrintReachabilityFlags



    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",

          (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',

          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',



          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',

          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',

          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',

          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',

          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',

          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',

          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',

          comment

          );

#endif

}





static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)

{

#pragma unused (target, flags)

    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");

    NSCAssert([(__bridge NSObject*) info isKindOfClass: [Reachability class]], @"info was wrong class in ReachabilityCallback");



    Reachability* noteObject = (__bridge Reachability *)info;

    // Post a notification to notify the client that the network reachability changed.

    [[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];

}





#pragma mark - Reachability implementation



@implementation Reachability

{

    BOOL _alwaysReturnLocalWiFiStatus; //default is NO

    SCNetworkReachabilityRef _reachabilityRef;

}



+ (instancetype)reachabilityWithHostName:(NSString *)hostName

{

    Reachability* returnValue = NULL;

    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);

    if (reachability != NULL)

    {

        returnValue= [[self alloc] init];

        if (returnValue != NULL)

        {

            returnValue->_reachabilityRef = reachability;

            returnValue->_alwaysReturnLocalWiFiStatus = NO;

        }

    }

    return returnValue;

}





+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress

{

    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);



    Reachability* returnValue = NULL;



    if (reachability != NULL)

    {

        returnValue = [[self alloc] init];

        if (returnValue != NULL)

        {

            returnValue->_reachabilityRef = reachability;

            returnValue->_alwaysReturnLocalWiFiStatus = NO;

        }

    }

    return returnValue;

}







+ (instancetype)reachabilityForInternetConnection

{

    struct sockaddr_in zeroAddress;

    bzero(&zeroAddress, sizeof(zeroAddress));

    zeroAddress.sin_len = sizeof(zeroAddress);

    zeroAddress.sin_family = AF_INET;



    return [self reachabilityWithAddress:&zeroAddress];

}





+ (instancetype)reachabilityForLocalWiFi

{

    struct sockaddr_in localWifiAddress;

    bzero(&localWifiAddress, sizeof(localWifiAddress));

    localWifiAddress.sin_len = sizeof(localWifiAddress);

    localWifiAddress.sin_family = AF_INET;



    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0.

    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);



    Reachability* returnValue = [self reachabilityWithAddress: &localWifiAddress];

    if (returnValue != NULL)

    {

        returnValue->_alwaysReturnLocalWiFiStatus = YES;

    }



    return returnValue;

}

#pragma mark - Start and stop notifier

- (BOOL)startNotifier
{
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context))
    {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            returnValue = YES;
        }
    }

    return returnValue;
}

- (void)stopNotifier
{
    if (_reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}
- (void)dealloc

{
    [self stopNotifier];
    if (_reachabilityRef != NULL)
    {
        CFRelease(_reachabilityRef);
    }
    [super dealloc];
}

#pragma mark - Network Flag Handling
- (NetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags

{
    PrintReachabilityFlags(flags, "localWiFiStatusForFlags");
    NetworkStatus returnValue = NotReachable;
    if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))

    {
        returnValue = ReachableViaWiFi;
    }
    return returnValue;
}
- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{

    PrintReachabilityFlags(flags, "networkStatusForFlags");

    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)

    {
        return NotReachable;

    }

    NetworkStatus returnValue = NotReachable;
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)

    {
        returnValue = ReachableViaWiFi;
    }

    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||

        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))

    {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)

        {
            returnValue = ReachableViaWiFi;
        }
    }
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)

    {
        returnValue = ReachableViaWWAN;

    }

    return returnValue;
}

- (BOOL)connectionRequired
{

    NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");

    SCNetworkReachabilityFlags flags;

    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))

    {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    return NO;
}

- (NetworkStatus)currentReachabilityStatus
{
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    NetworkStatus returnValue = NotReachable;
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))

    {
        if (_alwaysReturnLocalWiFiStatus) {
            returnValue = [self localWiFiStatusForFlags:flags];
        }
        else {
            returnValue = [self networkStatusForFlags:flags];
        }
    }
    return returnValue;
}
@end
