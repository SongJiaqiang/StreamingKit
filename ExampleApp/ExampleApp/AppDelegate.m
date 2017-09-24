//
//  AppDelegate.m
//  ExampleApp
//
//  Created by Thong Nguyen on 20/01/2014.
//  Copyright (c) 2014 Thong Nguyen. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioKit/AudioKit.h>
#import "AudioPlayerView.h"
#import "SampleQueueId.h"


@interface AppDelegate()
{
    STKAudioPlayer* audioPlayer;
}
@end

@implementation AppDelegate

-(BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    NSError* error;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
	[[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    Float32 bufferLength = 0.1;
    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(bufferLength), &bufferLength);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UIViewController alloc] init];
    
	self.window.backgroundColor = [UIColor whiteColor];
    
	audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
	audioPlayer.meteringEnabled = YES;
	audioPlayer.volume = 1;
    
	AudioPlayerView* audioPlayerView = [[AudioPlayerView alloc] initWithFrame:self.window.bounds andAudioPlayer:audioPlayer];
    
	audioPlayerView.delegate = self;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
	
    [self.window makeKeyAndVisible];
    
    [self.window.rootViewController.view addSubview:audioPlayerView];
	
    return YES;
}

-(BOOL) canBecomeFirstResponder
{
    return YES;
}

-(void) audioPlayerViewPlayFromHTTPSelected:(AudioPlayerView*)audioPlayerView
{
    NSURL* url = [NSURL URLWithString:@"http://www.abstractpath.com/files/audiosamples/sample.mp3"];
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
	[audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

-(void) audioPlayerViewPlayFromIcecastSelected:(AudioPlayerView *)audioPlayerView
{
    NSURL* url = [NSURL URLWithString:@"http://shoutmedia.abc.net.au:10326"];
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
    [audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

-(void) audioPlayerViewQueueShortFileSelected:(AudioPlayerView*)audioPlayerView
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"airplane" ofType:@"aac"];
	NSURL* url = [NSURL fileURLWithPath:path];
	
	STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
	[audioPlayer queueDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

-(void) audioPlayerViewPlayFromLocalFileSelected:(AudioPlayerView*)audioPlayerView
{
	NSString* path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"m4a"];
	NSURL* url = [NSURL fileURLWithPath:path];
	
	STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
	
	[audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

-(void) audioPlayerViewQueuePcmWaveFileSelected:(AudioPlayerView*)audioPlayerView
{
	NSURL* url = [NSURL URLWithString:@"http://www.abstractpath.com/files/audiosamples/perfectly.wav"];
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
	[audioPlayer queueDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

-(void) audioPlayerViewPlayFromiTunesLibrarySelected:(AudioPlayerView*)audioPlayerView
{
    NSArray *alliTunesTracks = [[MPMediaQuery songsQuery] items];
    if (alliTunesTracks.count < 1) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"iTunes library empty" message:@"load track and try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [av show];
        return;
    }
    MPMediaItem *randomItem = nil;
    while (!randomItem) {
        NSUInteger randomIndex = arc4random_uniform((uint32_t)alliTunesTracks.count - 1);
        randomItem = [alliTunesTracks objectAtIndex:randomIndex];
        if ([[randomItem valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]) {
            randomItem = nil;
            continue;
        }
    }
    NSURL *url = [randomItem valueForProperty:MPMediaItemPropertyAssetURL];
    STKDataSource *dataSource = [STKAudioPlayer dataSourceFromURL:url];
    [audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}




@end
