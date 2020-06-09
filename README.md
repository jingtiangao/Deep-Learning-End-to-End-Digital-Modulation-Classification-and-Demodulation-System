# Deep Learning End to End Digital Modulation Classification and Demodulation System
- Conducted data processing using MATLAB signal toolbox, which calculate cummulants and gen-
erate labeled QPSK, 8PSK, 16QAM train and test dataset (including different signal-to-noise
ratio)
- Built modulation recognition model using Multilayer Perceptron, for data with SNR above 15db,
the accuracy rate is close to 100%.
- Built demodulation model using Convolutional Neural Network and generated confusion matrix,
for data with SNR above 20db, the accuracy rate is close to 100%.
- Parameter tuning, using relu activation function, softmax crossentropy loss function, adam opti-
mization algorithm and adjusting learning rate, which increase the convergence speed and improve
classification accuracy.

- Cascaded two models to achieve end-to-end modulation and demodulation