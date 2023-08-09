# Verilog Sobel Edge Detection Filter

This Verilog project implements a Sobel filter for edge detection using FPGA hardware.
The project consists of several components working together to perform real-time edge detection on 640x480 image frames.

## Components:

### Line Buffers (4x)

The line buffers store 4 lines of the input image frame. These buffers are used to create a sliding window effect for convolution with the Sobel kernels.

### Convolution Block

The convolution block applies the Sobel kernels to the 9-pixel window of the input image to compute the gradient magnitude. This block determines whether the center pixel of the window is part of an edge.

### Image Control Block

The image control block manages the data flow to the line buffers, ensuring that new image data is streamed in and processed efficiently.

### Output FIFO

The output FIFO (First-In-First-Out) buffer holds the results of the convolution process. It ensures that the edge detection output is synchronized and ready for further processing or display.

### Image Control Top

The Image Control Top module encapsulates the entire system, coordinating the interactions between the line buffers, convolution block, image control block, and output FIFO. It acts as the main interface for the complete edge detection process.

