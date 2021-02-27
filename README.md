# SwiftHeadSegmenter
An IoS app written in Swift that, given a picture, segments out a face and saves it as a png. The CoreML model used is a custom one, trained from scratch in Pytorch.

## Dataset

I was not able to find an exact segmentation dataset of what I wanted. The closest was [the face/head segmentation dataset](https://store.mut1ny.com/product/face-head-segmentation-dataset-community-edition?v=cd32106bcb6d), but it included necks. I decided to use the dataset for an initial phase of training, then a corrected version of it for transfer learning. Since the masks all had 3 channels and I needed grayscales, all collapsed the 3 channels into 1 using numpy.

<img src="https://github.com/ZedZeal/SwiftFaceSegmenter/blob/main/pics/dataset.png" width="400" height="200">

## Model 

Initially I wanted to use a pretrained model, such as DeepLabv3 or MObileNetv3. However, the problem with DeepLab was that it was too big (I wanted a model something around size 10M) and the architecture head of MobileNet is intended for classification: I tried to substitute it with a segmentation one (such as [lraspp](https://ieeexplore.ieee.org/document/9008835)), but I was not able to convert the result in a CoreML model. In the end I opted for a simple encoder-decoder model; the architecture is illustrated below.

<img src="https://github.com/ZedZeal/SwiftFaceSegmenter/blob/main/pics/arch.png">

## Training

After an initial phase of training (100 epochs, lr of 1e-4 with CosineAnnealingLR), it was time to create a subsection of the dataset that did not include the necks. By identifying the jaw landmarks points using OpenCV and unify them in a single segment using [Bresenham's algorithm](https://pypi.org/project/bresenham/), I was able to draw a line on the chins, making the neck elimination from the mask easier. I created a subsample of 1000 images and fine-tuned the model.


<img src="https://github.com/ZedZeal/SwiftFaceSegmenter/blob/main/pics/female03_headrende0039.png" width="200" height="200">

## CoreML Conversion

Using torch.jit and coremltools I converted the pytorch model into a CoreML one. the image inoput size was fixed at (256,256), same as training, and the output would be of MLMultiArray type. Since the model outputs a probability for each pixel to be the pixel of a head, I used numpy.where with a threshold value for receiving a binary array.

## The App
The app's usage is straightforward. It allows the user t select any photo in his gallery, and than shows the segmentation result from the model, whle saving it as a .png in the Documents folder.


Before selection            |  After selection
:-------------------------:|:-------------------------:
<img src="https://github.com/ZedZeal/SwiftFaceSegmenter/blob/main/pics/sc1.png" width="200" height="400">  |  <img src="https://github.com/ZedZeal/SwiftFaceSegmenter/blob/main/pics/sc2.png" width="200" height="400">







