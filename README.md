# Depth-Estimation-Stereo-Cameras #
## Objective ##
Explore different methods for Depth Estimation using a pair of images obtained from stereo cameras.
Disparity maps and depths are inversely related when we have perfectly calibrated cameras with parallel optical axes. (Z = f T / d). Hence we calculate disparity map for a given set of images.

## Dataset ##
We are using Middlebury 2014 Stereo datasets - http://vision.middlebury.edu/stereo/data/scenes2014/


## Solution Approach ##
Disparity map intuitively represents corresponding pixels that are horizontally shifted between the left and right image if we have perfectly calibrated cameras. Perfectly calibrated cameras allow the search space to be reduced from 2D to 1D. In other cases also, we can use epipolar geometry to reduce the search space. For finding pixel correspondence between the two images, we use patch based matching algorithms. We need to associate a cost between two patches. The different costs that we tried out are listed below.

### SAD ###
The SAD algorithm considers the absolute difference between the intensity of each pixel in the reference block and that of the corresponding pixel in the target block. <br />
<a href="https://www.codecogs.com/eqnedit.php?latex=SAD(x,y,d)&space;=&space;\sum_{(x,y)\epsilon&space;w}&space;\left&space;|&space;I_{l}(x,y)&space;-&space;I_{r}(x-d,y)\right&space;|" target="_blank"><img src="https://latex.codecogs.com/gif.latex?SAD(x,y,d)&space;=&space;\sum_{(x,y)\epsilon&space;w}&space;\left&space;|&space;I_{l}(x,y)&space;-&space;I_{r}(x-d,y)\right&space;|" title="SAD(x,y,d) = \sum_{(x,y)\epsilon w} \left | I_{l}(x,y) - I_{r}(x-d,y)\right |" /></a>

### SSD ###
In SSD algorithm, the summation is performed over the squared differences in pixel intensity values between two corresponding pixels in the aggregated support window. <br />
<a href="https://www.codecogs.com/eqnedit.php?latex=SSD(x,y,d)&space;=&space;\sum_{(x,y)\epsilon&space;w}&space;\left&space;|&space;I_{l}(x,y)&space;-&space;I_{r}(x-d,y)\right&space;|^{2}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?SSD(x,y,d)&space;=&space;\sum_{(x,y)\epsilon&space;w}&space;\left&space;|&space;I_{l}(x,y)&space;-&space;I_{r}(x-d,y)\right&space;|^{2}" title="SSD(x,y,d) = \sum_{(x,y)\epsilon w} \left | I_{l}(x,y) - I_{r}(x-d,y)\right |^{2}" /></a>


### Rank ###
The matching cost for RT is calculated based on the absolute difference between two ranks. <br />
<a href="https://www.codecogs.com/eqnedit.php?latex=RT(x,y,d)&space;=&space;\sum_{(x,y)\epsilon&space;w}&space;\left&space;|&space;Rank_{ref}(x,y)&space;-&space;Rank_{tar}(x-d,y)\right&space;|" target="_blank"><img src="https://latex.codecogs.com/gif.latex?RT(x,y,d)&space;=&space;\sum_{(x,y)\epsilon&space;w}&space;\left&space;|&space;Rank_{ref}(x,y)&space;-&space;Rank_{tar}(x-d,y)\right&space;|" title="RT(x,y,d) = \sum_{(x,y)\epsilon w} \left | Rank_{ref}(x,y) - Rank_{tar}(x-d,y)\right |" /></a>

<a href="https://www.codecogs.com/eqnedit.php?latex=Rank(x,y)&space;=&space;\sum_{(i,j)(x,y)}&space;L(i,j)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?Rank(x,y)&space;=&space;\sum_{(i,j)(x,y)}&space;L(i,j)" title="Rank(x,y) = \sum_{(i,j)(x,y)} L(i,j)" /></a>

<a href="https://www.codecogs.com/eqnedit.php?latex=L(i,j)&space;=&space;\left\{\begin{matrix}&space;0:&space;&&space;I(i,j)<I(x,y))\\&space;1:&space;&&space;otherwise&space;\end{matrix}\right." target="_blank"><img src="https://latex.codecogs.com/gif.latex?L(i,j)&space;=&space;\left\{\begin{matrix}&space;0:&space;&&space;I(i,j)<I(x,y))\\&space;1:&space;&&space;otherwise&space;\end{matrix}\right." title="L(i,j) = \left\{\begin{matrix} 0: & I(i,j)<I(x,y))\\ 1: & otherwise \end{matrix}\right." /></a>


### Adaptive SSD ###
We observed that the above methods had difficulty in matching pixels when they lied in a large smooth (no texture) area. This was because there were a lot of identical patches of intensity in the large area (like a wall etc.) To resolve this, we dynamically increase window size of the patch till some texture threshold was reached (we accounted for texture by ensuring that the difference between the minimum and maximum intensity value in the patch was greater than a threshold)

### Other approaches tried ###

#### Multiple Window ####
To capture local as well as global context, we tried an approach where we take multiple windows at a pixel and compute matching costs with each of them and took a weighted sum.

#### Anisotropic diffusion ####
We tried anisotropic diffusion as post-processing step on disparity map, but it didn’t work well. This was supposed to remove the discontinuity in the disparity image.

## Requirements ##
Other than Matlab, there are no special requirements.
## Running the code ##
The codes are named as their corresponding matching cost metric. Run the corresponding file by changing the input path of left and right images at the beginning of code.
## Results ##
Piano Left Image            |  SSD | 
:-------------------------:|:-------------------------: |
<img src="middlebury/Piano-perfect/im0.png?raw=true" width="560" height="225" />| ![Alt text](middlebury/Piano-perfect/ssd.jpg?raw=true) |

SAD | Rank |
:-------------------------: |  :-------------------------: |
![Alt text](middlebury/Piano-perfect/sad.jpg?raw=true) | ![Alt text](middlebury/Piano-perfect/rank.jpg?raw=true) |

Here, we list the performance of different matching costs over a few images from middlebury. The performance metric is percentage of good pixel, where a pixel is defined as good if it’s disparity is predicted correctly upto some threshold. These results are listed for threshold value of 20.

| Middlebury Image | SAD   | SSD | Adaptive SSD   | Rank | 
| :------------- | :----------: | :-----------: | :----------: | ----------: | 
|  Adirondack | 52.62   | 52    | 70.65 | 73.41 | 
|  Piano  | 70.58 | 70.23 | 68.3 | 76.16 | 
| Playroom | 58.65 | 53.03 | 65.08 | 65.51 |
| Vintage | 60.04 | 60.35 | 61.86 | 47.60 |


## References ##
http://www.cs.tut.fi/~suominen/SGN-1656-stereo/stereo_instructions.pdf
https://www.hindawi.com/journals/js/2016/8742920/?fbclid=IwAR2F3Dq2b1vFgLKX7NwTtUHsR6v_fdAH-USUcg5EuHZQ_I1t0s633LtcFTc
http://www.cs.toronto.edu/~fidler/slides/2015/CSC420/lecture12_hres.pdf
