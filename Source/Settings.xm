#import "../Tweaks/YouTubeHeader/YTSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSearchableSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItem.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../Tweaks/YouTubeHeader/YTUIUtils.h"
#import "../Tweaks/YouTubeHeader/YTSettingsPickerViewController.h"
#import "../Header.h"

static BOOL IsEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
static int GetSelection(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}
static int colorContrastMode() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"lcmColor"];
}
static int appVersionSpoofer() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"versionSpoofer"];
}
static const NSInteger CercubePlusSection = 500;

@interface YTSettingsSectionItemManager (CercubePlus)
- (void)updateCercubePlusSectionWithEntry:(id)entry;
@end

extern NSBundle *CercubePlusBundle();

// Settings
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(CercubePlusSection) atIndex:insertIndex + 1];
    return mutableOrder;
}
%end

%hook YTSettingsSectionController

- (void)setSelectedItem:(NSUInteger)selectedItem {
    if (selectedItem != NSNotFound) %orig;
}

%end

%hook YTSettingsSectionItemManager
%new(v@:@)
- (void)updateCercubePlusSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = CercubePlusBundle();
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    YTSettingsSectionItem *main = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"VERSION"), @(OS_STRINGIFY(TWEAK_VERSION))]
    titleDescription:LOC(@"VERSION_CHECK")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/arichorn/CercubePlusExtra/releases/latest"]];
    }];
    [sectionItems addObject:main];

# pragma mark - VideoPlayer
    YTSettingsSectionItem *videoPlayerGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VIDEO_PLAYER_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"AUTO_FULLSCREEN")
                titleDescription:LOC(@"AUTO_FULLSCREEN_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"autoFull_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"autoFull_enabled"];
                    return YES;
                }
                settingItemId:0],

           [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"TAP_TO_SKIP")
               titleDescription:LOC(@"TAP_TO_SKIP_DESC")
               accessibilityIdentifier:nil
               switchOn:IsEnabled(@"tapToSkip_enabled")
               switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                   [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"tapToSkip_enabled"];
                   return YES;
               }
               settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"SNAP_TO_CHAPTER")
                titleDescription:LOC(@"SNAP_TO_CHAPTER_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"snapToChapter_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"snapToChapter_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"PINCH_TO_ZOOM")
                titleDescription:LOC(@"PINCH_TO_ZOOM_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"pinchToZoom_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"pinchToZoom_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"YT_MINIPLAYER")
                titleDescription:LOC(@"YT_MINIPLAYER_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"ytMiniPlayer_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytMiniPlayer_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"STOCK_VOLUME_HUD")
                titleDescription:LOC(@"STOCK_VOLUME_HUD_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"stockVolumeHUD_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"stockVolumeHUD_enabled"];
                    return YES;
                }
                settingItemId:0]
        ];
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VIDEO_PLAYER_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:videoPlayerGroup];

# pragma mark - Video Controls Overlay Options
    YTSettingsSectionItem *videoControlOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLE_SHARE_BUTTON")
                titleDescription:LOC(@"ENABLE_SHARE_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"enableShareButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"enableShareButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON")
                titleDescription:LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"enableSaveToButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"enableSaveToButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_AUTOPLAY_SWITCH")
                titleDescription:LOC(@"HIDE_AUTOPLAY_SWITCH_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideAutoplaySwitch_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideAutoplaySwitch_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SUBTITLES_BUTTON")
                titleDescription:LOC(@"HIDE_SUBTITLES_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideCC_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCC_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_HUD_MESSAGES")
                titleDescription:LOC(@"HIDE_HUD_MESSAGES_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideHUD_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideHUD_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_PAID_PROMOTION_CARDS")
                titleDescription:LOC(@"HIDE_PAID_PROMOTION_CARDS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hidePaidPromotionCard_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hidePaidPromotionCard_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CHANNEL_WATERMARK")
                titleDescription:LOC(@"HIDE_CHANNEL_WATERMARK_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideChannelWatermark_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideChannelWatermark_enabled"];
                    return YES;
                }
                settingItemId:0],
                
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS")
                titleDescription:LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideVideoPlayerShadowOverlayButtons_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideVideoPlayerShadowOverlayButtons_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_PREVIOUS_AND_NEXT_BUTTON")
                titleDescription:LOC(@"HIDE_PREVIOUS_AND_NEXT_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hidePreviousAndNextButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hidePreviousAndNextButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"REPLACE_PREVIOUS_NEXT_BUTTON")
                titleDescription:LOC(@"REPLACE_PREVIOUS_NEXT_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"replacePreviousAndNextButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"replacePreviousAndNextButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"RED_PROGRESS_BAR")
                titleDescription:LOC(@"RED_PROGRESS_BAR_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"redProgressBar_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"redProgressBar_enabled"];
                    return YES;
                }
                settingItemId:0],
				
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"DISABLE_VIDEO_PLAYER_ZOOM")
                titleDescription:LOC(@"DISABLE_VIDEO_PLAYER_ZOOM")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableVideoPlayerZoom_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableVideoPlayerZoom_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_HOVER_CARD")
                titleDescription:LOC(@"HIDE_HOVER_CARD_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideHoverCards_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideHoverCards_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_RIGHT_PANEL")
                titleDescription:LOC(@"HIDE_RIGHT_PANEL_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideRightPanel_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideRightPanel_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_HEATWAVES")
                titleDescription:LOC(@"HIDE_HEATWAVES_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideHeatwaves_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideHeatwaves_enabled"];
                    return YES;
                }
                settingItemId:0],
                
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_DARK_OVERLAY_BACKGROUND")
                titleDescription:LOC(@"HIDE_DARK_OVERLAY_BACKGROUND_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideOverlayDarkBackground_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideOverlayDarkBackground_enabled"];
                    return YES;
                }
                settingItemId:0]
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:videoControlOverlayGroup];

# pragma mark - Shorts Controls Overlay Options
    YTSettingsSectionItem *shortsControlOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"SHORTS_CONTROLS_OVERLAY_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_VIDEOS")
                titleDescription:LOC(@"HIDE_SHORTS_VIDEOS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShorts_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShorts_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_CHANNEL_AVATAR")
                titleDescription:LOC(@"HIDE_SHORTS_CHANNEL_AVATAR_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShortsChannelAvatar_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShortsChannelAvatar_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_LIKE_BUTTON")
                titleDescription:LOC(@"HIDE_SHORTS_LIKE_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShortsLikeButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShortsLikeButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_DISLIKE_BUTTON")
                titleDescription:LOC(@"HIDE_SHORTS_DISLIKE_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShortsDislikeButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShortsDislikeButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_COMMENT_BUTTON")
                titleDescription:LOC(@"HIDE_SHORTS_COMMENT_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShortsCommentButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShortsCommentButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_REMIX_BUTTON")
                titleDescription:LOC(@"HIDE_SHORTS_REMIX_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShortsRemixButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShortsRemixButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHORTS_SHARE_BUTTON")
                titleDescription:LOC(@"HIDE_SHORTS_SHARE_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideShortsShareButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideShortsShareButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SUPER_THANKS")
                titleDescription:LOC(@"HIDE_SUPER_THANKS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideBuySuperThanks_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideBuySuperThanks_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SUBSCRIPTIONS")
                titleDescription:LOC(@"HIDE_SUBSCRIPTIONS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideSubscriptions_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideSubscriptions_enabled"];
                    return YES;
                }
                settingItemId:0]
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"SHORTS_CONTROLS_OVERLAY_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:shortsControlOverlayGroup];

# pragma mark - LowContrastMode
    YTSettingsSectionItem *lowContrastModeSection = [YTSettingsSectionItemClass itemWithTitle:LOC(@"LCM_CHOOSE_COLOR")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (colorContrastMode()) {
                case 1:
                    return LOC(@"RED_UI");
                case 2:
                    return LOC(@"BLUE_UI");
                case 3:
                    return LOC(@"GREEN_UI");
                case 4:
                    return LOC(@"YELLOW_UI");
                case 5:
                    return LOC(@"ORANGE_UI");
                case 6:
                    return LOC(@"PURPLE_UI");
                case 7:
                    return LOC(@"VIOLET_UI");
                case 8:
                    return LOC(@"PINK_UI");
                case 0:
                default:
                    return LOC(@"DEFAULT_UI");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"DEFAULT_UI") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lcmColor"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"RED_UI") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"lcmColor"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"BLUE_UI") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"lcmColor"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"GREEN_UI") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"lcmColor"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"YELLOW_UI") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"lcmColor"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"ORANGE_UI") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"lcmColor"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"PURPLE_UI") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:6 forKey:@"lcmColor"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"VIOLET_UI") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:7 forKey:@"lcmColor"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"PINK_UI") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:8 forKey:@"lcmColor"];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"LCM_CHOOSE_COLOR") pickerSectionTitle:nil rows:rows selectedItemIndex:colorContrastMode() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

# pragma mark - VersionSpoofer
    YTSettingsSectionItem *versionSpooferSection = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VERSION_SPOOFER_TITLE")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (appVersionSpoofer()) {
                case 1:
                    return @"v18.20.3";
                case 2:
                    return @"v18.14.1";
                case 3:
                    return @"v18.08.1";
                case 4:
                    return @"v18.01.6";
                case 5:
                    return @"v17.49.6";
                case 6:
                    return @"v17.39.4";
                case 7:
                    return @"v17.38.10";
                case 8:
                    return @"v17.30.1";
                case 9:
                    return @"v17.11.2";
                case 10:
                    return @"v17.01.4";
                case 11:
                    return @"v16.46.5";
                case 12:
                    return @"v16.42.3";
                case 13:
                    return @"v16.30.2";
                case 14:
                    return @"v16.29.4";
                case 15:
                    return @"v16.20.5";
                case 16:
                    return @"v16.17.4";
                case 17:
                    return @"v16.16.4";
                case 18:
                    return @"v16.16.3";
                case 19:
                    return @"v16.15.4";
                case 20:
                    return @"v16.14.2";
                case 21:
                    return @"v16.13.1";
                case 22:
                    return @"v16.12.3";
                case 23:
                    return @"v16.11.3";
                case 24:
                    return @"v16.10.3";
                case 25:
                    return @"v16.09.3";
                case 26:
                    return @"v16.09.2";
                case 27:
                    return @"v16.08.2";
                case 28:
                    return @"v16.05.9";
                case 29:
                    return @"v16.05.8";
                case 30:
                    return @"v16.05.7";
                case 0:
                default:
                    return @"v18.22.9";
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.22.9" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.20.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.14.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.08.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.49.6" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.39.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:6 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.38.10" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:7 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;      
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.30.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:8 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.11.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:9 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.01.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.46.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:11 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.42.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:12 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.30.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:13 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.29.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:14 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.20.5" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:15 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.17.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:16 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.16.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:17 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.16.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:18 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.15.4" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:19 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.14.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:20 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.13.1" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:21 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.12.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:22 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
               }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.11.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:23 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.10.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:24 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.09.3" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:25 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.09.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:26 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.08.2" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:27 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.05.9" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:28 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.05.8" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:29 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v16.05.7" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:30 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VERSION_SPOOFER_TITLE") pickerSectionTitle:nil rows:rows selectedItemIndex:appVersionSpoofer() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

# pragma mark - Theme
    YTSettingsSectionItem *themeGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"THEME_OPTIONS")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (GetSelection(@"appTheme")) {
                case 1:
                    return LOC(@"OLED_DARK_THEME_2");
                case 2:
                    return LOC(@"OLD_DARK_THEME");
                case 0:
                default:
                    return LOC(@"DEFAULT_THEME");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"DEFAULT_THEME") titleDescription:LOC(@"DEFAULT_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"OLED_DARK_THEME") titleDescription:LOC(@"OLED_DARK_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"OLD_DARK_THEME") titleDescription:LOC(@"OLD_DARK_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"OLED_KEYBOARD")
                titleDescription:LOC(@"OLED_KEYBOARD_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"oledKeyBoard_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"oledKeyBoard_enabled"];
                    return YES;
                }
                settingItemId:0],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"LOW_CONTRAST_MODE")
                titleDescription:LOC(@"LOW_CONTRAST_MODE_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"lowContrastMode_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"lowContrastMode_enabled"];
                    return YES;
                }
                settingItemId:0], lowContrastModeSection];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"THEME_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:GetSelection(@"appTheme") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
    [sectionItems addObject:themeGroup];

# pragma mark - Miscellaneous
    YTSettingsSectionItem *miscellaneousGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"MISCELLANEOUS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLE_YT_STARTUP_ANIMATION")
                titleDescription:LOC(@"ENABLE_YT_STARTUP_ANIMATION_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"ytStartupAnimation_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytStartupAnimation_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_YOUTUBE_LOGO")
                titleDescription:LOC(@"HIDE_YOUTUBE_LOGO_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideYouTubeLogo_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideYouTubeLogo_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CHIP_BAR")
                titleDescription:LOC(@"HIDE_CHIP_BAR_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideChipBar_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideChipBar_enabled"];
                    return YES;
                }
                settingItemId:0],
                
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_MODERN_INTERFACE")
                titleDescription:LOC(@"HIDE_MODERN_INTERFACE_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"ytNoModernUI_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytNoModernUI_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"IPAD_LAYOUT")
                titleDescription:LOC(@"IPAD_LAYOUT_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"iPadLayout_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"iPadLayout_enabled"];
                    return YES;
                }
                settingItemId:0], 

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"IPHONE_LAYOUT")
                titleDescription:LOC(@"IPHONE_LAYOUT_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"iPhoneLayout_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"iPhoneLayout_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"CAST_CONFIRM")
                titleDescription:LOC(@"CAST_CONFIRM_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"castConfirm_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"castConfirm_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"DISABLE_HINTS")
                titleDescription:LOC(@"DISABLE_HINTS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableHints_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableHints_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"NEW_MINIPLAYER_STYLE")
                titleDescription:LOC(@"NEW_MINIPLAYER_STYLE_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"bigYTMiniPlayer_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"bigYTMiniPlayer_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CAST_BUTTON")
                titleDescription:LOC(@"HIDE_CAST_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideCastButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCastButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_NOTIFICATION_BUTTON")
                titleDescription:LOC(@"HIDE_NOTIFICATION_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideNotificationButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideNotificationButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SPONSORBLOCK_BUTTON")
                titleDescription:LOC(@"HIDE_SPONSORBLOCK_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideSponsorBlockButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideSponsorBlockButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CERCUBE_BUTTON")
                titleDescription:LOC(@"")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideCercubeButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCercubeButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CERCUBE_PIP_BUTTON")
                titleDescription:LOC(@"HIDE_CERCUBE_PIP_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideCercubePiP_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCercubePiP_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CERCUBE_DOWNLOAD_BUTTON")
                titleDescription:LOC(@"HIDE_CERCUBE_DOWNLOAD_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideCercubeDownload_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL disabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hideCercubeDownload_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"DISABLE_WIFI_RELATED_SETTINGS")
                titleDescription:LOC(@"DISABLE_WIFI_RELATED_SETTINGS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableWifiRelatedSettings_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableWifiRelatedSettings_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"YT_RE_EXPLORE")
                titleDescription:LOC(@"YT_RE_EXPLORE_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"reExplore_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"reExplore_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"YT_SPEED")
                titleDescription:LOC(@"YT_SPEED_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"ytSpeed_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytSpeed_enabled"];
                    return YES;
                }
                settingItemId:0],
                
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLE_FLEX")
                titleDescription:LOC(@"ENABLE_FLEX_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"flex_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"flex_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"APP_VERSION_SPOOFER")
                titleDescription:LOC(@"APP_VERSION_SPOOFER_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"enableVersionSpoofer_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"enableVersionSpoofer_enabled"];
                    return YES;
                }
                settingItemId:0], versionSpooferSection];
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"MISCELLANEOUS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:miscellaneousGroup];

    [settingsViewController setSectionItems:sectionItems forCategory:CercubePlusSection title:@"CercubePlus" titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == CercubePlusSection) {
        [self updateCercubePlusSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end
