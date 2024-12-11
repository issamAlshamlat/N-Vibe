// This file is generated and will be overwritten automatically.

#import <Foundation/Foundation.h>

/**
 * PROFILE SHORT message options
 * slopeStep - if true, slopeStep type will be generated
 * curvature - if true, curvature type will be generated
 * roadCondition - if true, roadCondition type will be generated
 * variableSpeedSign - if true, variableSpeedSign type will be generated
 * headingChange - if true, headingChange type will be generated
 * historyAverageSpeed - if true, historyAverageSpeed type will be generated
 */
NS_SWIFT_NAME(AdasisConfigProfileshortTypeOptions)
__attribute__((visibility ("default")))
@interface MBNNAdasisConfigProfileshortTypeOptions : NSObject

- (nonnull instancetype)init;

- (nonnull instancetype)initWithSlopeStep:(BOOL)slopeStep
                                curvature:(BOOL)curvature
                            roadCondition:(BOOL)roadCondition
                        variableSpeedSign:(BOOL)variableSpeedSign
                            headingChange:(BOOL)headingChange
                      historyAverageSpeed:(BOOL)historyAverageSpeed;

@property (nonatomic, readonly, getter=isSlopeStep) BOOL slopeStep;
@property (nonatomic, readonly, getter=isCurvature) BOOL curvature;
@property (nonatomic, readonly, getter=isRoadCondition) BOOL roadCondition;
@property (nonatomic, readonly, getter=isVariableSpeedSign) BOOL variableSpeedSign;
@property (nonatomic, readonly, getter=isHeadingChange) BOOL headingChange;
@property (nonatomic, readonly, getter=isHistoryAverageSpeed) BOOL historyAverageSpeed;

- (BOOL)isEqualToAdasisConfigProfileshortTypeOptions:(nonnull MBNNAdasisConfigProfileshortTypeOptions *)other;

@end
