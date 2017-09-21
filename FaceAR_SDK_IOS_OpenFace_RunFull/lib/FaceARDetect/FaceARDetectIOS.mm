//
//  FaceARDetectIOS.m
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//  Created by Keegan Ren on 7/5/16.
//  Copyright © 2016 Keegan Ren. All rights reserved.
//

#import "FaceARDetectIOS.h"
#import "UIKit/UIKit.h"

LandmarkDetector::FaceModelParameters det_parameters;
// The modules that are being used for tracking
LandmarkDetector::CLNF clnf_model;

@implementation FaceARDetectIOS

//bool inits_FaceAR();
-(id) init
{
    self = [super init];
    NSString *location = [[NSBundle mainBundle] resourcePath];
    det_parameters.init();
    det_parameters.model_location = [location UTF8String] + std::string("/model/main_clnf_general.txt");
    det_parameters.face_detector_location = [location UTF8String] + std::string("/classifiers/haarcascade_frontalface_alt.xml");
    
    std::cout << "model_location = " << det_parameters.model_location << std::endl;
    std::cout << "face_detector_location = " << det_parameters.face_detector_location << std::endl;
    
    clnf_model.model_location_clnf = [location UTF8String] + std::string("/model/main_clnf_general.txt");
    clnf_model.face_detector_location_clnf = [location UTF8String] + std::string("/classifiers/haarcascade_frontalface_alt.xml");
    clnf_model.inits();

    return self;
}


// Visualising the results
void visualise_tracking(cv::Mat& captured_image, cv::Mat_<float>& depth_image, const LandmarkDetector::CLNF& face_model, const LandmarkDetector::FaceModelParameters& det_parameters, int frame_count, double fx, double fy, double cx, double cy,cv::Mat_<double> &shape2D)
{
    
    // Drawing the facial landmarks on the face and the bounding box around it if tracking is successful and initialised
    double detection_certainty = face_model.detection_certainty;
 
  
    double visualisation_boundary = 0.2;
    
    // Only draw if the reliability is reasonable, the value is slightly ad-hoc
    if (detection_certainty < visualisation_boundary)
    {
      // LandmarkDetector::Draw(captured_image, face_model);
        
        //**new******
               
         shape2D =face_model.detected_landmarks;
        
    
    }
 
}


//bool run_FaceAR(cv::Mat &captured_image, int frame_count, float fx, float fy, float cx, float cy);
-(BOOL) run_FaceAR:(cv::Mat)captured_image frame__:(int)frame_count fx__:(double)fx fy__:(double)fy cx__:(double)cx cy__:(double)cy returnInfo:(cv::Mat_<double>&) res resVisiblilities:(cv::Mat_<int>&) visibilities;
{
    // Reading the images
    cv::Mat_<float> depth_image;
    cv::Mat_<uchar> grayscale_image;
    
    if(captured_image.channels() == 3)
    {
        cv::cvtColor(captured_image, grayscale_image, CV_BGR2GRAY);
    }
    else
    {
        grayscale_image = captured_image.clone();
    }
    
    // The actual facial landmark detection / tracking
    bool detection_success = LandmarkDetector::DetectLandmarksInVideo(grayscale_image, depth_image, clnf_model, det_parameters);
    // bool detection_success = LandmarkDetector::DetectLandmarksInImage(grayscale_image, depth_image, clnf_model, det_parameters);
    
    // Visualising the results
    // Drawing the facial landmarks on the face and the bounding box around it if tracking is successful and initialised
    double detection_certainty = clnf_model.detection_certainty;
    int idx = clnf_model.patch_experts.GetViewIdx(clnf_model.params_global, 0);
    visibilities=clnf_model.patch_experts.visibilities[0][idx];
    if (detection_success==true && detection_certainty<-0.7){
    visualise_tracking(captured_image, depth_image, clnf_model, det_parameters, frame_count, fx, fy, cx, cy,res);
        return true;
    }else return false;

    
}

//bool reset_FaceAR();
-(BOOL) reset_FaceAR
{
    clnf_model.Reset();
    
    return true;
}

//bool clear_FaceAR();
-(BOOL) clear_FaceAR
{
    clnf_model.Reset();
    
    return true;
}


@end
