//
//  ARCameraViewController.m
//  ARCameraDemo
//
//  Created by innerpeacer on 2022/4/4.
//

#import "ARCameraViewController.h"
#import "MockingFileHelper.h"
#import "WTModelInfo.h"

@interface ARCameraViewController()
{
    NSString *selectedObjectID;
    WTModelInfo *currentModelInfo;
    int testAnimationIndex;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *shootingView;
@property (weak, nonatomic) IBOutlet UIView *modelView;
@property (weak, nonatomic) IBOutlet UIButton *modelButton;
@property (weak, nonatomic) IBOutlet UIButton *mvxButton;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *startVideoButton;
@property (nonatomic, strong) UIButton *stopVideoButton;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation ARCameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)unityDidLoadEntryScene
{
    [[WTUnitySDK sharedSDK] switchToScene:[WTUnitySDK cameraScene]];
}

- (void)unityDidLoadScene:(NSString *)sceneName
{
    NSLog(@"======== Did Load Scene: %@", sceneName);
    if ([sceneName isEqualToString:[WTUnitySDK cameraScene]]) {
        [[WTUnitySDK sharedSDK] setShootingParams:WTShooting_HD];
        [[WTUnitySDK sharedSDK] setEditModeWaitingInterval:5.0f];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self view];
}

- (UIView *)viewToOverlayInUnity
{
    float width = self.modelView.frame.size.width;
    
    UIButton *button = [self createButtonWithTitle:@"Return To Native" Color:[UIColor greenColor] Action:@selector(backButtonClicked:)];
    button.center = CGPointMake(100, 100);
    [self.containerView addSubview:button];
    
    {
        UIButton *button = [self createButtonWithTitle:@"Play Animation" Color:[UIColor greenColor] Action:@selector(playAnimation:)];
        button.center = CGPointMake(width - 100, 100);
        [self.containerView addSubview:button];
    }
    
//    self.modelView.hidden = YES;
    self.shootingView.hidden = YES;
    
    {
        UIButton *button = [self createButtonWithTitle:@"Photo" Color:[UIColor greenColor] Action:@selector(takePhotoClicked:)];
        button.center = CGPointMake(100, 50);
        [self.shootingView addSubview:button];
        self.takePhotoButton = button;
    }
    
    {
        UIButton *button = [self createButtonWithTitle:@"Start Video" Color:[UIColor greenColor] Action:@selector(startVideoClicked:)];
        button.center = CGPointMake(width-120, 50);
        [self.shootingView addSubview:button];
        self.startVideoButton = button;
    }
    
    {
        UIButton *button = [self createButtonWithTitle:@"Stop Video" Color:[UIColor greenColor] Action:@selector(stopVideoClicked:)];
        button.center = CGPointMake(width-120, 150);
        [self.shootingView addSubview:button];
        self.stopVideoButton = button;
        self.stopVideoButton.enabled = NO;
    }
    
    {
        UIButton *button = [self createButtonWithTitle:@"Back To Main" Color:[UIColor redColor] Action:@selector(backButtonClicked:)];
        button.center = CGPointMake(100, 150);
        [self.shootingView addSubview:button];
        self.backButton = button;
    }
    
    [self.modelButton addTarget:self action:@selector(modelSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.mvxButton addTarget:self action:@selector(modelSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchButton addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.removeButton addTarget:self action:@selector(removeObjectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self showRemoveButton:NO];

    return self.containerView;
}

- (IBAction)playAnimation:(id)sender
{
    if (currentModelInfo == nil) {
        return;
    }
    
    if (testAnimationIndex >= currentModelInfo.animation.clips.count) {
        testAnimationIndex = 0;
    }
    WTAnimatinoClip *clip = currentModelInfo.animation.clips[testAnimationIndex++];
    [[WTUnitySDK sharedSDK] playCameraAnimation:clip.clipName];
}

- (void)showRemoveButton:(BOOL)show
{
    self.removeButton.hidden = !show;
}

- (IBAction)modelSelected:(id)sender
{
    NSLog(@"modelSelected");
    if (sender == self.mvxButton) {
//        [self useMvxModel:@"1" async:NO];
        [self useMvxModel:@"1" async:YES];
    } else if (sender == self.modelButton) {
        [self useWabModel:@"techgirl" async:YES];
//        int random = arc4random() % 2;
//        if (random == 0) {
//            [self useGlbModel:@"Flamingo" async:NO];
//        } else {
//            [self useWabModel:@"techgirl" async:YES];
//        }
    }
    [self switchView];
}

- (void)useWabModel:(NSString *)modelName async:(BOOL)async
{
    NSLog(@"Use Wab");
    NSString *dir = [[MockingFileHelper modelRootDirectory] stringByAppendingPathComponent:@"WAB"];
    NSString *modelPath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wab", modelName]];
    NSString *modelInfoPath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", modelName]];
    if (async) {
        [[WTUnitySDK sharedSDK] useModelAsyncWithPath:modelPath InfoPath:modelInfoPath];
    } else {
        [[WTUnitySDK sharedSDK] useModelWithPath:modelPath InfoPath:modelInfoPath];
    }
}

- (void)useMvxModel:(NSString *)modelName async:(BOOL)async
{
    NSLog(@"Use Mvx");
    NSString *dir = [[MockingFileHelper modelRootDirectory] stringByAppendingPathComponent:@"MVX"];
    NSString *modelPath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mvx", modelName]];
    NSString *modelInfoPath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", modelName]];
    if (async) {
        [[WTUnitySDK sharedSDK] useModelAsyncWithPath:modelPath InfoPath:modelInfoPath];
    } else {
        [[WTUnitySDK sharedSDK] useModelWithPath:modelPath InfoPath:modelInfoPath];
    }
}

- (void)useGlbModel:(NSString *)modelName async:(BOOL)async
{
    NSLog(@"Use Glb");
    NSString *dir = [[MockingFileHelper modelRootDirectory] stringByAppendingPathComponent:@"GLB"];
    NSString *modelPath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.glb", modelName]];
    NSString *modelInfoPath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", modelName]];
    if (async) {
        [[WTUnitySDK sharedSDK] useModelAsyncWithPath:modelPath InfoPath:modelInfoPath];
    } else {
        [[WTUnitySDK sharedSDK] useModelWithPath:modelPath InfoPath:modelInfoPath];
    }
}

- (void)useFrameWabModel:(NSString *)modelName async:(BOOL)async
{
    NSLog(@"Use FrameWab");
    NSString *dir = [[MockingFileHelper modelRootDirectory] stringByAppendingPathComponent:@"FrameWAB"];
    NSString *modelPath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wab", modelName]];
    NSString *modelInfoPath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", modelName]];
    if (async) {
        [[WTUnitySDK sharedSDK] useModelAsyncWithPath:modelPath InfoPath:modelInfoPath];
    } else {
        [[WTUnitySDK sharedSDK] useModelWithPath:modelPath InfoPath:modelInfoPath];
    }
}

- (void)switchView
{
    self.modelView.hidden = !self.modelView.hidden;
    self.shootingView.hidden = !self.shootingView.hidden;
}

- (void)switchButtonClicked:(id)sender
{
    [self switchView];
}

- (void)backButtonClicked:(id)sender
{
    [[WTUnitySDK sharedSDK] showNativeWindow];
}

- (void)removeObjectButtonClicked:(id)sender
{
    NSLog(@"Remove Object: %@", selectedObjectID);
    [[WTUnitySDK sharedSDK] removeModelObject:selectedObjectID];
//    [[WTUnitySDK sharedSDK] removeModelObject:@"nil"];
    [self showRemoveButton:NO];
}

- (void)takePhotoClicked:(id)sender
{
    NSLog(@"takePhotoClicked");
    [[WTUnitySDK sharedSDK] takePhoto:@"HD"];
}

- (void)startVideoClicked:(id)sender
{
    NSLog(@"startVideoClicked");
    [[WTUnitySDK sharedSDK] startRecordingVideo:@"HD"];
    self.startVideoButton.enabled = NO;
    self.stopVideoButton.enabled = YES;
}

- (void)stopVideoClicked:(id)sender
{
    NSLog(@"stopVideoClicked");
    [[WTUnitySDK sharedSDK] stopRecordingVideo];
    self.startVideoButton.enabled = YES;
    self.stopVideoButton.enabled = NO;
}

- (UIButton *)createButtonWithTitle:(NSString *)title Color:(UIColor *)color Action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 120, 44);
    button.backgroundColor = color;
    [button addTarget:self action:action forControlEvents:UIControlEventPrimaryActionTriggered];
    return button;
}


- (void)unityDidFinishPhotoing:(NSString *)pID withPath:(NSString *)path
{
    NSLog(@"unityDidFinishPhotoing: %@, %@", pID, path);
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    NSLog(@"Exist: %d", isExist);
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    NSLog(@"Image: %d/%d", (int)image.size.width, (int)image.size.height);
}

- (void)unityDidStartRecording:(NSString *)vID
{
    NSLog(@"unityDidStartRecording: %@", vID);
}


- (void)unityDidFinishRecording:(NSString *)vID withPath:(NSString *)path
{
    NSLog(@"unityDidFinishRecording: %@, %@", vID, path);
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    NSLog(@"Exist: %d", isExist);
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:YES];
    unsigned long long length = [fileAttributes fileSize];
    float fileSize = length/1024.0/1024.0;
    NSLog(@"VideSize: %.2f MB", fileSize);

}

#pragma Model Handling Callback
- (void)unityDidFinishLoadingModel:(int)modelType withPath:(NSString *)path infoPath:(NSString *)infoPath
{
    NSLog(@"Did Load Model: %@", path);
    currentModelInfo = [WTModelInfo modelInfoFromFile:infoPath];
}

- (void)unityDidFailedLoadingModel:(int)modelType withPath:(NSString *)path infoPath:(NSString *)infoPath description:(NSString *)description
{
    NSLog(@"Failed Load Model: %@", description);
}

- (void)unityDidPlaceModel:(int)modelType withModelID:(NSString *)mID
{
    NSString *type = (modelType == WTModel_MantisVisionHD) ? @"Mantis": @"3D";
    NSLog(@"Did Place %@ Model: %@", type, mID);
}

- (void)unityDidSelectModel:(int)modelType withModelID:(NSString *)mID
{
    NSString *type = (modelType == WTModel_MantisVisionHD) ? @"Mantis": @"3D";
    NSLog(@"Did Select %@ Model: %@", type, mID);
    selectedObjectID = mID;
    [self showRemoveButton:YES];
}

- (void)unityDidUnselectModel:(int)modelType withModelID:(NSString *)mID
{
    NSString *type = (modelType == WTModel_MantisVisionHD) ? @"Mantis": @"3D";
    NSLog(@"Did unselect %@ Model: %@", type, mID);
    selectedObjectID = nil;
    [self showRemoveButton:NO];
}

- (void)unityDidRemoveModel:(int)modelType withModelID:(NSString *)mID
{
    NSString *type = (modelType == WTModel_MantisVisionHD) ? @"Mantis": @"3D";
    NSLog(@"Did remove %@ Model: %@", type, mID);
}

- (void)unityDidFailedRemovingModel:(NSString *)mID description:(NSString *)description
{
    NSLog(@"Failed Load Model: %@", description);
}

@end
