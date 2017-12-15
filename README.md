# Multi-Standard OFDM-based transmitter for cognitive radios.
This repos contains the implementation of Multi-Standard OFDM-based transmitter that supports generating the transmited signals of 802.11, 802.16, 802.22. 
The operating standard of transmitter is dynamically switched by changing the configuration in run-time. 

This repos includes implementation files stored in **MY_SOURCES**, and simulation golden model stored in **MATLAB**.

**MY_SOURCES** contains hdl files using verilog to implement the sub-modules (*.v) of systems and to make a testbench files (*_tb.v). There are some pre-computed cofficient sets defined by the standard (e.g. preamble) are stored in '*.txt' files. OFDM_TX_CR.v is the top modules of transmitter.

**MATLAB** contains matlab files that simulate OFDM signals as a golden model for implementation. The matlab files are also used to generate test vector for testbench and verify the output files from testbench.

#### Publications

This implementation is presented in the paper below:

- T. H. Pham, S. A. Fahmy and I. V. McLoughlin, "An End-to-End Multi-Standard OFDM Transceiver Architecture Using FPGA Partial Reconfiguration," in IEEE Access, vol. 5, pp. 21002-21015, 2017.
[doi: 10.1109/ACCESS.2017.2756914](http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8051045&isnumber=7859429)

If you use this for research, please cite the paper:
```
@ARTICLE{Pham2017, 
author={T. H. Pham and S. A. Fahmy and I. V. McLoughlin}, 
journal={IEEE Access}, 
title={An End-to-End Multi-Standard OFDM Transceiver Architecture Using FPGA Partial Reconfiguration}, 
year={2017}, 
volume={5}, 
number={}, 
pages={21002-21015}, 
keywords={Baseband;Field programmable gate arrays;Hardware;OFDM;Program processors;Standards;OFDM;cognitive radio;open wireless architecture;radio transceivers;reconfigurable architectures}, 
doi={10.1109/ACCESS.2017.2756914}, 
ISSN={}, 
month={},}
```