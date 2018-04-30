This SoftwareAG Designer Project demonstrates using RxEPL to calculate various metrics 
for 200 different temperature sensors.

Prerequisites:
# Install Apama version 10.1 (patch 5) or higher
# Install RxEPL
# Install Lambdas for Apama (A separate project frequently used with RxEPL)

To run the code:
1) Open SoftwareAG Designer
2) Select File, Open Projects From File System
3) Select Directory...
4) Select the Sample directory
5) You should see the project name appear in the list
6) Click Finish to continue
7) Run the project by right clicking on it and selecting Run as, Apama Application


Examining the code
------------------
The main RxEPL code is in monitors/RxCode.mon

There is an equivalent RxEPL builder file, which replicates the functionality of the RxCode.mon.
This is located in: monitors/RxCode.rxblocks
Note: Some of the performance optimisations are not available in the RxEPL Builder and so have been omitted.

