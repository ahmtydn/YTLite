#import <Foundation/Foundation.h>

#import "../YouTubeHeader/MLAVPlayer.h"
#import "../YouTubeHeader/MLDefaultPlayerViewFactory.h"
#import "../YouTubeHeader/MLPlayerPool.h"
#import "../YouTubeHeader/MLPlayerPoolImpl.h"
#import "../YouTubeHeader/MLVideoDecoderFactory.h"
#import "../YouTubeHeader/YTHotConfig.h"
#import "../YouTubeHeader/YTIHamplayerConfig.h"

@class MLVideo, MLInnerTubePlayerConfig, MLPlayerStickySettings, MLAVPlayerLayerView, YTIHamplayerHotConfig;

static MLAVPlayer *makeAVPlayer(id pool, MLVideo *video, MLInnerTubePlayerConfig *cfg, MLPlayerStickySettings *sticky) {
    BOOL ext = [(MLAVPlayer *)[pool valueForKey:@"_activePlayer"] externalPlaybackActive];
    MLAVPlayer *p = [[%c(MLAVPlayer) alloc] initWithVideo:video playerConfig:cfg stickySettings:sticky externalPlaybackActive:ext];
    if (sticky) p.rate = sticky.rate;
    return p;
}

static void forceRenderType(YTIHamplayerConfig *cfg) { if (cfg) cfg.renderViewType = 2; }
static void forceRenderTypeHot(id cfg) { if (cfg) ((YTIHamplayerConfig *)cfg).renderViewType = 2; }
static void forceRenderTypeFromHot(YTHotConfig *hot) { forceRenderTypeHot([hot hamplayerHotConfig]); }

%hook MLPlayerPoolImpl
- (id)acquirePlayerForVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c stickySettings:(MLPlayerStickySettings *)s { return makeAVPlayer(self,v,c,s); }
- (id)acquirePlayerForVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c stickySettings:(MLPlayerStickySettings *)s latencyLogger:(id)l { return makeAVPlayer(self,v,c,s); }
- (id)acquirePlayerForVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c stickySettings:(MLPlayerStickySettings *)s latencyLogger:(id)l reloadContext:(id)r { return makeAVPlayer(self,v,c,s); }
- (id)acquirePlayerForVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c stickySettings:(MLPlayerStickySettings *)s latencyLogger:(id)l reloadContext:(id)r mediaPlayerResources:(id)m { return makeAVPlayer(self,v,c,s); }
- (id)acquirePlayerForVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c stickySettings:(MLPlayerStickySettings *)s latencyLogger:(id)l reloadContext:(id)r mediaPlayerResources:(id)m recompositeProvider:(id)rp { return makeAVPlayer(self,v,c,s); }
- (MLAVPlayerLayerView *)playerViewForVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c { return [[self valueForKey:@"_playerViewFactory"] AVPlayerViewForVideo:v playerConfig:c]; }
- (MLAVPlayerLayerView *)playerViewForVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c mediaPlayerResources:(id)m { return [[self valueForKey:@"_playerViewFactory"] AVPlayerViewForVideo:v playerConfig:c]; }
- (BOOL)canQueuePlayerPlayVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c { return NO; }
- (BOOL)canQueuePlayerPlayVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c reloadContext:(id)r { return NO; }
- (BOOL)canQueuePlayerPlayVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c reloadContext:(id)r error:(id *)e { return NO; }
- (BOOL)canUsePlayerView:(id)pv forPlayerConfig:(MLInnerTubePlayerConfig *)c { forceRenderType([c hamplayerConfig]); return %orig; }
%end

%hook MLPlayerPool
- (id)acquirePlayerForVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c stickySettings:(MLPlayerStickySettings *)s { return makeAVPlayer(self,v,c,s); }
- (id)acquirePlayerForVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c stickySettings:(MLPlayerStickySettings *)s latencyLogger:(id)l { return makeAVPlayer(self,v,c,s); }
- (MLAVPlayerLayerView *)playerViewForVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c { return [[self valueForKey:@"_playerViewFactory"] AVPlayerViewForVideo:v playerConfig:c]; }
- (BOOL)canQueuePlayerPlayVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c { return NO; }
- (BOOL)canUsePlayerView:(id)pv forVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c { forceRenderType([c hamplayerConfig]); return %orig; }
%end

%hook MLDefaultPlayerViewFactory
- (id)hamPlayerViewForVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c { forceRenderTypeFromHot([self valueForKey:@"_hotConfig"]); forceRenderType([c hamplayerConfig]); return %orig; }
- (id)hamPlayerViewForPlayerConfig:(MLInnerTubePlayerConfig *)c { forceRenderTypeFromHot([self valueForKey:@"_hotConfig"]); forceRenderType([c hamplayerConfig]); return %orig; }
- (BOOL)canUsePlayerView:(id)pv forVideo:(MLVideo *)v playerConfig:(MLInnerTubePlayerConfig *)c { forceRenderType([c hamplayerConfig]); return %orig; }
- (BOOL)canUsePlayerView:(id)pv forPlayerConfig:(MLInnerTubePlayerConfig *)c { forceRenderType([c hamplayerConfig]); return %orig; }
%end

%hook MLVideoDecoderFactory
- (void)prepareDecoderForFormatDescription:(id)fd delegateQueue:(id)q { forceRenderTypeHot([self valueForKey:@"_hotConfig"]); %orig; }
- (void)prepareDecoderForFormatDescription:(id)fd setPixelBufferTypeOnlyIfEmpty:(BOOL)b delegateQueue:(id)q { forceRenderTypeHot([self valueForKey:@"_hotConfig"]); %orig; }
%end

%ctor { %init; }
