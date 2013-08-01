//
//  PlaylistViewController.h
//  Vosbox
//
//  Created by Lorenzo Primiterra on 15/04/2012.
//  Copyright (c) 2012 Lorenzo Primiterra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+MD5.h"
@protocol PlaylistViewControllerDelegate <NSObject>
-(void) PlaylistViewControllerDismissed:(NSMutableArray *)newPlaylist argument2:(NSMutableArray*)newplaylistsList;
@end

@interface PlaylistViewController : UIViewController {
    NSMutableArray *playlistsList;
    NSMutableArray *playlist;
    NSString *currentUrl;
    id myDelegate;
}


@property (nonatomic, retain) NSMutableArray *playlistsList;
@property (nonatomic, retain) NSMutableArray *playlist;
@property (nonatomic, retain) NSString *currentUrl;
@property (nonatomic, retain) id<PlaylistViewControllerDelegate> myDelegate;

- (IBAction)cancel:(id)sender;
@end
