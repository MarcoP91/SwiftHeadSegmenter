# SwiftFaceSegmenter
An IoS app written in Swift that, given a picture, segments out a face and saves it as a png. The CoreML model used is a custom one, trained from scratch in Pytorch.

## Dataset

I was not able to find an exact segmentation dataset of what I wanted. The closest was [the face/head segmentation dataset](https://store.mut1ny.com/product/face-head-segmentation-dataset-community-edition?v=cd32106bcb6d), but it included necks. I decided to use the dataset for an initial phase of training, then a corrected version of it for transfer learning. Since the masks all had 3 channels and I needed grayscales, all collapsed the 3 channels into 1 using numpy.

![Dataset](https://github.com/ZedZeal/SwiftFaceSegmenter/blob/main/pics/dataset.png)




