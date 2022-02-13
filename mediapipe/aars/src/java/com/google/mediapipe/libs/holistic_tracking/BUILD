# Copyright 2019 The MediaPipe Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("//mediapipe/java/com/google/mediapipe:mediapipe_aar.bzl", "mediapipe_aar")

package(default_visibility = ["//visibility:private"])

licenses(["notice"])

mediapipe_aar(
    name = "mediapipe_holistic_tracking",
    srcs = glob(["*.java"]),
    calculators = [
        "//mediapipe/graphs/holistic_tracking_core:holistic_tracking_gpu_deps",
    ],
    assets = [
        "//mediapipe/graphs/holistic_tracking_core:holistic_tracking_gpu.binarypb",
        "//mediapipe/modules/face_detection:face_detection_short_range.tflite",
        "//mediapipe/modules/face_landmark:face_landmark.tflite",
        "//mediapipe/modules/hand_landmark:hand_landmark_full.tflite",
        "//mediapipe/modules/hand_landmark:handedness.txt",
        "//mediapipe/modules/holistic_landmark:hand_recrop.tflite",
        "//mediapipe/modules/pose_detection:pose_detection.tflite",
        "//mediapipe/modules/pose_landmark:pose_landmark_full.tflite",
    ],
    assets_dir = "",
)
