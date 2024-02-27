#!/usr/bin/env python3
# coding=utf-8
# date 2024-02-02 02:51:15
# author calllivecn <c-all@qq.com>

import android

# 获取摄像头对象
camera = android.hardware.Camera.open()

# 设置摄像头参数
camera.setPreviewSize(640, 480)
camera.setPreviewFpsRange(30, 30)

# 开始预览
camera.startPreview()

# 创建 MediaRecorder 对象
recorder = android.media.MediaRecorder()

# 设置 MediaRecorder 对象
recorder.setAudioSource(android.media.MediaRecorder.AudioSource.MIC)
recorder.setVideoSource(android.media.MediaRecorder.VideoSource.CAMERA)
recorder.setOutputFormat(android.media.MediaRecorder.OutputFormat.MPEG_4)
recorder.setVideoEncoder(android.media.MediaRecorder.VideoEncoder.H264)
recorder.setAudioEncoder(android.media.MediaRecorder.AudioEncoder.AAC)
recorder.setOutputFile("/sdcard/video.mp4")

# 开始录制
recorder.start()

# 录制一段时间后停止录制
time.sleep(10)
recorder.stop()

# 释放摄像头和 MediaRecorder 对象
camera.release()
recorder.release()



