//
//  WTUnitySDK.m
//  ARCameraDemo
//
//  Created by innerpeacer on 2022/3/30.
//

#import "WTUnitySDK.h"

void ShowAlert(NSString *title, NSString *msg) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];

    auto delegate = [[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

UnityFramework *LoadUnityFramework() {
    NSLog(@"UnityFrameworkLoad");
    
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *bundlePath = [mainBundlePath stringByAppendingString:@"/Frameworks/UnityFramework.framework"];

    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    if ([bundle isLoaded] == false) {
        NSLog(@"[bundle load]");
        [bundle load];
    }
    NSLog(@"isLoaded: %d", [bundle isLoaded]);

    UnityFramework *ufw = [bundle.principalClass getInstance];
    if (![ufw appController]) {
        [ufw setExecuteHeader:&_mh_execute_header];
    }
    return ufw;
}

@interface WTUnitySDK() <UnityFrameworkListener> {
    int gArgc;
    char **gArgv;
    NSDictionary *appLaunchOpts;
    
    UIWindow *mainWindow;
}

@property UnityFramework *ufw;
@property BOOL quitted;

@end

@implementation WTUnitySDK

- (id)init {
    self = [super init];
    if (self) {
        gArgc = 0;
        gArgv = nullptr;
    }
    return self;
}

+ (WTUnitySDK *)sharedSDK
{
    static dispatch_once_t onceToken;
    static WTUnitySDK *sharedInstance = nil;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[WTUnitySDK alloc] init];
    });
    
    return sharedInstance;
}

+ (UnityFramework *)ufw
{
    return [WTUnitySDK sharedSDK].ufw;
}

- (BOOL)isUnityInitialized
{
//    return _ufw && [_ufw appController];
    return _ufw;
}

- (BOOL)isQuitted
{
    return _quitted;
}

-(void)runInMainWithArgc:(int)argc argv:(char **)argv {
    gArgc = argc;
    gArgv = argv;
}

- (void)setLaunchOptions:(NSDictionary *)opts {
    appLaunchOpts = opts;
}

- (void)setMainWindow:(UIWindow *)window
{
    mainWindow = window;
}

- (void)preloadIfNeed
{
    NSLog(@"[WTUnitySDK].preload");
    if ([self isUnityInitialized]) {
        return;
    }
    
    if (self.quitted) {
        return;
    }
    
    if (_ufw == nil) {
        _ufw = LoadUnityFramework();
        [_ufw setDataBundleId:"com.unity3d.framework"];
    }
}

- (BOOL)initUnity
{
    if ([self isUnityInitialized]) {
        ShowAlert(@"Unity already initilized", @"Unload Unity first");
        return NO;
    }
    
    if (self.quitted) {
        ShowAlert(@"Unity cannot be initilized after quit", @"Use unload instead");
        return NO;
    }
    
    if (_ufw == nil) {
        _ufw = LoadUnityFramework();
        [_ufw setDataBundleId:"com.unity3d.framework"];
    }
    
    [_ufw registerFrameworkListener:self];
    //    [NSClassFromString(@"WTUnityCallbackUtils") registerApiForTestingCallbacks:self];
    [_ufw runEmbeddedWithArgc:gArgc argv:gArgv appLaunchOpts:appLaunchOpts];
    
    [_ufw appController].quitHandler  = ^(){
        NSLog(@"AppController.quitHander called");
    };
    return YES;
}

- (void)showNativeWindow
{
    [mainWindow makeKeyAndVisible];
}

- (void)showUnityWindow
{
    NSLog(@"[WTUnitySDK].showUnityWindow");
    [self initUnity];
}

- (void)unloadUnity
{
    if (![self isUnityInitialized]) {
        ShowAlert(@"Unity is not initialized", @"Initialize Unity first");
    } else {
        [_ufw unloadApplication];
    }
}

- (void)quitUnity
{
    if (![self isUnityInitialized]) {
        ShowAlert(@"Unity is not initialized", @"Initialize Unity first");
    } else {
        [_ufw quitApplication:0];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[_ufw appController] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[_ufw appController] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[_ufw appController] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[_ufw appController] applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[_ufw appController] applicationWillTerminate:application];
}

- (void)unityDidUnload:(NSNotification *)notification
{
    NSLog(@"unityDidUnload");
    [_ufw unregisterFrameworkListener:self];
    _ufw = nil;
//    [self showHostMainWindow:@""];
}

- (void)unityDidQuit:(NSNotification *)notification
{
    NSLog(@"unityDidQuit");
    
    [_ufw unregisterFrameworkListener:self];
    _ufw = nil;
    _quitted = YES;
//    [self showHostMainWindow:@""];
}

@end