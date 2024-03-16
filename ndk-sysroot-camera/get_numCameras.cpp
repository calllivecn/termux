//#include <camera2.h>

#include <stdio.h>
#include <stdlib.h>

#include <NdkCameraCaptureSession.h>
#include <NdkCameraDevice.h>
#include <NdkCameraError.h>
#include <NdkCameraManager.h>
#include <NdkCameraMetadata.h>
#include <NdkCameraMetadataTags.h>
#include <NdkCameraWindowType.h>
#include <NdkCaptureRequest.h>


int main(){
	int cameras = ACameraIdList::numCameras;
	printf("有多少摄像头: %d\n", cameras);
	return 0;
}

