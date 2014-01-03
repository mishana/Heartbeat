//
//  TKProgressCircleView.h
//  Created by Devin Ross on 1/1/11.
//

#import <UIKit/UIKit.h>

/** A progress circle view */
@interface TKProgressCircleView : UIView {
	BOOL _twirlMode;
	float _progress,_displayProgress;
}

/** Initialized a new progress circle view. */
- (id) init;

/** The progress displayed. Value between 0.0 and 1.0 */
@property (nonatomic,assign) float progress; // between 0.0 & 1.0

/** Have the progress circle twirl instead of displaying the current progress. */
@property (assign,nonatomic,getter=isTwirling) BOOL twirlMode;

/** Set the progress with the circle animating to the progress.
 @param progress The current progress.
 @param animated Flag to animate to the current progress.
 */
- (void) setProgress:(float)progress animated:(BOOL)animated;


@end